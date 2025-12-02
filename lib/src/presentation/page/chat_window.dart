import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webchat/core/di/di.dart';
import 'package:webchat/src/presentation/blocs/bloc/get_single_user_bloc/get_single_user_bloc.dart';
import 'package:webchat/src/presentation/blocs/bloc/websocket_bloc/websocket_bloc.dart';
import 'package:webchat/src/presentation/blocs/bloc/message_bloc/message_bloc.dart';
import 'package:webchat/src/presentation/widget/chat_windows_widget/chat_bubles.dart';
import 'package:webchat/src/presentation/widget/chat_windows_widget/chat_window_initializes.dart';
import 'package:webchat/src/presentation/widget/chat_windows_widget/date_separator_widget.dart';
import 'package:webchat/src/presentation/model/chat_message.dart';

class ChatWindow extends StatelessWidget {
  final int userId;

  const ChatWindow({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<GetSingleUserBloc>()
                ..add(GetSingleUserRequest(userId: userId)),
        ),
        BlocProvider(create: (context) => sl<WebSocketBloc>()),
        BlocProvider(create: (context) => sl<MessageBloc>()),
      ],
      child: Builder(
        builder: (context) {
          return ChatWindowInitializer(userId: userId);
        },
      ),
    );
  }
}


class MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final int userId;

  const MessageList({super.key, required this.messages, required this.userId});

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Widget> items = [];
    String? lastDate;

    for (final chatMessage in messages) {
      try {
        final date = DateTime.parse(chatMessage.timestamp);
        final dateKey = '${date.year}-${date.month}-${date.day}';

        if (lastDate != dateKey) {
          items.add(DateSeparatorWidget(date: date));
          lastDate = dateKey;
        }
      } catch (_) {}

      items.add(
        MessageBubleWidget(
          message: chatMessage.message,
          time: chatMessage.formattedTime,
          docId: chatMessage.id,
          isCurrentUser: chatMessage.isCurrentUser,
          status: chatMessage.status,
        ),
      );
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) => items[items.length - 1 - index],
    );
  }
}
