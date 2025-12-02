

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webchat/core/common/custom_state_handle_widgets.dart';
import 'package:webchat/src/presentation/blocs/bloc/message_bloc/message_bloc.dart';
import 'package:webchat/src/presentation/page/chat_window.dart';

import '../../../../core/theme/app_colors.dart';
import '../../blocs/bloc/websocket_bloc/websocket_bloc.dart';
import 'chat_window_text_style.dart';

class ChatWindowBody extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onTextChanged;
  final Function() onSendMessage;
  final int userId;

  const ChatWindowBody({
    super.key,
    required this.controller,
    required this.userId,
    required this.onTextChanged,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageBloc, MessageState>(
      builder: (context, msgState) {
        if (msgState is MessageLoading || msgState is MessageInitial) {
          return CustomStateHandleWidgets.loadingWidget();
        }

        if (msgState is MessageError) {
          return CustomStateHandleWidgets.informationWidget(
            message: msgState.message,
            onTap: () {
              context.read<MessageBloc>().add(LoadMessages(userId: userId));
            },
          );
        }

        if (msgState is! MessageLoaded) {
          return CustomStateHandleWidgets.loadingWidget();
        }

        return Column(
          children: [
            Expanded(
              child: MessageList(messages: msgState.messages, userId: userId),
            ),
            BlocBuilder<WebSocketBloc, WebSocketState>(
              builder: (context, wsState) {
                final isTyping = wsState.isTypingForUser(userId);
                if (isTyping) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Center(
                          child: Text(
                            'typing...',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppPalette.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            ChatWindowTextFiled(
              controller: controller,
              onTextChanged: onTextChanged,
              sendButton: onSendMessage,
            ),
          ],
        );
      },
    );
  }
}