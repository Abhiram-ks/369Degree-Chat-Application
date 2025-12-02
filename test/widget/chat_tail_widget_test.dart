import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webchat/core/di/di.dart';
import 'package:webchat/src/domain/entity/message_entity.dart';
import 'package:webchat/src/domain/entity/user_entity.dart';
import 'package:webchat/src/domain/repo/message_repo.dart';
import 'package:webchat/src/presentation/blocs/bloc/get_store_user.dart/get_store_user_bloc.dart';
import 'package:webchat/src/presentation/page/chat_tail.dart';

class MockMessageRepo implements MessageRepo {
  @override
  Future<List<MessageEntity>> getMessagesByUserId(int userId) async {
    return [];
  }

  @override
  Stream<List<MessageEntity>> watchMessagesByUserId(int userId) {
    return Stream.value([]);
  }

  @override
  Future<void> storeMessage(MessageEntity message) async {}

  @override
  Future<void> updateMessageStatus(int messageId, MessageStatus status) async {}
}

class FakeGetStoreUserBloc extends Fake implements GetStoreUserBloc {
  FakeGetStoreUserBloc(this._state);

  final GetStoreUserState _state;

  @override
  GetStoreUserState get state => _state;

  @override
  Stream<GetStoreUserState> get stream => Stream.value(_state);

  @override
  void add(GetStoreUserEvent event) {
    debugPrint('FakeGetStoreUserBloc received event: $event');
  }
  
  @override
  Future<void> close() async {}
}

void main() {
  final testUsers = [
    UserEntity(id: 1, fullName: 'John Doe', email: 'john@example.com', avatarUrl: ''),
    UserEntity(id: 2, fullName: 'Jane Smith', email: 'jane@example.com', avatarUrl: ''),
  ];

  setUpAll(() {
    if (!sl.isRegistered<MessageRepo>()) {
      sl.registerLazySingleton<MessageRepo>(() => MockMessageRepo());
    }
  });

  tearDownAll(() async {
    await sl.reset();
  });

  //! Helper Widget for injecting Fake Bloc
  Widget createWidget(GetStoreUserState state) {
    return MaterialApp(
      home: BlocProvider<GetStoreUserBloc>.value(
        value: FakeGetStoreUserBloc(state),
        child: const ChatTail(),
      ),
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Test Navigation Target')),
          ),
        );
      },
    );
  }

  //! Test Cases key based

  testWidgets('Should display scaffold with AppBar using keys', (tester) async {
    await tester.pumpWidget(createWidget(GetStoreUserInitial()));

    expect(find.byKey(const Key('chat_tail_scaffold')), findsOneWidget);
    expect(find.byKey(const Key('chat_tail_appbar')), findsOneWidget);
    expect(find.text('Chat Application'), findsOneWidget);
  });

  testWidgets('Should display user avatar widget in AppBar', (tester) async {
    await tester.pumpWidget(createWidget(GetStoreUserInitial()));
    expect(find.byKey(const Key('user_avatar_widget')), findsOneWidget);
  });

  testWidgets('Should display loading widget when state is loading', (tester) async {
    await tester.pumpWidget(createWidget(GetStoreUserLoading()));
    await tester.pump();

    expect(find.byKey(const Key('loading_widget')), findsOneWidget);
    expect(find.byKey(const Key('users_list_view')), findsNothing);
    expect(find.byKey(const Key('no_users_found_widget')), findsNothing);
  });

  testWidgets('Should display users list view when users loaded successfully', (tester) async {
    await tester.pumpWidget(createWidget(GetStoreUserSuccess(users: testUsers)));
    await tester.pump();

    expect(find.byKey(const Key('users_list_view')), findsOneWidget);
    expect(find.byKey(const Key('loading_widget')), findsNothing);
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Jane Smith'), findsOneWidget);
  });

  testWidgets('Should display individual user tiles with specific keys', (tester) async {
    await tester.pumpWidget(createWidget(GetStoreUserSuccess(users: testUsers)));
    await tester.pump();

    // ! Check for specific user tiles by their IDs
    expect(find.byKey(const Key('chat_tile_1')), findsOneWidget);
    expect(find.byKey(const Key('chat_tile_2')), findsOneWidget);
    expect(find.byKey(const Key('user_tile_gesture_1')), findsOneWidget);
    expect(find.byKey(const Key('user_tile_gesture_2')), findsOneWidget);
  });

  testWidgets('Should display "No users found" widget when list is empty', (tester) async {
    await tester.pumpWidget(createWidget(GetStoreUserSuccess(users: [])));
    await tester.pump();

    expect(find.byKey(const Key('no_users_found_widget')), findsOneWidget);
    expect(find.byKey(const Key('users_list_view')), findsNothing);
    expect(find.text('No users found'), findsOneWidget);
  });

  testWidgets('Should display error widget when state is failure', (tester) async {
    const errorMessage = 'Failed to load users';

    await tester.pumpWidget(createWidget(GetStoreUserFailure(message: errorMessage)));
    await tester.pump();

    expect(find.byKey(const Key('error_widget')), findsOneWidget);
    expect(find.text(errorMessage), findsOneWidget);
    expect(find.byKey(const Key('loading_widget')), findsNothing);
    expect(find.byKey(const Key('users_list_view')), findsNothing);
  });

  testWidgets('Should tap on specific user tile using key-based selection', (tester) async {
    await tester.pumpWidget(createWidget(GetStoreUserSuccess(users: testUsers)));
    await tester.pumpAndSettle();

    //! Tap on the first user's gesture detector using its specific key
    final firstUserGesture = find.byKey(const Key('user_tile_gesture_1'));
    expect(firstUserGesture, findsOneWidget);

    await tester.tap(firstUserGesture);
    await tester.pumpAndSettle();

    //! Verify navigation occurred
    expect(find.text('Test Navigation Target'), findsOneWidget);
  });

  testWidgets('Should tap on second user tile using key-based selection', (tester) async {
    await tester.pumpWidget(createWidget(GetStoreUserSuccess(users: testUsers)));
    await tester.pumpAndSettle();

    //! Tap on the second user's gesture detector using its specific key
    final secondUserGesture = find.byKey(const Key('user_tile_gesture_2'));
    expect(secondUserGesture, findsOneWidget);

    await tester.tap(secondUserGesture);
    await tester.pumpAndSettle();

    //! Verify navigation occurred
    expect(find.text('Test Navigation Target'), findsOneWidget);
  });

  testWidgets('Should display chat tail builder widget', (tester) async {
    await tester.pumpWidget(createWidget(GetStoreUserInitial()));
    await tester.pump();

    expect(find.byKey(const Key('chat_tail_builder')), findsOneWidget);
  });

  testWidgets('Should display refresh indicator', (tester) async {
    await tester.pumpWidget(createWidget(GetStoreUserSuccess(users: testUsers)));
    await tester.pump();

    expect(find.byKey(const Key('chat_tail_refresh_indicator')), findsOneWidget);
  });

  testWidgets('Should have correct widget hierarchy', (tester) async {
    await tester.pumpWidget(createWidget(GetStoreUserSuccess(users: testUsers)));
    await tester.pump();

    //! Verify the widget hierarchy using keys
    expect(find.byKey(const Key('chat_tail_scaffold')), findsOneWidget);
    expect(find.byKey(const Key('chat_tail_builder')), findsOneWidget);
    expect(find.byKey(const Key('chat_tail_refresh_indicator')), findsOneWidget);
    expect(find.byKey(const Key('users_list_view')), findsOneWidget);
  });
}
