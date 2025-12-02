import 'package:flutter/material.dart';
import 'package:webchat/src/presentation/widget/chat_windows_widget/chat_bubles.dart';
import 'package:webchat/src/presentation/widget/chat_windows_widget/chat_message.dart';
import 'package:webchat/src/presentation/widget/chat_windows_widget/date_separator_widget.dart';

class MessageList extends StatelessWidget {
  final List<ChatMessage> messages;

  const MessageList({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<_MessageItem> items = [];
    String? lastDate;

    for (final chatMessage in messages) {
      DateTime? date;
      try {
        date = DateTime.parse(chatMessage.timestamp);
        final dateKey = '${date.year}-${date.month}-${date.day}';

        if (lastDate != dateKey) {
          items.add(_MessageItem(isSeparator: true, date: date));
          lastDate = dateKey;
        }
      } catch (_) {
      }

      items.add(
      _MessageItem(
          isSeparator: false,
          message: chatMessage,
        ),
      );
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[items.length - 1 - index];
        if (item.isSeparator) {
          return DateSeparatorWidget(date: item.date!);
        }
        return MessageBubleWidget(
          message: item.message!.message,
          time: item.message!.formattedTime,
          docId: item.message!.id,
          isCurrentUser: item.message!.isCurrentUser,
          status: item.message!.status,
        );
      },
    );
  }
}

class _MessageItem {
  final bool isSeparator;
  final DateTime? date;
  final ChatMessage? message;

  _MessageItem({
    required this.isSeparator,
    this.date,
    this.message,
  });
}
