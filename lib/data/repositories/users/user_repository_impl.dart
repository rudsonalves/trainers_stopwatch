import '/core/result/result.dart';
import '/data/services/users/user_service.dart';
import '/domain/common/user/models/user.dart';
import 'user_repository.dart';

final class UserRepositoryImpl implements UserRepository {
  final UserService _service;
  List<User> _users = const [];

  UserRepositoryImpl({required UserService service}) : _service = service;

  @override
  List<User> get users => _users;

  @override
  AsyncResult<List<User>> loadAll() async {
    final result = await _service.readAll();
    if (result.isFailure) return Failure(result.error!);
    _users = List.unmodifiable(result.value!);
    return Success(_users);
  }

  @override
  AsyncResult<User> insert(User user) async {
    final result = await _service.insert(user);
    if (result.isFailure) return Failure(result.error!);
    _users = List.unmodifiable([..._users, result.value!]);
    return result;
  }

  @override
  AsyncResult<Unit> update(User user) async {
    final id = user.id;
    if (id == null) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'A persisted user id is required to update the cache.',
        ),
      );
    }
    final result = await _service.update(user);
    if (result.isFailure) return Failure(result.error!);
    _users = List.unmodifiable(
      _users.map((cached) => cached.id == id ? user : cached),
    );
    return const Success(unit);
  }

  @override
  AsyncResult<Unit> delete(int id) async {
    final result = await _service.delete(id);
    if (result.isFailure) return Failure(result.error!);
    _users = List.unmodifiable(_users.where((user) => user.id != id));
    return const Success(unit);
  }

  @override
  AsyncResult<List<String>> readPhotoReferences() =>
      _service.readPhotoReferences();
}
