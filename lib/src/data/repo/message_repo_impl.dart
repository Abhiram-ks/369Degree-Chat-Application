import '../../domain/entity/message_entity.dart';
import '../../domain/repo/message_repo.dart';
import '../datasource/local/message_local_datasource.dart';
import '../model/message_model.dart';

class MessageRepoImpl implements MessageRepo {
  final MessageLocalDataSource _localDataSource;

  MessageRepoImpl({required MessageLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<List<MessageEntity>> getMessagesByUserId(int userId) async {
    final messages = await _localDataSource.getMessagesByUserId(userId);
    return messages.map((m) => m.toEntity()).toList();
  }

  @override
  Stream<List<MessageEntity>> watchMessagesByUserId(int userId) {
    return _localDataSource.watchMessagesByUserId(userId)
        .map((messages) => messages.map((m) => m.toEntity()).toList());
  }

  @override
  Future<void> storeMessage(MessageEntity message) async {
    final messageModel = MessageModel(
      id: message.id,
      userId: message.userId,
      message: message.message,
      date: message.date,
      isCurrentUser: message.isCurrentUser,
      status: message.status,
    );
    await _localDataSource.storeMessage(messageModel);
  }

  @override
  Future<void> updateMessageStatus(int messageId, MessageStatus status) async {
    await _localDataSource.updateMessageStatus(messageId, status.toString());
  }
}

