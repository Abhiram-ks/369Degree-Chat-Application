part of 'message_bloc.dart';

abstract class MessageState {}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class MessageLoaded extends MessageState {
  final List<ChatMessage> messages;
  final int userId;

  MessageLoaded({required this.messages, required this.userId});
}

class MessageError extends MessageState {
  final String message;
  MessageError({required this.message});
}

