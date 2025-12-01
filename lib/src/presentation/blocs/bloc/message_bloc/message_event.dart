part of 'message_bloc.dart';

abstract class MessageEvent {}

class LoadMessages extends MessageEvent {
  final int userId;
  LoadMessages({required this.userId});
}

class SendMessage extends MessageEvent {
  final int userId;
  final String message;
  SendMessage({required this.userId, required this.message});
}

class MessageReceived extends MessageEvent {
  final int userId;
  final String message;
  MessageReceived({required this.userId, required this.message});
}

class UpdateMessageStatus extends MessageEvent {
  final int messageId;
  final MessageStatus status;
  UpdateMessageStatus({required this.messageId, required this.status});
}

// Internal events for stream updates
class _MessagesUpdated extends MessageEvent {
  final List<MessageEntity> messages;
  final int userId;
  _MessagesUpdated({required this.messages, required this.userId});
}

class _MessagesError extends MessageEvent {
  final String message;
  _MessagesError({required this.message});
}

