import 'dart:async';

/// WebSocket connection status enumeration
enum WebSocketConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

/// Abstract repository interface for WebSocket operations
/// This defines the contract that any WebSocket repository implementation must follow
abstract class WebSocketRepo {
  /// Stream of connection status changes
  Stream<WebSocketConnectionStatus> get statusStream;
  
  /// Stream of incoming messages
  Stream<Map<String, dynamic>> get messageStream;
  
  /// Stream of typing indicators
  Stream<Map<String, dynamic>> get typingStream;
  
  /// Connect to WebSocket server
  /// [url] - Optional WebSocket URL. If not provided, uses default from constants
  Future<void> connect({String? url});
  
  /// Disconnect from WebSocket server
  Future<void> disconnect();
  
  /// Send a chat message
  /// [message] - The message text to send
  /// [userId] - Optional user ID
  /// [messageId] - Optional message ID for tracking
  void sendMessage(String message, {int? userId, String? messageId});
  
  /// Send typing indicator
  /// [isTyping] - Whether the user is typing or not
  /// [userId] - The user ID who is typing
  void sendTypingIndicator(bool isTyping, {int? userId});
}
