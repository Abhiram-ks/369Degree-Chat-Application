import '../../domain/entity/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    super.id,
    required super.userId,
    required super.message,
    required super.date,
    required super.isCurrentUser,
    required super.status,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int?,
      userId: json['userId'] as int,
      message: json['message'] as String,
      date: DateTime.parse(json['date'] as String),
      isCurrentUser: (json['isCurrentUser'] as int) == 1,
      status: _parseStatus(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'message': message,
      'date': date.toIso8601String(),
      'isCurrentUser': isCurrentUser ? 1 : 0,
      'status': status.toString(),
    };
  }

  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      userId: userId,
      message: message,
      date: date,
      isCurrentUser: isCurrentUser,
      status: status,
    );
  }

  static MessageStatus _parseStatus(String statusStr) {
    // Handle both enum string format and simple string
    final cleanStatus = statusStr.replaceAll('MessageStatus.', '').toLowerCase();
    switch (cleanStatus) {
      case 'sending':
        return MessageStatus.sending;
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      default:
        return MessageStatus.sent;
    }
  }
}

