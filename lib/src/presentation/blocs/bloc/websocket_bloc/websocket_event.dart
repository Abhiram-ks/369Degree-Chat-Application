part of 'websocket_bloc.dart';

abstract class WebSocketEvent {}

class WebSocketConnect extends WebSocketEvent {
  final String? url;
  WebSocketConnect({this.url});
}

class WebSocketDisconnect extends WebSocketEvent {}

class WebSocketSendMessage extends WebSocketEvent {
  final String message;
  final int userId;
  final String? messageId;
  WebSocketSendMessage({required this.message, required this.userId, this.messageId});
}

class WebSocketSendTyping extends WebSocketEvent {
  final bool isTyping;
  final int userId;
  WebSocketSendTyping({required this.isTyping, required this.userId});
}

class WebSocketMessageReceived extends WebSocketEvent {
  final Map<String, dynamic> messageData;
  WebSocketMessageReceived({required this.messageData});
}

class WebSocketStatusChanged extends WebSocketEvent {
  final WebSocketConnectionStatus status;
  WebSocketStatusChanged({required this.status});
}

class WebSocketTypingChanged extends WebSocketEvent {
  final bool isTyping;
  final int userId;
  WebSocketTypingChanged({required this.isTyping, required this.userId});
}

