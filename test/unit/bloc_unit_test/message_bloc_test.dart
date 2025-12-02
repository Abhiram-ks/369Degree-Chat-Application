import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webchat/src/domain/entity/message_entity.dart';
import 'package:webchat/src/domain/repo/message_repo.dart';
import 'package:webchat/src/domain/usecase/message_usecase/store_message_usecase.dart';
import 'package:webchat/src/presentation/blocs/bloc/message_bloc/message_bloc.dart';

import 'message_bloc_test.mocks.dart';

@GenerateMocks([MessageRepo, StoreMessageUsecase])
void main() {
  late MockMessageRepo mockMessageRepo;
  late MockStoreMessageUsecase mockStoreMessageUsecase;
  late MessageBloc messageBloc;

  setUp(() {
    mockMessageRepo = MockMessageRepo();
    mockStoreMessageUsecase = MockStoreMessageUsecase();
    messageBloc = MessageBloc(
      messageRepo: mockMessageRepo,
      storeMessageUsecase: mockStoreMessageUsecase,
    );
  });

  tearDown(() {
    messageBloc.close();
  });

  group('MessageBloc Tests', () {
    test('initial state is MessageInitial', () {
      expect(messageBloc.state, isA<MessageInitial>());
    });

   ///! Test 1: LoadMessages emits MessageLoading then MessageLoaded
    test('LoadMessages emits MessageLoading then MessageLoaded', () async {
      const userId = 1;
      final testMessages = [
        MessageEntity(
          id: 1,
          userId: userId,
          message: 'Test message',
          date: DateTime(2024, 1, 1),
          isCurrentUser: true,
          status: MessageStatus.sent,
        ),
      ];

      final streamController = StreamController<List<MessageEntity>>();

      when(mockMessageRepo.getMessagesByUserId(userId))
          .thenAnswer((_) async => testMessages);
      when(mockMessageRepo.watchMessagesByUserId(userId))
          .thenAnswer((_) => streamController.stream);


      messageBloc.add(LoadMessages(userId: userId));

      await expectLater(
        messageBloc.stream,
        emitsInOrder([
          isA<MessageLoading>(),
          isA<MessageLoaded>()
              .having((state) => state.messages.length, 'messages length', 1)
              .having((state) => state.userId, 'userId', userId),
        ]),
      );

      streamController.close();
    });
  

   ///! Test 2: LoadMessages emits MessageError on failure
    test('LoadMessages emits MessageError on failure', () async {
      const userId = 1;
      when(mockMessageRepo.getMessagesByUserId(userId))
          .thenThrow(Exception('Database error'));

      messageBloc.add(LoadMessages(userId: userId));
      await expectLater(
        messageBloc.stream,
        emitsInOrder([
          isA<MessageLoading>(),
          isA<MessageError>()
              .having((state) => state.message, 'error message', contains('Database error')),
        ]),
      );
    });

   ///! Test 3: SendMessage stores message with sending status
    test('SendMessage stores message with sending status', () async {
      const userId = 1;
      const messageText = 'Hello World';

      final storedMessages = [
        MessageEntity(
          id: 1,
          userId: userId,
          message: messageText,
          date: DateTime.now(),
          isCurrentUser: true,
          status: MessageStatus.sending,
        ),
      ];

      when(mockStoreMessageUsecase.call(any)).thenAnswer((_) async {});
      when(mockMessageRepo.getMessagesByUserId(userId))
          .thenAnswer((_) async => storedMessages);

      messageBloc.add(SendMessage(userId: userId, message: messageText));
      await Future.delayed(const Duration(milliseconds: 100));
      final captured = verify(mockStoreMessageUsecase.call(captureAny)).captured;
      expect(captured.length, 1);
      final storedMessage = captured.first as MessageEntity;
      expect(storedMessage.message, messageText);
      expect(storedMessage.userId, userId);
      expect(storedMessage.isCurrentUser, true);
      expect(storedMessage.status, MessageStatus.sending);
    });

    ///! Test 5: SendMessage with empty message should not store
    test('SendMessage with empty message does nothing', () async {
      const userId = 1;
      const emptyMessage = '   ';

      when(mockMessageRepo.getMessagesByUserId(userId))
          .thenAnswer((_) async => []);

      messageBloc.add(SendMessage(userId: userId, message: emptyMessage));
      await Future.delayed(const Duration(milliseconds: 100));
      verifyNever(mockStoreMessageUsecase.call(any));
    });

    ///! Test 6: MessageReceived should store received message
    test('6. MessageReceived stores message with read status', () async {
      const userId = 1;
      const messageText = 'Incoming message';

      final testMessages = <MessageEntity>[];
      final streamController = StreamController<List<MessageEntity>>();

      when(mockMessageRepo.getMessagesByUserId(userId))
          .thenAnswer((_) async => testMessages);
      when(mockMessageRepo.watchMessagesByUserId(userId))
          .thenAnswer((_) => streamController.stream);
      when(mockStoreMessageUsecase.call(any)).thenAnswer((_) async {});

      messageBloc.add(LoadMessages(userId: userId));
      await Future.delayed(const Duration(milliseconds: 100));

      messageBloc.add(MessageReceived(userId: userId, message: messageText));
      await Future.delayed(const Duration(milliseconds: 100));

      final captured = verify(mockStoreMessageUsecase.call(captureAny)).captured;
      expect(captured.length, 1);
      final storedMessage = captured.last as MessageEntity;
      expect(storedMessage.message, messageText);
      expect(storedMessage.userId, userId);
      expect(storedMessage.isCurrentUser, false);
      expect(storedMessage.status, MessageStatus.read);

      streamController.close();
    });

      ///! Test 7: UpdateMessageStatus should update message status
    test('UpdateMessageStatus updates message status', () async {
      const messageId = 1;
      const newStatus = MessageStatus.delivered;

      when(mockMessageRepo.updateMessageStatus(messageId, newStatus))
          .thenAnswer((_) async {});
      messageBloc.add(UpdateMessageStatus(messageId: messageId, status: newStatus));
      await Future.delayed(const Duration(milliseconds: 100));

      verify(mockMessageRepo.updateMessageStatus(messageId, newStatus)).called(1);
    });

    ///! Test 8: Multiple LoadMessages should cancel previous subscription
    test('LoadMessages cancels previous subscription when userId changes', () async {
      const userId1 = 1;
      const userId2 = 2;
      final testMessages = <MessageEntity>[];
      final streamController1 = StreamController<List<MessageEntity>>();
      final streamController2 = StreamController<List<MessageEntity>>();

      when(mockMessageRepo.getMessagesByUserId(userId1))
          .thenAnswer((_) async => testMessages);
      when(mockMessageRepo.watchMessagesByUserId(userId1))
          .thenAnswer((_) => streamController1.stream);
      when(mockMessageRepo.getMessagesByUserId(userId2))
          .thenAnswer((_) async => testMessages);
      when(mockMessageRepo.watchMessagesByUserId(userId2))
          .thenAnswer((_) => streamController2.stream);

      messageBloc.add(LoadMessages(userId: userId1));
      await Future.delayed(const Duration(milliseconds: 100));

      messageBloc.add(LoadMessages(userId: userId2));
      await Future.delayed(const Duration(milliseconds: 100));

      verify(mockMessageRepo.getMessagesByUserId(userId1)).called(1);
      verify(mockMessageRepo.getMessagesByUserId(userId2)).called(1);

      streamController1.close();
      streamController2.close();
    });
  });
}

