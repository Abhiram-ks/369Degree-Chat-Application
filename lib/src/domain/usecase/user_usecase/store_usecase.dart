import '../../../data/model/user_model.dart';
import '../../repo/get_user_repo.dart';

class StoreUserUsecase {
  final GetStoreUserRepo _GetStoreUserRepo;

  StoreUserUsecase({required GetStoreUserRepo GetStoreUserRepo}) : _GetStoreUserRepo = GetStoreUserRepo;

  Future<void> call(UserModel user) async {
    await _GetStoreUserRepo.storeUser(user);
  }
}