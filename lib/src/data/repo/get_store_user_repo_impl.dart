import 'package:webchat/src/data/datasource/remote/get_store_users_remote_datasource.dart';
import 'package:webchat/src/data/model/user_model.dart';
import '../../domain/entity/user_entity.dart';
import '../../domain/repo/get_user_repo.dart';
import '../datasource/local/store_user_local_datasource.dart';

class GetStoreUserRepoImpl implements GetStoreUserRepo {
  final GetUsersRemoteDataSource _getUsersRemoteDataSource;
  final StoreUserLocalDataSource _storeUserLocalDataSource;

  GetStoreUserRepoImpl({required GetUsersRemoteDataSource getUsersRemoteDataSource, required StoreUserLocalDataSource storeUserLocalDataSource}) : _getUsersRemoteDataSource = getUsersRemoteDataSource, _storeUserLocalDataSource = storeUserLocalDataSource;

  //! Get Users
  @override
  Future<List<UserEntity>> getUsers() async {
    return await _getUsersRemoteDataSource.getUsers();
  }

  //! Store User
  @override
  Future<void> storeUser(UserModel user) async {
    await _storeUserLocalDataSource.storeUser(user);
  }
}