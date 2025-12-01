import '../entity/user_entity.dart';
import '../repo/get_single_user_repo.dart';

class GetSingleUserUsecase {
  final GetSingleUserRepo _getSingleUserRepo;

  GetSingleUserUsecase({required GetSingleUserRepo getSingleUserRepo}) : _getSingleUserRepo = getSingleUserRepo;

  Future<UserEntity> call(int userId) async {
    return await _getSingleUserRepo.getUserById(userId);
  }
}