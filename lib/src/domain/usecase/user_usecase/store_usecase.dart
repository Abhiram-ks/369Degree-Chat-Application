import '../../../data/model/user_model.dart';
import '../../repo/get_user_repo.dart';

class StoreUserUsecase {
  final GetStoreUserRepo _getStoreUserRepo;

  StoreUserUsecase({required GetStoreUserRepo getStoreUserRepo}) : _getStoreUserRepo = getStoreUserRepo;

  Future<void> call(UserModel user) async {
    await _getStoreUserRepo.storeUser(user);
  }
}