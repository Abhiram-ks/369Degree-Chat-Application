import 'package:webchat/src/domain/entity/user_entity.dart';

abstract class GetUserRepo {
  Future<List<UserEntity>> getUsers();
}