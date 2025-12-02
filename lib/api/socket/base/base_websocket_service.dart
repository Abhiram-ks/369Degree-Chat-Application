import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:webchat/src/domain/repo/websocket_repo.dart';
import 'package:webchat/core/error/error_handler.dart';

import '../../../core/error/web_socket_exeption.dart';

/// !Base WebSocket service - Core connection functionality
/// !Handles: connect, disconnect, message streams, reconnection
class BaseWebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _streamSubscription;
  WebSocketConnectionStatus _status = WebSocketConnectionStatus.disconnected;

  final StreamController<WebSocketConnectionStatus> _statusController =
      StreamController<WebSocketConnectionStatus>.broadcast();
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _typingController =
      StreamController<Map<String, dynamic>>.broadcast();

  Timer? _reconnectTimer;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  String? _url;

  static const int _maxReconnectAttempts = 10;
  static const Duration _reconnectDelay = Duration(seconds: 2);

  WebSocketConnectionStatus get status => _status;
  bool get isConnected => _status == WebSocketConnectionStatus.connected;
  Stream<WebSocketConnectionStatus> get statusStream => _statusController.stream;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;

  Future<void> connect(String url) async {
    if (_status == WebSocketConnectionStatus.connected ||
        _status == WebSocketConnectionStatus.connecting) {
      return;
    }

    if (url.isEmpty) {
      _updateStatus(WebSocketConnectionStatus.error);
      return;
    }

    _url = url;
    try {
      final uri = Uri.parse(_url!);
      if (uri.host.isEmpty) {
        throw FormatException('Invalid WebSocket URL: missing host');
      }
    } catch (e) {
      _updateStatus(WebSocketConnectionStatus.error);
      return;
    }

    _shouldReconnect = true;
    _reconnectAttempts = 0;
    await _connect();
  }

  Future<void> _connect() async {
    if (_url == null || _url!.isEmpty) {
      _onError(WebSocketException.invalidUrl());
      return;
    }

    try {
      _updateStatus(WebSocketConnectionStatus.connecting);
      final uri = Uri.parse(_url!);
      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;

      _updateStatus(WebSocketConnectionStatus.connected);
      _reconnectAttempts = 0;

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

  void _onMessage(dynamic message) {
    try {
      if (message is! String) return;

      final trimmed = message.trim();
      if (trimmed.toLowerCase() == 'pong') return;
      if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) return;

      final data = jsonDecode(message) as Map<String, dynamic>;

      if (data.containsKey('type') && data['type'] == 'typing') {
        final isTyping = data['typing'] as bool? ?? data['isTyping'] as bool? ?? false;
        final userId = data['userId'] as int?;
        if (userId != null) {
          _typingController.add({'isTyping': isTyping, 'userId': userId});
          return;
        }
      }

      _messageController.add(data);
    } catch (e) {
      debugPrint(' Error handling message: $e');
    }
  }

  void _onError(dynamic error) {
    ErrorHandler.handleWebSocketError(error);
    _updateStatus(WebSocketConnectionStatus.error);
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _scheduleReconnect();
  }

  void _onClose() {
    _updateStatus(WebSocketConnectionStatus.disconnected);
    _streamSubscription?.cancel();
    _streamSubscription = null;
    if (_shouldReconnect) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect || _reconnectAttempts >= _maxReconnectAttempts) return;

    _reconnectTimer?.cancel();
    _reconnectAttempts++;

    _reconnectTimer = Timer(_reconnectDelay, () {
      if (_shouldReconnect &&
          (_status == WebSocketConnectionStatus.disconnected ||
              _status == WebSocketConnectionStatus.error)) {
        _connect();
      }
    });
  }

  void sendRaw(String message) {
    if (!isConnected || _channel == null) {
      _onError(WebSocketException.sendFailed(
        originalError: 'Not connected to WebSocket',
      ));
      return;
    }
    try {
      _channel!.sink.add(message);
    } catch (e) {
      ErrorHandler.handleWebSocketError(e);
    }
  }

  Future<void> disconnect() async {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();

    try {
      await _streamSubscription?.cancel();
      await _channel?.sink.close(1000, 'Normal closure');
    } catch (e) {
      debugPrint('Error closing WebSocket: $e');
    }

    _channel = null;
    _streamSubscription = null;
    _updateStatus(WebSocketConnectionStatus.disconnected);
  }

  void _updateStatus(WebSocketConnectionStatus newStatus) {
    if (_status == newStatus) return;
    _status = newStatus;
    _statusController.add(newStatus);
  }

  void dispose() {
    disconnect();
    _statusController.close();
    _messageController.close();
    _typingController.close();
  }
}

