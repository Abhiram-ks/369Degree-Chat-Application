import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webchat/api/socket/websocket_service.dart';
import 'package:webchat/core/di/di.dart';
import 'package:webchat/src/domain/entity/message_entity.dart';
import 'package:webchat/src/domain/entity/user_entity.dart';
import 'package:webchat/src/domain/repo/websocket_repo.dart';
import 'package:webchat/src/presentation/blocs/bloc/get_single_user_bloc/get_single_user_bloc.dart';
import 'package:webchat/src/presentation/blocs/bloc/message_bloc/message_bloc.dart';
import 'package:webchat/src/presentation/blocs/bloc/websocket_bloc/websocket_bloc.dart';
import 'package:webchat/src/presentation/widget/chat_windows_widget/chat_appbar.dart';
import 'package:webchat/src/presentation/widget/chat_windows_widget/chat_window_body_widget.dart';
import 'package:webchat/src/presentation/widget/chat_windows_widget/chat_message.dart';

class MockWebSocketService extends Fake implements WebSocketService {
  @override
  Stream<Map<String, dynamic>> get messageStream => Stream.empty();
}
class FakeGetSingleUserBloc extends Fake implements GetSingleUserBloc {
  FakeGetSingleUserBloc(this._state);

  final GetSingleUserState _state;

  @override
  GetSingleUserState get state => _state;

  @override
  Stream<GetSingleUserState> get stream => Stream.value(_state);

  @override
  void add(GetSingleUserEvent event) {}

  @override
  Future<void> close() async {}
}

class FakeMessageBloc extends Fake implements MessageBloc {
  FakeMessageBloc(this._state);

  final MessageState _state;

  @override
  MessageState get state => _state;

  @override
  Stream<MessageState> get stream => Stream.value(_state);

  @override
  void add(MessageEvent event) {}

  @override
  Future<void> close() async {}
}

class FakeWebSocketBloc extends Fake implements WebSocketBloc {
  FakeWebSocketBloc(this._state);

  final WebSocketState _state;

  @override
  WebSocketState get state => _state;

  @override
  Stream<WebSocketState> get stream => Stream.value(_state);

  @override
  void add(WebSocketEvent event) {}

  @override
  Future<void> close() async {}
}

