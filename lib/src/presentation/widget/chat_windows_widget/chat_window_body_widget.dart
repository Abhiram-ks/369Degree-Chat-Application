import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webchat/core/common/custom_state_handle_widgets.dart';
import 'package:webchat/src/presentation/blocs/bloc/message_bloc/message_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../blocs/bloc/websocket_bloc/websocket_bloc.dart';
import 'chat_window_message_list_widget.dart';
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
          return Container(
            key: const Key('chat_body_loading_widget'),
            child: CustomStateHandleWidgets.loadingWidget(),
          );
        }

        if (msgState is MessageError) {
          return Container(
            key: const Key('chat_body_error_widget'),
            child: CustomStateHandleWidgets.informationWidget(
              message: msgState.message,
              onTap: () {
                context.read<MessageBloc>().add(LoadMessages(userId: userId));
              },
            ),
          );
        }

        if (msgState is! MessageLoaded) {
          return Container(
            key: const Key('chat_body_loading_widget'),
            child: CustomStateHandleWidgets.loadingWidget(),
          );
        }
        final isEmpty = msgState.messages.isEmpty;

        return Column(
          key: const Key('chat_body_content_column'),
          children: [
            Expanded(
              child: isEmpty
                  ? Align(
                    alignment: .topCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          key: const Key('chat_body_empty_message_widget'),
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppPalette.blue.withAlpha((0.3 * 255).round()),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "⚿ It looks like your chat box is empty! Start a conversation with a client — your chats will appear here. All conversations are private and secure.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppPalette.black,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    )
                  : MessageList(
                      key: const Key('chat_body_message_list'),
                      messages: msgState.messages,
                    ),
            ),
            BlocBuilder<WebSocketBloc, WebSocketState>(
              builder: (context, wsState) {
                final isTyping = wsState.isTypingForUser(userId);
                if (isTyping) {
                  return Container(
                    key: const Key('chat_body_typing_indicator'),
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
                return const SizedBox.shrink(key: Key('chat_body_typing_hidden'));
              },
            ),
            ChatWindowTextFiled(
              key: const Key('chat_body_text_field'),
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