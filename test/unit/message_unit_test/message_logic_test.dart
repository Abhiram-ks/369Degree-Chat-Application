import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webchat/src/data/repo/message_repo_impl.dart';
import 'package:webchat/src/domain/entity/message_entity.dart';
import 'message_logic_test.mocks.dart';


@GenerateMocks([MessageRepoImpl])
void main() {
  late MockMessageRepoImpl mockMessageRepoImpl;

  setUp(() {
    mockMessageRepoImpl = MockMessageRepoImpl();
  });
  

  //! getMessagesByUserId return messages Objects
  test('getMessagesByUserId return messages Objects', () async {
    when(mockMessageRepoImpl.getMessagesByUserId(any)).thenAnswer(
      (_) async => [
        MessageEntity(
          id: 1,
          message: 'Unknown Message Type',
          date: DateTime.now(),
          userId: 1,
          status: MessageStatus.sent,
          isCurrentUser: true,
        ),
      ],
    );
    final messages = await mockMessageRepoImpl.getMessagesByUserId(1);
    expect(messages.first.id, 1);
    expect(messages, isA<List<MessageEntity>>());
  });


  //! watchMessagesByUserId return stream of messages
  test('watchMessagesByUserId return stream of messages', () async {
    // Arrange: Mock the stream to return a list of messages
    when(mockMessageRepoImpl.watchMessagesByUserId(any)).thenAnswer(
      (_) => Stream.value([
        MessageEntity(
          id: 1,
          message: 'Test Message',
          date: DateTime.now(),
          userId: 1,
          status: MessageStatus.sent,
          isCurrentUser: true,
        ),
      ]),
    );

    // Act: Get the stream
    final messagesStream = mockMessageRepoImpl.watchMessagesByUserId(-4);
    expect(messagesStream, isA<Stream<List<MessageEntity>>>());
    
    final messages = await messagesStream.first;
    expect(messages.first.id, 1);
    expect(messages, isA<List<MessageEntity>>());
  });

  //! storeMessage completes successfully
  test('storeMessage completes successfully', () async {
    when(mockMessageRepoImpl.storeMessage(any)).thenAnswer((_) async {});

    await mockMessageRepoImpl.storeMessage(
      MessageEntity(
        id: 1,
        message: 'Test Message',
        date: DateTime.now(),
        userId: 1,
        status: MessageStatus.sent,
        isCurrentUser: true,
      ),
    );

    verify(mockMessageRepoImpl.storeMessage(any)).called(1);
  });

  //! updateMessageStatus completes successfully
  test('updateMessageStatus completes successfully', () async {
    when(mockMessageRepoImpl.updateMessageStatus(any, any))
        .thenAnswer((_) async {});

    await mockMessageRepoImpl.updateMessageStatus(1, MessageStatus.delivered);
    verify(mockMessageRepoImpl.updateMessageStatus(1, MessageStatus.delivered))
        .called(1);
  });
}
