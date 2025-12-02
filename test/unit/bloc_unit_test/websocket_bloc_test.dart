import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webchat/api/socket/websocket_service.dart';
import 'package:webchat/src/domain/repo/websocket_repo.dart';
import 'package:webchat/src/presentation/blocs/bloc/websocket_bloc/websocket_bloc.dart';

import 'websocket_bloc_test.mocks.dart';

@GenerateMocks([WebSocketService])
void main() {
  late MockWebSocketService mockWebSocketService;
  late WebSocketBloc webSocketBloc;
  late StreamController<WebSocketConnectionStatus> statusController;
  late StreamController<Map<String, dynamic>> messageController;
  late StreamController<Map<String, dynamic>> typingController;

  setUp(() {
    mockWebSocketService = MockWebSocketService();
    statusController = StreamController<WebSocketConnectionStatus>.broadcast();
    messageController = StreamController<Map<String, dynamic>>.broadcast();
    typingController = StreamController<Map<String, dynamic>>.broadcast();

    when(mockWebSocketService.status).thenReturn(WebSocketConnectionStatus.disconnected);
    when(mockWebSocketService.isConnected).thenReturn(false);
    when(mockWebSocketService.statusStream).thenAnswer((_) => statusController.stream);
    when(mockWebSocketService.messageStream).thenAnswer((_) => messageController.stream);
    when(mockWebSocketService.typingStream).thenAnswer((_) => typingController.stream);
    when(mockWebSocketService.connect(url: anyNamed('url'))).thenAnswer((_) async {});
    when(mockWebSocketService.disconnect()).thenAnswer((_) async {});

    webSocketBloc = WebSocketBloc(
      webSocketService: mockWebSocketService,
      autoConnect: false, 
    );
  });

  tearDown(() {
    webSocketBloc.close();
    statusController.close();
    messageController.close();
    typingController.close();
  });

  group('WebSocketBloc Tests', () {
    ///! Test 1: Initial state should use service status
    test('initial state uses WebSocketService status', () {
      expect(webSocketBloc.state.connectionStatus, WebSocketConnectionStatus.disconnected);
      expect(webSocketBloc.state.isConnected, false);
    });

    ///! Test 2: WebSocketConnect event should call service connect
    test('WebSocketConnect calls service connect', () async {
      const testUrl = 'wss://echo.websocket.org';

      webSocketBloc.add(WebSocketConnect(url: testUrl));
      await Future.delayed(const Duration(milliseconds: 100));

      verify(mockWebSocketService.connect(url: testUrl)).called(1);
    });

    ///! Test 3: WebSocketDisconnect event should call service disconnect
    test('WebSocketDisconnect calls service disconnect', () async {
      webSocketBloc.add(WebSocketDisconnect());
      await Future.delayed(const Duration(milliseconds: 100));
      verify(mockWebSocketService.disconnect()).called(1);
    });

    ///! Test 4: WebSocketSendMessage should call service sendMessage when connected
    test('WebSocketSendMessage calls service when connected', () async {
      when(mockWebSocketService.status).thenReturn(WebSocketConnectionStatus.connected);
      when(mockWebSocketService.isConnected).thenReturn(true);

      final connectedBloc = WebSocketBloc(
        webSocketService: mockWebSocketService,
        autoConnect: false,
      );

      const testMessage = 'Hello';
      const userId = 1;
      const messageId = '123';

      connectedBloc.add(WebSocketSendMessage(
        message: testMessage,
        userId: userId,
        messageId: messageId,
      ));
      await Future.delayed(const Duration(milliseconds: 100));

      verify(mockWebSocketService.sendMessage(
        testMessage,
        userId: userId,
        messageId: messageId,
      )).called(1);

      connectedBloc.close();
    });

    ///! Test 5: WebSocketSendMessage should not call service when disconnected
    test('5. WebSocketSendMessage does nothing when disconnected', () async {
      const testMessage = 'Hello';
      const userId = 1;

      webSocketBloc.add(WebSocketSendMessage(
        message: testMessage,
        userId: userId,
        messageId: '123',
      ));
      await Future.delayed(const Duration(milliseconds: 100));

      verifyNever(mockWebSocketService.sendMessage(any, userId: anyNamed('userId'), messageId: anyNamed('messageId')));
    });

    ///! Test 6: WebSocketStatusChanged should update connection status
    test('WebSocketStatusChanged updates connection status', () async {
      webSocketBloc.add(WebSocketStatusChanged(status: WebSocketConnectionStatus.connected));
      await expectLater(
        webSocketBloc.stream,
        emits(
          isA<WebSocketState>()
              .having((state) => state.connectionStatus, 'status', WebSocketConnectionStatus.connected)
              .having((state) => state.isConnected, 'isConnected', true),
        ),
      );
    });

    ///! Test 7: WebSocketTypingChanged should update typing users
    test('WebSocketTypingChanged adds user to typing list', () async {
      webSocketBloc.add(WebSocketTypingChanged(isTyping: true, userId: 1));
      await expectLater(
        webSocketBloc.stream,
        emits(
          isA<WebSocketState>()
              .having((state) => state.typingUsers[1], 'user 1 typing', true),
        ),
      );
    });

    ///! Test 8: WebSocketTypingChanged with false should remove user from typing list
    test('WebSocketTypingChanged removes user from typing list', () async {
      webSocketBloc.add(WebSocketTypingChanged(isTyping: true, userId: 1));
      await Future.delayed(const Duration(milliseconds: 100));
      webSocketBloc.add(WebSocketTypingChanged(isTyping: false, userId: 1));
      await expectLater(
        webSocketBloc.stream,
        emits(
          isA<WebSocketState>()
              .having((state) => state.typingUsers.containsKey(1), 'user 1 not typing', false),
        ),
      );
    });

    ///! Test 9: WebSocketSendTyping should call service when connected
    test('WebSocketSendTyping calls service when connected', () async {
      when(mockWebSocketService.status).thenReturn(WebSocketConnectionStatus.connected);
      when(mockWebSocketService.isConnected).thenReturn(true);

      final connectedBloc = WebSocketBloc(
        webSocketService: mockWebSocketService,
        autoConnect: false,
      );

      const userId = 1;

      connectedBloc.add(WebSocketSendTyping(isTyping: true, userId: userId));
      await Future.delayed(const Duration(milliseconds: 100));

      verify(mockWebSocketService.sendTypingIndicator(true, userId: userId)).called(1);

      connectedBloc.close();
    });

    ///! Test 10: WebSocketSendTyping should not call service when disconnected
    test('WebSocketSendTyping does nothing when disconnected', () async {
      const userId = 1;
      webSocketBloc.add(WebSocketSendTyping(isTyping: true, userId: userId));
      await Future.delayed(const Duration(milliseconds: 100));

      verifyNever(mockWebSocketService.sendTypingIndicator(any, userId: anyNamed('userId')));
    });
  });
}

