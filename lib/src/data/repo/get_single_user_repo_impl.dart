import '../../domain/entity/user_entity.dart';
import '../../domain/repo/get_single_user_repo.dart';
import '../datasource/local/store_user_local_datasource.dart';
import '../model/user_model.dart';

class GetSingleUserRepoImpl implements GetSingleUserRepo {
  final StoreUserLocalDataSource _storeUserLocalDataSource;

  GetSingleUserRepoImpl({required StoreUserLocalDataSource storeUserLocalDataSource}) : _storeUserLocalDataSource = storeUserLocalDataSource;

  @override
  Future<UserEntity> getUserById(int userId) async {
    final UserModel? user = await _storeUserLocalDataSource.getUserById(userId);
    if (user == null) {
      throw Exception('User not found');
    }
     return user.toEntity();
  }
}