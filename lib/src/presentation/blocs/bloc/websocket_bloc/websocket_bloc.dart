import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:webchat/api/websocket_service.dart';
import 'package:webchat/src/domain/repo/websocket_repo.dart';

part 'websocket_event.dart';
part 'websocket_state.dart';

class WebSocketBloc extends Bloc<WebSocketEvent, WebSocketState> {
  final WebSocketService _webSocketService;
  StreamSubscription<WebSocketConnectionStatus>? _statusSubscription;
  StreamSubscription<Map<String, dynamic>>? _messageSubscription;
  StreamSubscription<Map<String, dynamic>>? _typingSubscription;

  WebSocketBloc({required WebSocketService webSocketService})
      : _webSocketService = webSocketService,
        super(
          WebSocketState(
            connectionStatus: webSocketService.status,
            isConnected: webSocketService.isConnected,
          ),
        ) {
    // Register all event handlers first
    on<WebSocketConnect>(_onConnect);
    on<WebSocketDisconnect>(_onDisconnect);
    on<WebSocketSendMessage>(_onSendMessage);
    on<WebSocketSendTyping>(_onSendTyping);
    on<WebSocketMessageReceived>(_onMessageReceived);
    on<WebSocketStatusChanged>(_onStatusChanged);
    on<WebSocketTypingChanged>(_onTypingChanged);
    
    // Initialize with current WebSocketService status using post-frame callback
    _initializeWithCurrentStatus();
    
    // Then start listening to streams after handlers are registered
    _listenToStreams();
  }
  
  /// Initialize BLoC state with current WebSocketService status
  /// This ensures the BLoC reflects the actual connection state when recreated
  void _initializeWithCurrentStatus() {
    final currentStatus = _webSocketService.status;
    final isConnected = _webSocketService.isConnected;
    
    // Use addPostFrameCallback to emit after the frame, as emit can't be called directly
    // from constructor context in BLoC v8+
    Future.microtask(() {
      if (!isClosed) {
        add(WebSocketStatusChanged(status: currentStatus));
      }
    });
    
    debugPrint('🔄 WebSocketBloc: Initialized with status: $currentStatus (connected: $isConnected)');
    
    // If disconnected but should reconnect, trigger reconnection
    if (currentStatus == WebSocketConnectionStatus.disconnected && 
        currentStatus != WebSocketConnectionStatus.error) {
      // Don't auto-connect here, let the UI trigger it via WebSocketConnect event
      debugPrint('ℹ️ WebSocket is disconnected - waiting for connect event');
    }
  }

  void _listenToStreams() {
    // Cancel existing subscriptions if any (for hot reload safety)
    _statusSubscription?.cancel();
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();

    _statusSubscription = _webSocketService.statusStream.listen(
      (status) {
        if (!isClosed) {
          add(WebSocketStatusChanged(status: status));
        }
      },
      onError: (error) => debugPrint('Status stream error: $error'),
    );

    _messageSubscription = _webSocketService.messageStream.listen(
      (messageData) {
        if (!isClosed) {
          add(WebSocketMessageReceived(messageData: messageData));
        }
      },
      onError: (error) => debugPrint('Message stream error: $error'),
    );

    _typingSubscription = _webSocketService.typingStream.listen(
      (typingData) {
        if (!isClosed) {
          final userId = typingData['userId'] as int?;
          final isTyping = typingData['isTyping'] as bool? ?? false;
          if (userId != null) {
            add(WebSocketTypingChanged(isTyping: isTyping, userId: userId));
          }
        }
      },
      onError: (error) => debugPrint('Typing stream error: $error'),
    );
  }

  void _onConnect(WebSocketConnect event, Emitter<WebSocketState> emit) async {
    debugPrint('🔌 WebSocketBloc: Connecting...');
    try {
      await _webSocketService.connect(url: event.url);
    } catch (e) {
      debugPrint('❌ WebSocketBloc: Connection error: $e');
      emit(state.copyWith(
        connectionStatus: WebSocketConnectionStatus.error,
        isConnected: false,
      ));
    }
  }

  void _onDisconnect(WebSocketDisconnect event, Emitter<WebSocketState> emit) async {
    debugPrint('🔌 WebSocketBloc: Disconnecting...');
    await _webSocketService.disconnect();
  }

  void _onSendMessage(WebSocketSendMessage event, Emitter<WebSocketState> emit) {
    if (!state.isConnected) {
      debugPrint('⚠️ Cannot send message: WebSocket not connected');
      return;
    }
    
    _webSocketService.sendMessage(
      event.message,
      userId: event.userId,
      messageId: event.messageId,
    );
  }

  void _onSendTyping(WebSocketSendTyping event, Emitter<WebSocketState> emit) {
    if (!state.isConnected) {
      return;
    }
    
    _webSocketService.sendTypingIndicator(event.isTyping, userId: event.userId);
  }

  void _onMessageReceived(WebSocketMessageReceived event, Emitter<WebSocketState> emit) {
    // Message received event handler
    // The message data is in event.messageData
    // This handler ensures the event is properly processed
    // Actual message processing is handled by MessageBloc via stream listeners
    debugPrint('📬 WebSocketBloc: Message received event processed');
  }

  void _onStatusChanged(WebSocketStatusChanged event, Emitter<WebSocketState> emit) {
    debugPrint('🔄 WebSocketBloc: Status changed to ${event.status}');
    final newState = state.copyWith(
      connectionStatus: event.status,
      isConnected: event.status == WebSocketConnectionStatus.connected,
    );
    emit(newState);
    debugPrint('✅ WebSocketBloc: State emitted - isConnected: ${newState.isConnected}');
  }

  void _onTypingChanged(WebSocketTypingChanged event, Emitter<WebSocketState> emit) {
    final updatedTypingUsers = Map<int, bool>.from(state.typingUsers);
    if (event.isTyping) {
      updatedTypingUsers[event.userId] = true;
    } else {
      updatedTypingUsers.remove(event.userId);
    }
    emit(state.copyWith(typingUsers: updatedTypingUsers));
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    return super.close();
  }
}

