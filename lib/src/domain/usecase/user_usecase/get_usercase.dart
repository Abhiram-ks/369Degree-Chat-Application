import 'package:webchat/src/domain/repo/get_user_repo.dart';

import '../../entity/user_entity.dart';

class GetUserUsecase {
  final GetStoreUserRepo getStoreUserRepo;

  GetUserUsecase({required this.getStoreUserRepo});

  Future<List<UserEntity>> call() async {
    return await getStoreUserRepo.getUsers();
  }
}