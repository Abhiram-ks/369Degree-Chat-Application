import 'dart:convert';
import 'package:webchat/core/constant/app_constants.dart';
import 'package:webchat/src/domain/repo/websocket_repo.dart';
import 'base/base_websocket_service.dart';

class WebSocketService {
  final BaseWebSocketService _baseService;

  WebSocketService() : _baseService = BaseWebSocketService();


  WebSocketConnectionStatus get status => _baseService.status;
  bool get isConnected => _baseService.isConnected;
  Stream<WebSocketConnectionStatus> get statusStream => _baseService.statusStream;
  Stream<Map<String, dynamic>> get messageStream => _baseService.messageStream;
  Stream<Map<String, dynamic>> get typingStream => _baseService.typingStream;

  Future<void> connect({String? url}) async {
    await _baseService.connect(url ?? AppConstants.websocketUrl);
  }

  Future<void> disconnect() async {
    await _baseService.disconnect();
  }

  void sendMessage(String message, {int? userId, int? receiverId, String? messageId}) {
    final messageData = {
      'type': 'chat',
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      if (userId != null) 'userId': userId,
      if (receiverId != null) 'receiverId': receiverId,
      if (messageId != null) 'messageId': messageId,
    };
    _baseService.sendRaw(jsonEncode(messageData));
  }

  void sendTypingIndicator(bool isTyping, {int? userId, int? receiverId}) {
    if (userId == null || !isConnected) return;

    final typingData = {
      'type': 'typing',
      'typing': isTyping,
      'userId': userId,
      if (receiverId != null) 'receiverId': receiverId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    _baseService.sendRaw(jsonEncode(typingData));
  }

  void dispose() {
    _baseService.dispose();
  }
}
