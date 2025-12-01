import '../../entity/message_entity.dart';
import '../../repo/message_repo.dart';

class GetMessagesUsecase {
  final MessageRepo _messageRepo;

  GetMessagesUsecase({required MessageRepo messageRepo}) : _messageRepo = messageRepo;

  Future<List<MessageEntity>> call(int userId) async {
    return await _messageRepo.getMessagesByUserId(userId);
  }
}

