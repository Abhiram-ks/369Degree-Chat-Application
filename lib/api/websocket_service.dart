import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:webchat/core/constant/app_constants.dart';
import 'package:webchat/src/domain/repo/websocket_repo.dart';

class WebSocketService {
  // --- Private Instance Properties ---
  WebSocketChannel? _channel;
  WebSocketConnectionStatus _status = WebSocketConnectionStatus.disconnected;
  
  // Use final for controllers that won't be reassigned
  final StreamController<WebSocketConnectionStatus> _statusController = 
      StreamController<WebSocketConnectionStatus>.broadcast();
  final StreamController<Map<String, dynamic>> _messageController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _typingController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  StreamSubscription? _streamSubscription;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  Timer? _pongTimeoutTimer;
  
  String? _url;
  bool _shouldReconnect = true;
  bool _isReconnecting = false;
  int _reconnectAttempts = 0;
  
  // Use final for the message queue list
  final List<String> _messageQueue = [];

  // --- Static Constants (Good job!) ---
  static const int _maxQueueSize = 100;
  static const int _maxReconnectAttempts = 10;
  static const Duration _initialReconnectDelay = Duration(seconds: 2);
  static const Duration _maxReconnectDelay = Duration(seconds: 30);
  
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _pongTimeout = Duration(seconds: 10);

  // --- Public Getters ---
  WebSocketConnectionStatus get status => _status;
  bool get isConnected => _status == WebSocketConnectionStatus.connected;
  
  Stream<WebSocketConnectionStatus> get statusStream => _statusController.stream;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;

  // --- Public Methods ---

  /// Initializes connection parameters and starts the connection process.
  Future<void> connect({String? url}) async {
    if (_status == WebSocketConnectionStatus.connected ||   _status == WebSocketConnectionStatus.connecting) {
      return;
    }

    final rawUrl = url ?? AppConstants.websocketUrl;
    
    try {
      final uri = Uri.parse(rawUrl);
      if (uri.host.isEmpty) {
        throw FormatException('Invalid WebSocket URL: missing host');
      }
      _url = uri.toString();
    } catch (e) {
      _updateStatus(WebSocketConnectionStatus.error);
      return;
    }
    
    _shouldReconnect = true;
    _reconnectAttempts = 0;
    await _connect();
  }

  void sendMessage(String message, {int? userId, int? receiverId, String? messageId}) {
    final messageData = {
      'type': 'chat',
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      if (userId != null) 'userId': userId,
      if (receiverId != null) 'receiverId': receiverId,
      if (messageId != null) 'messageId': messageId,
    };
    
    _send(messageData);
  }

  void sendTypingIndicator(bool isTyping, {int? userId, int? receiverId}) {
    if (userId == null || !isConnected || _channel == null) {
      return;
    }

    final typingData = {
      'type': 'typing',
      'typing': isTyping,
      'userId': userId,
      if (receiverId != null) 'receiverId': receiverId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _send(typingData, queueIfDisconnected: false);
  }

  Future<void> disconnect() async {
    _shouldReconnect = false;
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    _isReconnecting = false;
    
    try {
      await _streamSubscription?.cancel();
      await _channel?.sink.close(1000, 'Normal closure'); 
    } catch (e) {
      throw Exception('Error closing WebSocket: $e');
    }
    
    _channel = null;
    _messageQueue.clear();
    _updateStatus(WebSocketConnectionStatus.disconnected);
  }

  void dispose() {
    disconnect(); 
    _statusController.close();
    _messageController.close();
    _typingController.close();
  }


  Future<void> _connect() async {
    if (_url == null) {
      return;
    }

    try {
      _updateStatus(WebSocketConnectionStatus.connecting);
      
      final uri = Uri.parse(_url!);
      _channel = WebSocketChannel.connect(uri);
      
      await _channel!.ready;
      
      _onOpen();

      _streamSubscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onClose,
        cancelOnError: false,
      );
    } catch (e) {
      _onError(e);
    }
  }

  void _onOpen() {
    _reconnectAttempts = 0;
    _isReconnecting = false;
    _reconnectTimer?.cancel();
    _updateStatus(WebSocketConnectionStatus.connected);
    
    _startHeartbeat();
    _flushMessageQueue();
  }

