import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webchat/core/di/di.dart';
import 'package:webchat/core/constant/app_constants.dart';
import 'package:webchat/api/socket/websocket_service.dart';
import 'package:webchat/src/presentation/blocs/bloc/websocket_bloc/websocket_bloc.dart';
import 'package:webchat/src/presentation/blocs/bloc/message_bloc/message_bloc.dart';
import '../../../domain/entity/message_entity.dart';

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

  void initializeChat() {
    final webSocketBloc = context.read<WebSocketBloc>();
    final messageBloc = context.read<MessageBloc>();

    messageBloc.add(LoadMessages(userId: userId));

    if (!webSocketBloc.state.isConnected) {
      webSocketBloc.add(WebSocketConnect(url: AppConstants.websocketUrl));
    }
    _listenToWebSocketMessages(messageBloc);
  }

  void _listenToWebSocketMessages(MessageBloc messageBloc) {
    final webSocketService = sl<WebSocketService>();
    
    _webSocketMessageSubscription = webSocketService.messageStream.listen(
      (messageData) {
        _handleIncomingMessage(messageData, messageBloc);
      },
        onError: (error) {
          throw Exception('WebSocket message stream error: $error');
      },
    );
  }

  void _handleIncomingMessage(
    Map<String, dynamic> messageData,
    MessageBloc messageBloc,
  ) {
    final msgState = messageBloc.state;
    
    if (msgState is! MessageLoaded) return;

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

    if (messageData.containsKey('message') && messageData['message'] != null) {
      final message = messageData['message'].toString();
      final messageUserId = messageData['userId'] as int?;
      
      if (message.isNotEmpty && messageUserId == userId) {
        final now = DateTime.now();
        
        final sendingMessage = msgState.messages.firstWhere(
          (m) => m.isCurrentUser && 
                 m.message == message &&
                 (m.status == MessageStatus.sending || m.status == MessageStatus.sent) &&
                 now.difference(DateTime.parse(m.timestamp)).inSeconds < 10,
          orElse: () => msgState.messages.first,
        );
        
        if ((sendingMessage.status == MessageStatus.sending || 
             sendingMessage.status == MessageStatus.sent) &&
            sendingMessage.isCurrentUser) {
          final dbMessageId = int.tryParse(sendingMessage.id);
          if (dbMessageId != null) {
            messageBloc.add(
              UpdateMessageStatus(
                messageId: dbMessageId,
                status: MessageStatus.delivered,
              ),
            );
          }
        }
        

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

  void onTextChanged(String text) {
    final webSocketBloc = context.read<WebSocketBloc>();
    if (webSocketBloc.isClosed || !webSocketBloc.state.isConnected) return;

    final trimmedText = text.trim();

    if (trimmedText.isNotEmpty) {
      if (!webSocketBloc.isClosed) {
        webSocketBloc.add(WebSocketSendTyping(isTyping: true, userId: userId));
      }
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(milliseconds: 500), () {
        if (!webSocketBloc.isClosed && webSocketBloc.state.isConnected) {
          webSocketBloc.add(WebSocketSendTyping(isTyping: false, userId: userId));
        }
      });
    } else {
      _typingTimer?.cancel();
      if (!webSocketBloc.isClosed && webSocketBloc.state.isConnected) {
        webSocketBloc.add(WebSocketSendTyping(isTyping: false, userId: userId));
      }
    }
  }

  void onSendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final webSocketBloc = context.read<WebSocketBloc>();
    final messageBloc = context.read<MessageBloc>();

    if (webSocketBloc.isClosed || !webSocketBloc.state.isConnected) {
      return;
    }

    controller.clear();
    _typingTimer?.cancel();
    
    if (!webSocketBloc.isClosed) {
      webSocketBloc.add(WebSocketSendTyping(isTyping: false, userId: userId));
    }
    
    if (!messageBloc.isClosed) {
      messageBloc.add(SendMessage(userId: userId, message: text));
    }
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    final msgState = messageBloc.state;
    if (msgState is MessageLoaded && 
        !webSocketBloc.isClosed && 
        webSocketBloc.state.isConnected) {
      final messagesToSend = msgState.messages.where((m) => 
        m.isCurrentUser &&
        m.message == text &&
        m.status == MessageStatus.sending
      ).toList();

      if (messagesToSend.isNotEmpty) {
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
  }

  void dispose() {
    _typingTimer?.cancel();
    _webSocketMessageSubscription?.cancel();
  }
}