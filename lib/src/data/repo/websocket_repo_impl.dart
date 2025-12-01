import '../../../api/socket/websocket_service.dart';
import '../../domain/repo/websocket_repo.dart';

class WebSocketRepoImpl implements WebSocketRepo {
  final WebSocketService _webSocketService;

  WebSocketRepoImpl({required WebSocketService webSocketService})
      : _webSocketService = webSocketService;

  @override
  Stream<WebSocketConnectionStatus> get statusStream =>
      _webSocketService.statusStream;

  @override
  Stream<Map<String, dynamic>> get messageStream =>
      _webSocketService.messageStream;

  @override
  Stream<Map<String, dynamic>> get typingStream =>
      _webSocketService.typingStream;

  @override
  Future<void> connect({String? url}) async {
    await _webSocketService.connect(url: url);
  }

  @override
  Future<void> disconnect() async {
    await _webSocketService.disconnect();
  }

  @override
  void sendMessage(String message, {int? userId, String? messageId}) {
    _webSocketService.sendMessage(
      message,
      userId: userId,
      messageId: messageId,
    );
  }

  @override
  void sendTypingIndicator(bool isTyping, {int? userId}) {
    _webSocketService.sendTypingIndicator(
      isTyping,
      userId: userId,
    );
  }
}
