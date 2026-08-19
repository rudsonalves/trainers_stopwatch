import '/common/adapters/user_domain_adapter.dart';
import '/common/models/user_model.dart';
import '/data/repositories/users/user_repository.dart';

// Temporary adapter for the legacy trainings flow. Remove in backlog 006.
final class UserManager {
  final UserRepository _repository;
  bool _started = false;

  UserManager({required UserRepository repository}) : _repository = repository;

  List<UserModel> get users =>
      _repository.users.map((user) => user.toLegacy()).toList(growable: false);

  Future<void> init() async {
    if (_started) return;
    await getAllUsers();
    _started = true;
  }

  Future<void> getAllUsers() async {
    final result = await _repository.loadAll();
    if (result.isFailure) throw result.error!;
  }

  Future<void> insert(UserModel user) async {
    final result = await _repository.insert(user.toDomain());
    if (result.isFailure) throw result.error!;
    user.id = result.value!.id;
  }

  Future<void> update(UserModel user) async {
    final result = await _repository.update(user.toDomain());
    if (result.isFailure) throw result.error!;
  }

  Future<void> delete(UserModel user) async {
    final result = await _repository.delete(user.id!);
    if (result.isFailure) throw result.error!;
  }

  int findIndex(int id) => users.indexWhere((user) => user.id == id);

  Future<List<String>> getImagesList() async {
    final result = await _repository.readPhotoReferences();
    if (result.isFailure) throw result.error!;
    return result.value!;
  }
}
