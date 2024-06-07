import '../../common/models/user_model.dart';
import '../../store/stores/user_store.dart';
import 'abstract_user_repository.dart';

class UserRepository implements AbstractUserRepository {
  final _store = UserStore();

  @override
  Future<int> insert(UserModel user) async {
    final id = await _store.insert(user.toMap());
    user.id = id;

    return id;
  }

  @override
  Future<UserModel?> query(int id) async {
    final map = await _store.query(id);
    if (map == null) return null;
    final user = UserModel.fromMap(map);
    return user;
  }

  @override
  Future<List<UserModel>> queryAll() async {
    final mapList = await _store.queryAll();
    if (mapList.isEmpty) return [];
    final userList = mapList.map((map) => UserModel.fromMap(map!)).toList();
    return userList;
  }

  @override
  Future<int> delete(UserModel user) async {
    final result = await _store.delete(user.id!);
    return result;
  }

  @override
  Future<int> update(UserModel user) async {
    final result = await _store.update(user.id!, user.toMap());
    return result;
  }
}
