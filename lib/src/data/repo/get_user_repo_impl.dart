import 'package:webchat/src/data/datasource/remote/get_users_remote_datasource.dart';
import '../../domain/entity/user_entity.dart';
import '../../domain/repo/get_user_repo.dart';

class GetUserRepoImpl implements GetUserRepo {
  final GetUsersRemoteDataSource _getUsersRemoteDataSource;

  GetUserRepoImpl({required GetUsersRemoteDataSource getUsersRemoteDataSource}) : _getUsersRemoteDataSource = getUsersRemoteDataSource;

  @override
  Future<List<UserEntity>> getUsers() async {
    return await _getUsersRemoteDataSource.getUsers();
  }
}