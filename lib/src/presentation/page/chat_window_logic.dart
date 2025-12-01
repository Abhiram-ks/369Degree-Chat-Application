import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webchat/core/di/di.dart';
import 'package:webchat/core/constant/app_constants.dart';
import 'package:webchat/api/websocket_service.dart';
import 'package:webchat/src/presentation/blocs/bloc/websocket_bloc/websocket_bloc.dart';
import 'package:webchat/src/presentation/blocs/bloc/message_bloc/message_bloc.dart';
import 'package:webchat/src/presentation/widget/chat_windows_widget/chat_bubles.dart';

import '../../domain/entity/message_entity.dart';

/// Business logic handler for ChatWindow
/// Separates logic from UI for better maintainability
class ChatWindowLogic {
  final BuildContext context;
  final int userId;
  final TextEditingController controller;
  Timer? _typingTimer;
  StreamSubscription<Map<String, dynamic>>? _webSocketMessageSubscription;

  ChatWindowLogic({
    required this.context,
    required this.userId,
    required this.controller,
  });

  /// Initialize chat: connect WebSocket and load messages
  void initializeChat() {
    final webSocketBloc = context.read<WebSocketBloc>();
    final messageBloc = context.read<MessageBloc>();

    // Load messages first
    messageBloc.add(LoadMessages(userId: userId));

    // Connect WebSocket (will reconnect if already connected)
    // The WebSocketService is a singleton, so it maintains connection state
    if (!webSocketBloc.state.isConnected) {
      webSocketBloc.add(WebSocketConnect(url: AppConstants.websocketUrl));
    } else {
      debugPrint('✅ WebSocket already connected, skipping connect event');
    }

    // Listen to WebSocket messages and forward to MessageBloc
    _listenToWebSocketMessages(messageBloc);
  }

  /// Listen to WebSocket messages and handle them properly
  /// Following WebSocket API best practices: https://websocket.org/reference/websocket-api
  void _listenToWebSocketMessages(MessageBloc messageBloc) {
    final webSocketService = sl<WebSocketService>();
    
    _webSocketMessageSubscription = webSocketService.messageStream.listen(
      (messageData) {
        _handleIncomingMessage(messageData, messageBloc);
      },
      onError: (error) {
        debugPrint('❌ WebSocket message stream error: $error');
      },
    );
  }

  /// Handle incoming WebSocket message
  /// Updates message status to "delivered" when echo is received
  /// Following WebSocket API best practices: https://websocket.org/reference/websocket-api
  void _handleIncomingMessage(
    Map<String, dynamic> messageData,
    MessageBloc messageBloc,
  ) {
    final msgState = messageBloc.state;
    
    if (msgState is! MessageLoaded) return;

    // Handle message acknowledgment (delivered status)
    if (messageData.containsKey('ack') && messageData['ack'] == true) {
      final messageId = messageData['messageId'];
      final messageUserId = messageData['userId'] as int?;
      
      if (messageId != null && messageUserId == userId) {
        final messageIdInt = int.tryParse(messageId.toString());
        if (messageIdInt != null) {
          messageBloc.add(
            UpdateMessageStatus(
              messageId: messageIdInt,
              status: MessageStatus.delivered,
            ),
          );
        }
      }
      return;
    }

    // Handle message echo - update status from "sending" to "delivered"
    if (messageData.containsKey('message') && messageData['message'] != null) {
      final message = messageData['message'].toString();
      final messageUserId = messageData['userId'] as int?;
      
      if (message.isNotEmpty && messageUserId == userId) {
        final now = DateTime.now();
        
        // Find the sending message and update its status to "delivered"
        final sendingMessage = msgState.messages.firstWhere(
          (m) => m.isCurrentUser && 
                 m.message == message &&
                 (m.status == MessageStatus.sending || m.status == MessageStatus.sent) &&
                 now.difference(DateTime.parse(m.timestamp)).inSeconds < 10,
          orElse: () => msgState.messages.first,
        );
        
        if (sendingMessage.status == MessageStatus.sending || 
            sendingMessage.status == MessageStatus.sent) {
          final dbMessageId = int.tryParse(sendingMessage.id);
          if (dbMessageId != null) {
            messageBloc.add(
              UpdateMessageStatus(
                messageId: dbMessageId,
                status: MessageStatus.delivered,
              ),
            );
            debugPrint('✅ Message status updated to delivered: $dbMessageId');
          }
        }
        
        // Create receiver message (left side) when WebSocket echo is received
        // This shows message on both sender and receiver sides
        final receiverExists = msgState.messages.any((m) => 
          !m.isCurrentUser && 
          m.message == message &&
          now.difference(DateTime.parse(m.timestamp)).inSeconds < 10
        );
        
        if (!receiverExists) {
          messageBloc.add(
            MessageReceived(
              userId: userId,
              message: message,
            ),
          );
        }
      }
    }
  }

  /// Handle text input changes - send typing indicator
  void onTextChanged(String text) {
    final webSocketBloc = context.read<WebSocketBloc>();
    if (!webSocketBloc.state.isConnected) return;

    final trimmedText = text.trim();

    if (trimmedText.isNotEmpty) {
      webSocketBloc.add(WebSocketSendTyping(isTyping: true, userId: userId));
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        if (webSocketBloc.state.isConnected) {
          webSocketBloc.add(WebSocketSendTyping(isTyping: false, userId: userId));
        }
      });
    } else {
      _typingTimer?.cancel();
      if (webSocketBloc.state.isConnected) {
        webSocketBloc.add(WebSocketSendTyping(isTyping: false, userId: userId));
      }
    }
  }

  /// Handle send message action
  void onSendMessage() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final webSocketBloc = context.read<WebSocketBloc>();
    final messageBloc = context.read<MessageBloc>();

    if (!webSocketBloc.state.isConnected) {
      debugPrint('⚠️ Cannot send message: WebSocket not connected');
      return;
    }

    controller.clear();
    _typingTimer?.cancel();
    webSocketBloc.add(WebSocketSendTyping(isTyping: false, userId: userId));

    // Store message locally first with "sending" status
    messageBloc.add(SendMessage(userId: userId, message: text));

    // Send via WebSocket after a short delay to ensure message is stored
    Future.delayed(const Duration(milliseconds: 100), () {
      final msgState = messageBloc.state;
      if (msgState is MessageLoaded) {
        final messagesToSend = msgState.messages
            .where((m) => m.isCurrentUser &&
                   m.message == text &&
                   m.status == MessageStatus.sending)
            .toList();

        if (messagesToSend.isNotEmpty && webSocketBloc.state.isConnected) {
          final messageToSend = messagesToSend.last;
          webSocketBloc.add(
            WebSocketSendMessage(
              message: text,
              userId: userId,
              messageId: messageToSend.id,
            ),
          );
        }
      }
    });
  }

  /// Dispose resources
  void dispose() {
    _typingTimer?.cancel();
    _webSocketMessageSubscription?.cancel();
  }
}

