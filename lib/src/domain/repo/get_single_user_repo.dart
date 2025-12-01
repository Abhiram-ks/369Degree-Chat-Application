import '../entity/user_entity.dart';

abstract class GetSingleUserRepo {
  Future<UserEntity> getUserById(int userId);
}