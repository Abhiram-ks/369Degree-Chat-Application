import '../../presentation/widget/chat_windows_widget/chat_bubles.dart';

class MessageEntity {
  final int? id;
  final int userId;
  final String message;
  final DateTime date;
  final bool isCurrentUser;
  final MessageStatus status;

  MessageEntity({
    this.id,
    required this.userId,
    required this.message,
    required this.date,
    required this.isCurrentUser,
    required this.status,
  });
}

