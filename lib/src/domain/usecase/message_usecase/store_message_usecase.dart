import '../../entity/message_entity.dart';
import '../../repo/message_repo.dart';

class StoreMessageUsecase {
  final MessageRepo _messageRepo;

  StoreMessageUsecase({required MessageRepo messageRepo}) : _messageRepo = messageRepo;

  Future<void> call(MessageEntity message) async {
    await _messageRepo.storeMessage(message);
  }
}