void main() {
  final testUser = UserEntity(
    id: 1,
    fullName: 'John Doe',
    email: 'john@example.com',
    avatarUrl: 'https://example.com/avatar.jpg',
  );

  final testMessages = [
    ChatMessage(
      id: '1',
      message: 'Hello!',
      timestamp: DateTime.now().toIso8601String(),
      isCurrentUser: true,
      status: MessageStatus.sent,
    ),
    ChatMessage(
      id: '2',
      message: 'Hi there!',
      timestamp: DateTime.now().toIso8601String(),
      isCurrentUser: false,
      status: MessageStatus.delivered,
    ),
  ];

  setUpAll(() {
    //! Register mock WebSocketService in GetIt for all tests
    if (!sl.isRegistered<WebSocketService>()) {
      sl.registerLazySingleton<WebSocketService>(() => MockWebSocketService());
    }
  });

  tearDownAll(() async {
    //! Clean up service locator after tests
    await sl.reset();
  });

  // ---------------------------------------------------------------
  // !Helper Widget for injecting Fake Blocs
  // ---------------------------------------------------------------
  Widget createWidget({
    required GetSingleUserState userState,
    required MessageState messageState,
    required WebSocketState webSocketState,
    int userId = 1,
  }) {
    final controller = TextEditingController();
    
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<GetSingleUserBloc>.value(
            value: FakeGetSingleUserBloc(userState),
          ),
          BlocProvider<MessageBloc>.value(
            value: FakeMessageBloc(messageState),
          ),
          BlocProvider<WebSocketBloc>.value(
            value: FakeWebSocketBloc(webSocketState),
          ),
        ],
        child: LayoutBuilder(
          key: const Key('chat_window_layout_builder'),
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            return Scaffold(
              key: const Key('chat_window_scaffold'),
              appBar: ChatAppBar(
                key: const Key('chat_window_appbar'),
                userId: userId,
                screenWidth: screenWidth,
              ),
              body: ChatWindowBody(
                key: const Key('chat_window_body'),
                controller: controller,
                userId: userId,
                onTextChanged: (_) {},
                onSendMessage: () {},
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  //! KEY-BASED TEST CASES
  // ---------------------------------------------------------------

  group('ChatWindow Scaffold Tests', () {
    testWidgets('Should display scaffold and layout builder using keys', (tester) async {
      await tester.pumpWidget(createWidget(
        userState: GetSingleUserSuccess(user: testUser),
        messageState: MessageLoaded(messages: [], userId: 1),
        webSocketState: WebSocketState(
          connectionStatus: WebSocketConnectionStatus.connected,
        ),
      ));
      await tester.pump();

      expect(find.byKey(const Key('chat_window_layout_builder')), findsOneWidget);
      expect(find.byKey(const Key('chat_window_scaffold')), findsOneWidget);
    });

    testWidgets('Should display chat window body using key', (tester) async {
      await tester.pumpWidget(createWidget(
        userState: GetSingleUserSuccess(user: testUser),
        messageState: MessageLoaded(messages: [], userId: 1),
        webSocketState: WebSocketState(
          connectionStatus: WebSocketConnectionStatus.connected,
        ),
      ));
      await tester.pump();

      expect(find.byKey(const Key('chat_window_body')), findsOneWidget);
    });
  });

  group('ChatWindow AppBar Tests', () {
    testWidgets('Should display chat window appbar using key', (tester) async {
      await tester.pumpWidget(createWidget(
        userState: GetSingleUserSuccess(user: testUser),
        messageState: MessageLoaded(messages: [], userId: 1),
        webSocketState: WebSocketState(
          connectionStatus: WebSocketConnectionStatus.connected,
        ),
      ));
      await tester.pump();

      expect(find.byKey(const Key('chat_window_appbar')), findsOneWidget);
    });

    testWidgets('Should display successful appbar with user info', (tester) async {
      await tester.pumpWidget(createWidget(
        userState: GetSingleUserSuccess(user: testUser),
        messageState: MessageLoaded(messages: [], userId: 1),
        webSocketState: WebSocketState(
          connectionStatus: WebSocketConnectionStatus.connected,
        ),
      ));
      await tester.pump();

      expect(find.byKey(const Key('chat_appbar_success')), findsOneWidget);
      expect(find.byKey(const Key('chat_appbar_back_button')), findsOneWidget);
      expect(find.byKey(const Key('chat_appbar_user_info')), findsOneWidget);
    });

    testWidgets('Should display user avatar in appbar', (tester) async {
      await tester.pumpWidget(createWidget(
        userState: GetSingleUserSuccess(user: testUser),
        messageState: MessageLoaded(messages: [], userId: 1),
        webSocketState: WebSocketState(
          connectionStatus: WebSocketConnectionStatus.connected,
        ),
      ));
      await tester.pump();

      expect(find.byKey(const Key('chat_appbar_avatar_container')), findsOneWidget);
      expect(find.byKey(const Key('chat_appbar_avatar_image')), findsOneWidget);
      expect(find.byKey(const Key('chat_appbar_online_indicator')), findsOneWidget);
    });

    testWidgets('Should display user name in appbar', (tester) async {
      await tester.pumpWidget(createWidget(
        userState: GetSingleUserSuccess(user: testUser),
        messageState: MessageLoaded(messages: [], userId: 1),
        webSocketState: WebSocketState(
          connectionStatus: WebSocketConnectionStatus.connected,
        ),
      ));
      await tester.pump();

      expect(find.byKey(const Key('chat_appbar_user_name')), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('Should display online status when connected', (tester) async {
      await tester.pumpWidget(createWidget(
        userState: GetSingleUserSuccess(user: testUser),
        messageState: MessageLoaded(messages: [], userId: 1),
        webSocketState: WebSocketState(
          connectionStatus: WebSocketConnectionStatus.connected,
        ),
      ));
      await tester.pump();

      expect(find.byKey(const Key('chat_appbar_status_row')), findsOneWidget);
      expect(find.byKey(const Key('chat_appbar_status_dot')), findsOneWidget);
      expect(find.byKey(const Key('chat_appbar_status_text')), findsOneWidget);
      expect(find.text('Online'), findsOneWidget);
    });

    testWidgets('Should display offline status when disconnected', (tester) async {
      await tester.pumpWidget(createWidget(
        userState: GetSingleUserSuccess(user: testUser),
        messageState: MessageLoaded(messages: [], userId: 1),
        webSocketState: WebSocketState(
          connectionStatus: WebSocketConnectionStatus.disconnected,
        ),
      ));
      await tester.pump();

      expect(find.byKey(const Key('chat_appbar_status_text')), findsOneWidget);
      expect(find.text('Offline'), findsOneWidget);
    });

    testWidgets('Should display typing indicator in appbar when user is typing', (tester) async {
      await tester.pumpWidget(createWidget(
        userState: GetSingleUserSuccess(user: testUser),
        messageState: MessageLoaded(messages: [], userId: 1),
        webSocketState: WebSocketState(
          connectionStatus: WebSocketConnectionStatus.connected,
          typingUsers: {1: true},
        ),
      ));
      await tester.pump();

      expect(find.byKey(const Key('chat_appbar_typing_indicator')), findsOneWidget);
      expect(find.text('typing...'), findsAtLeastNWidgets(1));
    });

    testWidgets('Should display loading appbar when user state is loading', (tester) async {
      await tester.pumpWidget(createWidget(
        userState: GetSingleUserLoading(),
        messageState: MessageLoaded(messages: [], userId: 1),
        webSocketState: WebSocketState(
          connectionStatus: WebSocketConnectionStatus.connected,
        ),
      ));
      await tester.pump();

      expect(find.byKey(const Key('chat_appbar_loading')), findsOneWidget);
    });
  });

  group('ChatWindow Body Tests', () {
    testWidgets('Should display loading widget when messages are loading', (tester) async {
      await tester.pumpWidget(createWidget(
        userState: GetSingleUserSuccess(user: testUser),
        messageState: MessageLoading(),
        webSocketState: WebSocketState(
          connectionStatus: WebSocketConnectionStatus.connected,
        ),
      ));
      await tester.pump();

      expect(find.byKey(const Key('chat_body_loading_widget')), findsOneWidget);
    });

    testWidgets('Should display error widget when message loading fails', (tester) async {
      await tester.pumpWidget(createWidget(
        userState: GetSingleUserSuccess(user: testUser),
        messageState: MessageError(message: 'Failed to load messages'),
        webSocketState: WebSocketState(
          connectionStatus: WebSocketConnectionStatus.connected,
        ),
      ));
      await tester.pump();

      expect(find.byKey(const Key('chat_body_error_widget')), findsOneWidget);
      expect(find.text('Failed to load messages'), findsOneWidget);
    });

    testWidgets('Should display empty message widget when no messages', (tester) async {
      await tester.pumpWidget(createWidget(
        userState: GetSingleUserSuccess(user: testUser),
        messageState: MessageLoaded(messages: [], userId: 1),
        webSocketState: WebSocketState(
          connectionStatus: WebSocketConnectionStatus.connected,
        ),
      ));
      await tester.pump();

      expect(find.byKey(const Key('chat_body_empty_message_widget')), findsOneWidget);
      expect(find.textContaining('chat box is empty'), findsOneWidget);
    });

    testWidgets('Should display message list when messages are loaded', (tester) async {
      await tester.pumpWidget(createWidget(
        userState: GetSingleUserSuccess(user: testUser),
        messageState: MessageLoaded(messages: testMessages, userId: 1),
        webSocketState: WebSocketState(
          connectionStatus: WebSocketConnectionStatus.connected,
        ),
      ));
      await tester.pump();

      expect(find.byKey(const Key('chat_body_content_column')), findsOneWidget);
      expect(find.byKey(const Key('chat_body_message_list')), findsOneWidget);
    });

    testWidgets('Should display text field in chat body', (tester) async {
      await tester.pumpWidget(createWidget(
        userState: GetSingleUserSuccess(user: testUser),
        messageState: MessageLoaded(messages: [], userId: 1),
        webSocketState: WebSocketState(
          connectionStatus: WebSocketConnectionStatus.connected,
        ),
      ));
      await tester.pump();

      expect(find.byKey(const Key('chat_body_text_field')), findsOneWidget);
    });

    testWidgets('Should display typing indicator in body when user is typing', (tester) async {
      await tester.pumpWidget(createWidget(
        userState: GetSingleUserSuccess(user: testUser),
        messageState: MessageLoaded(messages: testMessages, userId: 1),
        webSocketState: WebSocketState(
          connectionStatus: WebSocketConnectionStatus.connected,
          typingUsers: {1: true},
        ),
      ));
      await tester.pump();

      expect(find.byKey(const Key('chat_body_typing_indicator')), findsOneWidget);
    });

    testWidgets('Should hide typing indicator when user is not typing', (tester) async {
      await tester.pumpWidget(createWidget(
        userState: GetSingleUserSuccess(user: testUser),
        messageState: MessageLoaded(messages: testMessages, userId: 1),
        webSocketState: WebSocketState(
          connectionStatus: WebSocketConnectionStatus.connected,
          typingUsers: <int, bool>{},
        ),
      ));
      await tester.pump();

      expect(find.byKey(const Key('chat_body_typing_hidden')), findsOneWidget);
      expect(find.byKey(const Key('chat_body_typing_indicator')), findsNothing);
    });
  });

  group('ChatWindow Complete Widget Hierarchy Tests', () {
    testWidgets('Should have correct complete widget hierarchy when loaded', (tester) async {
      await tester.pumpWidget(createWidget(
        userState: GetSingleUserSuccess(user: testUser),
        messageState: MessageLoaded(messages: testMessages, userId: 1),
        webSocketState: WebSocketState(
          connectionStatus: WebSocketConnectionStatus.connected,
        ),
      ));
      await tester.pump();

      //? Verify scaffold and layout
      expect(find.byKey(const Key('chat_window_layout_builder')), findsOneWidget);
      expect(find.byKey(const Key('chat_window_scaffold')), findsOneWidget);
      
      //? Verify appbar components
      expect(find.byKey(const Key('chat_window_appbar')), findsOneWidget);
      expect(find.byKey(const Key('chat_appbar_success')), findsOneWidget);
      expect(find.byKey(const Key('chat_appbar_user_name')), findsOneWidget);
      
      //? Verify body components
      expect(find.byKey(const Key('chat_window_body')), findsOneWidget);
      expect(find.byKey(const Key('chat_body_content_column')), findsOneWidget);
      expect(find.byKey(const Key('chat_body_message_list')), findsOneWidget);
      expect(find.byKey(const Key('chat_body_text_field')), findsOneWidget);
    });

    testWidgets('Should handle all loading states correctly', (tester) async {
      await tester.pumpWidget(createWidget(
        userState: GetSingleUserLoading(),
        messageState: MessageLoading(),
        webSocketState: WebSocketState(
          connectionStatus: WebSocketConnectionStatus.connecting,
        ),
      ));
      await tester.pump();

      expect(find.byKey(const Key('chat_appbar_loading')), findsOneWidget);
      expect(find.byKey(const Key('chat_body_loading_widget')), findsOneWidget);
    });

    testWidgets('Should handle websocket connection states', (tester) async {
      //! Test connected state
      await tester.pumpWidget(createWidget(
        userState: GetSingleUserSuccess(user: testUser),
        messageState: MessageLoaded(messages: [], userId: 1),
        webSocketState: WebSocketState(
          connectionStatus: WebSocketConnectionStatus.connected,
        ),
      ));
      await tester.pump();

      expect(find.text('Online'), findsOneWidget);

      //! Test disconnected state
      await tester.pumpWidget(createWidget(
        userState: GetSingleUserSuccess(user: testUser),
        messageState: MessageLoaded(messages: [], userId: 1),
        webSocketState: WebSocketState(
          connectionStatus: WebSocketConnectionStatus.disconnected,
        ),
      ));
      await tester.pump();

      expect(find.text('Offline'), findsOneWidget);
    });
  });
}
