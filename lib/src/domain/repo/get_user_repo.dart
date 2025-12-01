import 'package:webchat/src/data/model/user_model.dart';
import 'package:webchat/src/domain/entity/user_entity.dart';

abstract class GetStoreUserRepo {
  Future<List<UserEntity>> getUsers();
  Future<void> storeUser(UserModel user);
}