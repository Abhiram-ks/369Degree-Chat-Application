import 'dart:async';

enum WebSocketConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}


abstract class WebSocketRepo {
  Stream<WebSocketConnectionStatus> get statusStream;
  Stream<Map<String, dynamic>> get messageStream;
  Stream<Map<String, dynamic>> get typingStream;
  Future<void> connect({String? url});
  Future<void> disconnect();
  void sendMessage(String message, {int? userId, String? messageId});
  void sendTypingIndicator(bool isTyping, {int? userId});
}
