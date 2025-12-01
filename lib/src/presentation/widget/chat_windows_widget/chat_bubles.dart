import 'package:flutter/material.dart';
import 'package:webchat/core/theme/app_colors.dart';
import 'package:webchat/src/domain/entity/message_entity.dart';

class MessageBubleWidget extends StatelessWidget {
  final String message;
  final String time;
  final String docId;
  final bool isCurrentUser;
  final MessageStatus status;

  const MessageBubleWidget({
    super.key,
    required this.message,
    required this.time,
    required this.docId,
    required this.isCurrentUser,
    this.status = MessageStatus.sent,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isCurrentUser ? AppPalette.white : AppPalette.black;

    Widget? buildStatusIcon() {
      if (!isCurrentUser) {
        return null;
      }

      switch (status) {
        case MessageStatus.sending:
          return Icon(
            Icons.access_time,
            size: 14,
            color: textColor.withValues(alpha: 0.7),
            semanticLabel: 'Sending',
          );
        case MessageStatus.sent:
          return Icon(
            Icons.done,
            size: 14,
            color: textColor.withValues(alpha: 0.7),
            semanticLabel: 'Sent',
          );
        case MessageStatus.delivered:
        case MessageStatus.read:
          // Double tick (✓✓) - WhatsApp style
          // Blue for read, white/gray for delivered
          return Icon(
            Icons.done_all,
            size: 14,
            color: status == MessageStatus.read
                ? Colors.blueAccent
                : textColor.withValues(alpha: 0.7),
            semanticLabel: status == MessageStatus.read ? 'Read' : 'Delivered',
          );
      }
    }

    final statusIcon = buildStatusIcon();

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isCurrentUser ? AppPalette.blue : AppPalette.hint,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isCurrentUser ? const Radius.circular(16) : Radius.zero,
            bottomRight:
                isCurrentUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          crossAxisAlignment: isCurrentUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
                if (statusIcon != null) ...[
                  const SizedBox(width: 4),
                  statusIcon,
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
