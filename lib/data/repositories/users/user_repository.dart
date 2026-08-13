import '/core/result/result.dart';
import '/domain/common/user/models/user.dart';

abstract interface class UserRepository {
  List<User> get users;

  AsyncResult<List<User>> loadAll();
  AsyncResult<User> insert(User user);
  AsyncResult<Unit> update(User user);
  AsyncResult<Unit> delete(int id);
  AsyncResult<List<String>> readPhotoReferences();
}
