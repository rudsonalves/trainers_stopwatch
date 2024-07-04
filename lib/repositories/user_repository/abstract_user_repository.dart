import '../../common/models/user_model.dart';

abstract class AbstractUserRepository {
  Future<int> insert(UserModel user);
  Future<UserModel?> query(int id);
  Future<List<UserModel>> queryAll();
  Future<int> delete(UserModel user);
  Future<int> update(UserModel user);
  Future<List<String>> getImagesList();
}
