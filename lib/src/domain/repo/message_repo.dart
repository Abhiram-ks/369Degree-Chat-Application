import 'dart:async';
import '../../domain/entity/message_entity.dart';

abstract class MessageRepo {
  Future<List<MessageEntity>> getMessagesByUserId(int userId);
  Stream<List<MessageEntity>> watchMessagesByUserId(int userId);
  Future<void> storeMessage(MessageEntity message);
  Future<void> updateMessageStatus(int messageId, MessageStatus status);
}