  void _onMessage(dynamic message) {
    _startHeartbeat(); 

    try {
      if (message is String) {
        final trimmed = message.trim();
        
        if (trimmed.toLowerCase() == 'pong') {
          _pongTimeoutTimer?.cancel();
          return;
        }
        
        if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) {
          return;
        }
        
        final data = jsonDecode(message) as Map<String, dynamic>;
        
        if (data.containsKey('type')) {
          switch (data['type']) {
            case 'typing':
              final isTyping = data['typing'] as bool? ?? data['isTyping'] as bool? ?? false;
              final userId = data['userId'] as int?;
              if (userId != null) {
                _typingController.add({
                  'isTyping': isTyping,
                  'userId': userId,
                });
              }
              return;
          }
        }
        
        _messageController.add(data);
      }
    } catch (e) {
      debugPrint('❌ Error handling message: $e\nOriginal: $message');
    }
  }

  void _onError(dynamic error) {
    _stopHeartbeat();
    if (_status != WebSocketConnectionStatus.error) {
      _updateStatus(WebSocketConnectionStatus.error);
    }
    _streamSubscription?.cancel();
    _streamSubscription = null;
    
    _scheduleReconnect();
  }

  void _onClose() {
    _stopHeartbeat();
    
    if (_status != WebSocketConnectionStatus.disconnected && 
        _status != WebSocketConnectionStatus.error) {
      _updateStatus(WebSocketConnectionStatus.disconnected);
    }
  
    _streamSubscription?.cancel();
    _streamSubscription = null;
    
    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }
  
  void _scheduleReconnect() {
    if (!_shouldReconnect) {
      return;
    }
    
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      return;
    }
    
    if (_isReconnecting) {
      return;
    }
    
    if (_status == WebSocketConnectionStatus.connecting) {
      return;
    }

    _reconnectTimer?.cancel();
    _isReconnecting = true;
    
    final delayMs = (_initialReconnectDelay.inMilliseconds * (1 << _reconnectAttempts))
        .clamp(_initialReconnectDelay.inMilliseconds, _maxReconnectDelay.inMilliseconds);
    final delay = Duration(milliseconds: delayMs);
    
    _reconnectAttempts++;
    debugPrint('🔄 Scheduling reconnect attempt $_reconnectAttempts in ${delay.inSeconds}s');
    
    _reconnectTimer = Timer(delay, () {
      _isReconnecting = false;
      
      if (!_shouldReconnect) {
        return;
      }
      
      // Only reconnect if still disconnected or in error state
      if (_status == WebSocketConnectionStatus.disconnected || 
          _status == WebSocketConnectionStatus.error) {
        _connect();
      } else {
        debugPrint('✅ Already connected, skipping reconnect');
      }
    });
  }
  
  /// Generic method to handle sending and queuing.
  void _send(Map<String, dynamic> data, {bool queueIfDisconnected = true}) {
    final jsonMessage = jsonEncode(data);
    
    if (isConnected && _channel != null) {
      try {
        _channel!.sink.add(jsonMessage);
        // Reset heartbeat on any outgoing message
        _startHeartbeat(); 
      } catch (e) {
        debugPrint('❌ Error sending message: $e');
        if (queueIfDisconnected) {
          _queueMessage(jsonMessage);
        }
      }
    } else if (queueIfDisconnected) {
      debugPrint('📦 Queueing message (disconnected)');
      _queueMessage(jsonMessage);
    }
  }

  /// Flush queued messages when connection is restored.
  void _flushMessageQueue() {
    if (_messageQueue.isEmpty) return;
    
    debugPrint('📤 Flushing ${_messageQueue.length} queued messages');
    
    // Create a copy and clear the original queue to prevent re-queueing loops
    final messagesToSend = List<String>.from(_messageQueue);
    _messageQueue.clear(); 
    
    for (final message in messagesToSend) {
      if (isConnected && _channel != null) {
        try {
          _channel!.sink.add(message);
        } catch (e) {
          debugPrint('❌ Error flushing queued message: $e');
          // If sending fails during flush, re-queue
          _queueMessage(message); 
        }
      } else {
        // If connection is lost again during flush, re-queue the remaining messages
        _queueMessage(message); 
      }
    }
  }
  
  /// Queue message when disconnected (or when sending fails).
  void _queueMessage(String message) {
    if (_messageQueue.length >= _maxQueueSize) {
      debugPrint('⚠️ Message queue full, dropping oldest message');
      _messageQueue.removeAt(0);
    }
    _messageQueue.add(message);
  }

  // --- Private Heartbeat Logic ---

  /// Heartbeat/Ping-Pong pattern to keep connection alive.
  void _startHeartbeat() {
    _stopHeartbeat(); // Cancel previous timers
    
    _heartbeatTimer = Timer(_heartbeatInterval, () {
      if (isConnected && _channel != null) {
        try {
          _channel!.sink.add('ping');
          debugPrint('💓 Sending ping');
          
          // Set pong timeout
          _pongTimeoutTimer = Timer(_pongTimeout, () {
            debugPrint('⚠️ Pong timeout - connection may be stale');
            _onError('Pong timeout'); // Force error/reconnect
          });
        } catch (e) {
          debugPrint('❌ Error sending ping: $e');
        }
      }
    });
  }
  
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _pongTimeoutTimer?.cancel();
  }

  // --- Private Utility ---

  void _updateStatus(WebSocketConnectionStatus newStatus) {
    if (_status == newStatus) return; // Prevent unnecessary stream events
    _status = newStatus;
    _statusController.add(newStatus);
  }
}