import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:webchat/api/socket/websocket_service.dart';
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
    on<WebSocketConnect>(_onConnect);
    on<WebSocketDisconnect>(_onDisconnect);
    on<WebSocketSendMessage>(_onSendMessage);
    on<WebSocketSendTyping>(_onSendTyping);
    on<WebSocketStatusChanged>(_onStatusChanged);
    on<WebSocketTypingChanged>(_onTypingChanged);
    _listenToStreams();
    _initializeWithCurrentStatus();
  }

  void _initializeWithCurrentStatus() {
    final currentStatus = _webSocketService.status;
    final currentIsConnected = _webSocketService.isConnected;
    if (state.connectionStatus != currentStatus ||
        state.isConnected != currentIsConnected) {
      add(WebSocketStatusChanged(status: currentStatus));
    }
    if (currentStatus == WebSocketConnectionStatus.disconnected ||
        currentStatus == WebSocketConnectionStatus.error) {
      debugPrint('🔄 WebSocketBloc: Auto-connecting on initialization...');
      add(WebSocketConnect());
    } else if (currentStatus == WebSocketConnectionStatus.connected) {
      debugPrint('✅ WebSocketBloc: Already connected');
    }
  }

  void _listenToStreams() {
    _statusSubscription?.cancel();
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();

    _statusSubscription = _webSocketService.statusStream.listen(
      (status) {
        if (!isClosed) {
          add(WebSocketStatusChanged(status: status));
        }
      },
      onError: (error) {
        debugPrint('⚠️ Status stream error: $error');
      },
    );

    _messageSubscription = _webSocketService.messageStream.listen(
      (messageData) {
        // Messages are handled directly by MessageBloc via stream listeners
        // No need to dispatch events here
      },
      onError: (error) {
        debugPrint('⚠️ Message stream error: $error');
      },
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
      onError: (error) {
        debugPrint('⚠️ Typing stream error: $error');
      },
    );
  }

  void _onConnect(WebSocketConnect event, Emitter<WebSocketState> emit) async {
    if (state.isConnected ||
        state.connectionStatus == WebSocketConnectionStatus.connecting) {
      debugPrint('ℹ️ WebSocket already connected or connecting, skipping...');
      return;
    }

    emit(
      state.copyWith(
        connectionStatus: WebSocketConnectionStatus.connecting,
        isConnected: false,
      ),
    );

    debugPrint('🔌 WebSocketBloc: Connecting...');
    try {
      await _webSocketService.connect(url: event.url);
      debugPrint('✅ WebSocketBloc: Connection initiated');
    } catch (e) {
      debugPrint('❌ WebSocketBloc: Connection error: $e');
      emit(
        state.copyWith(
          connectionStatus: WebSocketConnectionStatus.error,
          isConnected: false,
        ),
      );
    }
  }

  void _onDisconnect(
    WebSocketDisconnect event,
    Emitter<WebSocketState> emit,
  ) async {
    await _webSocketService.disconnect();
  }

  void _onSendMessage(
    WebSocketSendMessage event,
    Emitter<WebSocketState> emit,
  ) {
    if (!state.isConnected) {
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


  void _onStatusChanged(
    WebSocketStatusChanged event,
    Emitter<WebSocketState> emit,
  ) {
    if (state.connectionStatus != event.status) {
      final newIsConnected =
          event.status == WebSocketConnectionStatus.connected;
      emit(
        state.copyWith(
          connectionStatus: event.status,
          isConnected: newIsConnected,
        ),
      );
    }
  }

  void _onTypingChanged(
    WebSocketTypingChanged event,
    Emitter<WebSocketState> emit,
  ) {
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
