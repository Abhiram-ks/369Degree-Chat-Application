import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webchat/api/socket/websocket_service.dart';
import 'package:webchat/src/data/repo/websocket_repo_impl.dart';
import 'package:webchat/src/domain/repo/websocket_repo.dart';
import 'web_socket_test.mocks.dart';

@GenerateMocks([WebSocketService])
void main() {
  late MockWebSocketService mockWebSocketService;
  late WebSocketRepoImpl repository; 

  setUp(() {
    mockWebSocketService = MockWebSocketService();
    repository = WebSocketRepoImpl(webSocketService: mockWebSocketService); 
  });

  group('WebSocketRepoImpl Delegation Tests', () {
    test('connect delegates ', () async {
      const testUrl = 'wss://echo.websocket.org';
      when(mockWebSocketService.connect(url: anyNamed('url')))
          .thenAnswer((_) async {});
      await repository.connect(url: testUrl);
      verify(mockWebSocketService.connect(url: testUrl)).called(1);
    });
    
    test('connect propagates exceptions', () async {
      const testUrl = 'wss://echo.websocket.org';
      final testException = Exception('Connection refused');
      when(mockWebSocketService.connect(url: anyNamed('url')))
          .thenThrow(testException);
      expect(
        () => repository.connect(url: testUrl),
        throwsA(testException),
      );

      verify(mockWebSocketService.connect(url: testUrl)).called(1);
    });


    test('disconnect delegates', () async {
      when(mockWebSocketService.disconnect()).thenAnswer((_) async {});
      await repository.disconnect();

      verify(mockWebSocketService.disconnect()).called(1);
    });

    test('sendMessage delegates', () {
      const testMessage = 'Hello World';
      const testUserId = 42;
      const testMessageId = 'uuid-123';
    
      repository.sendMessage(
        testMessage,
        userId: testUserId,
        messageId: testMessageId,
      );

      verify(mockWebSocketService.sendMessage(
        testMessage,
        userId: testUserId,
        messageId: testMessageId,
      )).called(1);
    });

    test('statusStream correctly delegates', () {
      final mockStreamController = StreamController<WebSocketConnectionStatus>();
      when(mockWebSocketService.statusStream)
          .thenAnswer((_) => mockStreamController.stream);

      final repoStream = repository.statusStream;

      expect(repoStream, isA<Stream<WebSocketConnectionStatus>>());
      verify(mockWebSocketService.statusStream).called(1);

      mockStreamController.close();
    });

    test('messageStream correctly delegates', () {
      final mockStreamController = StreamController<Map<String, dynamic>>();
      when(mockWebSocketService.messageStream)
          .thenAnswer((_) => mockStreamController.stream);

      final repoStream = repository.messageStream;

      expect(repoStream, isA<Stream<Map<String, dynamic>>>());
      verify(mockWebSocketService.messageStream).called(1);

      mockStreamController.close();
    });
    
    test('typingStream correctly delegates', () {
      final mockStreamController = StreamController<Map<String, dynamic>>();
      when(mockWebSocketService.typingStream)
          .thenAnswer((_) => mockStreamController.stream);

      final repoStream = repository.typingStream;

      expect(repoStream, isA<Stream<Map<String, dynamic>>>());

      verify(mockWebSocketService.typingStream).called(1);

      mockStreamController.close();
    });

    test('sendTypingIndicator delegates', () {
      const testIsTyping = true;
      const testUserId = 42;

      repository.sendTypingIndicator(testIsTyping, userId: testUserId);

      verify(mockWebSocketService.sendTypingIndicator(
        testIsTyping,
        userId: testUserId,
      )).called(1);
    });
  });
}