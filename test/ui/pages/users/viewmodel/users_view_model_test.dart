import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/repositories/users/user_repository.dart';
import 'package:trainers_stopwatch/data/services/images/image_compression_service.dart';
import 'package:trainers_stopwatch/data/services/images/image_selection_service.dart';
import 'package:trainers_stopwatch/data/services/images/user_image_storage_service.dart';
import 'package:trainers_stopwatch/domain/common/user/models/user.dart';
import 'package:trainers_stopwatch/domain/models/image_selection.dart';
import 'package:trainers_stopwatch/domain/models/prepared_user_image.dart';
import 'package:trainers_stopwatch/domain/models/stored_user_image.dart';
import 'package:trainers_stopwatch/domain/usecases/users/users_use_case.dart';
import 'package:trainers_stopwatch/ui/pages/users/viewmodel/users_view_model.dart';

void main() {
  late _UserRepositoryFake repository;
  late UsersViewModel viewModel;

  setUp(() {
    repository = _UserRepositoryFake();
    viewModel = UsersViewModel(
      useCase: UsersUseCase(
        repository: repository,
        imageSelection: _ImageSelectionFake(),
        imageCompression: _ImageCompressionFake(),
        imageStorage: _ImageStorageFake(),
      ),
      initiallySelectedUserIds: const [1],
    );
  });

  tearDown(() => viewModel.dispose());

  test('loads users from the use case cache and exposes command state',
      () async {
    final blocker = Completer<void>();
    repository.loadBlocker = blocker;

    final loading = viewModel.load();
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.isLoading, isTrue);
    expect(viewModel.loadCommand.isRunning, isTrue);

    blocker.complete();
    await loading;

    expect(viewModel.loadCommand.isSuccess, isTrue);
    expect(viewModel.users, same(repository.users));
    expect(viewModel.users.single.name, 'Ana');
  });

  test('initializes selection and exposes immutable ids and users', () async {
    await viewModel.load();

    expect(viewModel.selectedUserIds, {1});
    expect(viewModel.selectedUsers, [repository.users.single]);
    expect(
      () => viewModel.selectedUserIds.add(2),
      throwsUnsupportedError,
    );
    expect(
      () => viewModel.selectedUsers.add(repository.users.single),
      throwsUnsupportedError,
    );
  });

  test('selects and deselects persisted users', () async {
    await viewModel.load();
    final user = repository.users.single;

    viewModel.setSelected(user, selected: false);
    expect(viewModel.isSelected(user), isFalse);

    viewModel.setSelected(user, selected: true);
    expect(viewModel.isSelected(user), isTrue);
  });

  test('ignores selection for a user without persisted id', () {
    const user = User(name: 'Draft', email: 'draft@example.com');

    viewModel.setSelected(user, selected: true);

    expect(viewModel.isSelected(user), isFalse);
    expect(viewModel.selectedUserIds, {1});
  });

  test('add, edit and delete commands reflect mutations from use case',
      () async {
    await viewModel.load();
    await viewModel.add(
      user: const User(name: 'Bia', email: 'bia@example.com'),
    );
    final added = viewModel.addCommand.value!;
    final edited = User(
      id: added.id,
      name: 'Beatriz',
      email: added.email,
    );

    await viewModel.edit(user: edited);
    await viewModel.delete(edited);

    expect(viewModel.addCommand.isSuccess, isTrue);
    expect(viewModel.editCommand.isSuccess, isTrue);
    expect(viewModel.deleteCommand.isSuccess, isTrue);
    expect(viewModel.users.map((user) => user.name), ['Ana']);
  });

  test('blocks deletion of a selected user before reaching use case', () async {
    await viewModel.load();

    await viewModel.delete(repository.users.single);

    expect(viewModel.deleteCommand.isFailure, isTrue);
    expect(viewModel.lastError!.code, AppErrorCode.invalidData);
    expect(repository.deleteCalls, 0);
  });

  test('exposes the latest AppError and clears it on a later success',
      () async {
    repository.loadError = const AppError(
      code: AppErrorCode.storageReadFailed,
      message: 'load failed',
    );

    await viewModel.load();

    expect(viewModel.lastError, repository.loadError);
    repository.loadError = null;
    await viewModel.load();
    expect(viewModel.lastError, isNull);
  });

  test('preserves loaded cache when a later reload fails', () async {
    await viewModel.load();
    final cached = viewModel.users;
    repository.loadError = const AppError(
      code: AppErrorCode.storageReadFailed,
      message: 'reload failed',
    );

    await viewModel.load();

    expect(viewModel.loadCommand.isFailure, isTrue);
    expect(viewModel.users, same(cached));
    expect(viewModel.users.single.name, 'Ana');
  });

  test('can explicitly clear the last error', () async {
    repository.loadError = const AppError(
      code: AppErrorCode.storageReadFailed,
      message: 'load failed',
    );
    await viewModel.load();

    viewModel.clearLastError();

    expect(viewModel.lastError, isNull);
  });
}

final class _UserRepositoryFake implements UserRepository {
  List<User> _users = const [];
  Completer<void>? loadBlocker;
  AppError? loadError;
  int deleteCalls = 0;

  @override
  List<User> get users => _users;

  @override
  AsyncResult<List<User>> loadAll() async {
    final blocker = loadBlocker;
    loadBlocker = null;
    if (blocker != null) await blocker.future;
    final error = loadError;
    if (error != null) return Failure(error);
    _users = const [User(id: 1, name: 'Ana', email: 'ana@example.com')];
    return Success(_users);
  }

  @override
  AsyncResult<User> insert(User user) async {
    final persisted = User(
      id: 2,
      name: user.name,
      email: user.email,
      phone: user.phone,
      photoReference: user.photoReference,
    );
    _users = List.unmodifiable([..._users, persisted]);
    return Success(persisted);
  }

  @override
  AsyncResult<Unit> update(User user) async {
    _users = List.unmodifiable(
      _users.map((cached) => cached.id == user.id ? user : cached),
    );
    return const Success(unit);
  }

  @override
  AsyncResult<Unit> delete(int id) async {
    deleteCalls++;
    _users = List.unmodifiable(_users.where((user) => user.id != id));
    return const Success(unit);
  }

  @override
  AsyncResult<List<String>> readPhotoReferences() async => const Success([]);
}

final class _ImageStorageFake implements UserImageStorageService {
  @override
  AsyncResult<StoredUserImage> promote(PreparedUserImage image) async =>
      const Success(StoredUserImage(reference: '/stored/image.jpg'));

  @override
  AsyncResult<Unit> remove(String reference) async => const Success(unit);

  @override
  AsyncResult<Unit> cleanUnused(Set<String> referencedImages) async =>
      const Success(unit);
}

final class _ImageSelectionFake implements ImageSelectionService {
  @override
  AsyncResult<ImageSelection> select() async =>
      const Success(ImageSelectionCanceled());
}

final class _ImageCompressionFake implements ImageCompressionService {
  @override
  AsyncResult<PreparedUserImage> compress(ImageSelected image) async =>
      const Success(
        PreparedUserImage(
          temporaryReference: '/temporary/image.jpg',
          fileName: 'image.jpg',
        ),
      );
}
