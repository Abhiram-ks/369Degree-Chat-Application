import '../../../domain/entity/message_entity.dart';

class ChatMessage {
  final String id;
  final String message;
  final String timestamp;
  final bool isCurrentUser;
  final MessageStatus status;

  ChatMessage({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.isCurrentUser,
    required this.status,
  });

  String get formattedTime {
    try {
      final dateTime = DateTime.parse(timestamp);
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      final now = DateTime.now();
      final hour = now.hour.toString().padLeft(2, '0');
      final minute = now.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
  }
}

