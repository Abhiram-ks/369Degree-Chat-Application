import '../../domain/entity/message_entity.dart';

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

  ChatMessage copyWith({
    String? id,
    String? message,
    String? timestamp,
    bool? isCurrentUser,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      status: status ?? this.status,
    );
  }

  String get formattedTime {
    try {
      final dateTime = DateTime.parse(timestamp);
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      // Return time in HH:MM format
      return '$hour:$minute';
    } catch (e) {
      // Fallback to current time if parsing fails
      final now = DateTime.now();
      final hour = now.hour.toString().padLeft(2, '0');
      final minute = now.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
  }
}

