import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/repositories/users/user_repository.dart';
import 'package:trainers_stopwatch/data/services/images/image_compression_service.dart';
import 'package:trainers_stopwatch/data/services/images/image_selection_service.dart';
import 'package:trainers_stopwatch/data/services/images/user_image_storage_service.dart';
import 'package:trainers_stopwatch/data/services/images/user_image_storage_service_impl.dart';
import 'package:trainers_stopwatch/domain/common/user/models/user.dart';
import 'package:trainers_stopwatch/domain/models/image_preparation.dart';
import 'package:trainers_stopwatch/domain/models/image_selection.dart';
import 'package:trainers_stopwatch/domain/models/prepared_user_image.dart';
import 'package:trainers_stopwatch/domain/models/stored_user_image.dart';
import 'package:trainers_stopwatch/domain/usecases/users/users_use_case.dart';

const _preparedImage = PreparedUserImage(
  temporaryReference: '/temporary/new.jpg',
  fileName: 'new.jpg',
);
const _storedReference = '/stored/new.jpg';
const _writeError = AppError(
  code: AppErrorCode.storageWriteFailed,
  message: 'database write failed',
);

UsersUseCase _useCase(
  UserRepository repository,
  UserImageStorageService storage,
) =>
    UsersUseCase(
      repository: repository,
      imageSelection: _ImageSelectionFake(),
      imageCompression: _ImageCompressionFake(),
      imageStorage: storage,
    );

void main() {
  test('selects and compresses an image as a single preparation operation',
      () async {
    const selected = ImageSelected(
      sourceReference: '/camera/source.jpg',
      fileName: 'source.jpg',
    );
    final compression = _ImageCompressionFake();
    final useCase = UsersUseCase(
      repository: _UserRepositoryFake(),
      imageSelection: _ImageSelectionFake(selection: selected),
      imageCompression: compression,
      imageStorage: _ImageStorageFake(),
    );

    final result = await useCase.prepareImage();

    expect(result.isSuccess, isTrue);
    expect(compression.received, selected);
    expect(result.value, isA<ImagePrepared>());
  });

  test('does not compress when image selection is canceled', () async {
    final compression = _ImageCompressionFake();
    final useCase = UsersUseCase(
      repository: _UserRepositoryFake(),
      imageSelection: _ImageSelectionFake(),
      imageCompression: compression,
      imageStorage: _ImageStorageFake(),
    );

    final result = await useCase.prepareImage();

    expect(result.value, isA<ImagePreparationCanceled>());
    expect(compression.received, isNull);
  });

  test('inserts a user after promoting its prepared image', () async {
    final repository = _UserRepositoryFake();
    final storage = _ImageStorageFake();
    final useCase = _useCase(repository, storage);

    final result = await useCase.insert(
      user: const User(name: 'Ana', email: 'ana@example.com'),
      preparedImage: _preparedImage,
    );

    expect(result.isSuccess, isTrue);
    expect(result.value!.photoReference, _storedReference);
    expect(repository.inserted!.photoReference, _storedReference);
    expect(storage.events, ['promote']);
  });

  test('removes promoted image when insertion fails', () async {
    final repository = _UserRepositoryFake()..insertError = _writeError;
    final storage = _ImageStorageFake();
    final useCase = _useCase(repository, storage);

    final result = await useCase.insert(
      user: const User(name: 'Ana', email: 'ana@example.com'),
      preparedImage: _preparedImage,
    );

    expect(result.error, _writeError);
    expect(storage.events, ['promote', 'remove:$_storedReference']);
  });

  test('does not reach repository when image promotion fails', () async {
    final repository = _UserRepositoryFake();
    final storage = _ImageStorageFake()..failPromotion = true;
    final useCase = _useCase(repository, storage);

    final result = await useCase.insert(
      user: const User(name: 'Ana', email: 'ana@example.com'),
      preparedImage: _preparedImage,
    );

    expect(result.error!.code, AppErrorCode.imageStorageWriteFailed);
    expect(repository.inserted, isNull);
    expect(repository.users, hasLength(1));
  });

  test('reports compensation error with the database error in details',
      () async {
    final repository = _UserRepositoryFake()..insertError = _writeError;
    final storage = _ImageStorageFake()..failRemove = true;
    final useCase = _useCase(repository, storage);

    final result = await useCase.insert(
      user: const User(name: 'Ana', email: 'ana@example.com'),
      preparedImage: _preparedImage,
    );

    expect(result.error!.code, AppErrorCode.imageStorageDeleteFailed);
    expect(result.error!.details.toString(), contains('storageWriteFailed'));
  });

  test('preserves old reference and removes new image when update fails',
      () async {
    final repository = _UserRepositoryFake()..updateError = _writeError;
    final storage = _ImageStorageFake();
    final useCase = _useCase(repository, storage);
    const original = User(
      id: 1,
      name: 'Ana',
      email: 'ana@example.com',
      photoReference: '/stored/old.jpg',
    );

    final result = await useCase.update(
      user: original,
      preparedImage: _preparedImage,
    );

    expect(result.error, _writeError);
    expect(repository.users.single, original);
    expect(repository.updated!.photoReference, _storedReference);
    expect(storage.events, ['promote', 'remove:$_storedReference']);
  });

  test('cleans only after a successful update', () async {
    final repository = _UserRepositoryFake()
      ..photoReferences = const [_storedReference];
    final storage = _ImageStorageFake();
    final useCase = _useCase(repository, storage);

    final result = await useCase.update(
      user: const User(
        id: 1,
        name: 'Ana',
        email: 'ana@example.com',
        photoReference: '/stored/old.jpg',
      ),
      preparedImage: _preparedImage,
    );

    expect(result.isSuccess, isTrue);
    expect(storage.events, ['promote', 'clean:$_storedReference']);
  });

  test('successful update removes old file and keeps new referenced file',
      () async {
    final directory = await Directory.systemTemp.createTemp('usecase-images-');
    addTearDown(() => directory.delete(recursive: true));
    final imageDirectory = Directory('${directory.path}/users_images');
    await imageDirectory.create();
    final oldImage = File('${imageDirectory.path}/old.jpg');
    final temporaryImage = File('${directory.path}/prepared.jpg');
    await oldImage.writeAsString('old');
    await temporaryImage.writeAsString('new');
    final repository = _UserRepositoryFake(
      initialUsers: [
        User(
          id: 1,
          name: 'Ana',
          email: 'ana@example.com',
          photoReference: oldImage.path,
        ),
      ],
    );
    final storage = UserImageStorageServiceImpl(
      documentsDirectoryProvider: () async => directory,
      clock: () => DateTime.fromMicrosecondsSinceEpoch(321),
    );
    final useCase = _useCase(repository, storage);

    final result = await useCase.update(
      user: repository.users.single,
      preparedImage: PreparedUserImage(
        temporaryReference: temporaryImage.path,
        fileName: 'new.jpg',
      ),
    );

    final newReference = repository.users.single.photoReference!;
    expect(result.isSuccess, isTrue);
    expect(await oldImage.exists(), isFalse);
    expect(newReference, endsWith('321-new.jpg'));
    expect(await File(newReference).readAsString(), 'new');
  });

  test('deletes from repository before cleaning unreferenced images', () async {
    final events = <String>[];
    final repository = _UserRepositoryFake(externalEvents: events)
      ..photoReferences = const [];
    final storage = _ImageStorageFake(externalEvents: events);
    final useCase = _useCase(repository, storage);

    final result = await useCase.delete(
      const User(
        id: 1,
        name: 'Ana',
        email: 'ana@example.com',
        photoReference: '/stored/old.jpg',
      ),
    );

    expect(result.isSuccess, isTrue);
    expect(events, ['delete:1', 'readReferences', 'clean:']);
  });

  test('does not clean images when deletion fails', () async {
    final repository = _UserRepositoryFake()..deleteError = _writeError;
    final storage = _ImageStorageFake();
    final useCase = _useCase(repository, storage);

    final result = await useCase.delete(
      const User(id: 1, name: 'Ana', email: 'ana@example.com'),
    );

    expect(result.error, _writeError);
    expect(storage.events, isEmpty);
  });
}

class _UserRepositoryFake implements UserRepository {
  final List<String>? externalEvents;
  List<User> _users = const [
    User(
      id: 1,
      name: 'Ana',
      email: 'ana@example.com',
      photoReference: '/stored/old.jpg',
    ),
  ];
  List<String> photoReferences = const [];
  AppError? insertError;
  AppError? updateError;
  AppError? deleteError;
  User? inserted;
  User? updated;

  _UserRepositoryFake({
    this.externalEvents,
    List<User>? initialUsers,
  }) {
    if (initialUsers != null) _users = List.of(initialUsers);
  }

  @override
  List<User> get users => _users;

  @override
  AsyncResult<List<User>> loadAll() async => Success(_users);

  @override
  AsyncResult<User> insert(User user) async {
    inserted = user;
    if (insertError case final error?) return Failure(error);
    final persisted = User(
      id: 2,
      name: user.name,
      email: user.email,
      phone: user.phone,
      photoReference: user.photoReference,
    );
    _users = [..._users, persisted];
    return Success(persisted);
  }

  @override
  AsyncResult<Unit> update(User user) async {
    updated = user;
    if (updateError case final error?) return Failure(error);
    _users = _users.map((item) => item.id == user.id ? user : item).toList();
    return const Success(unit);
  }

  @override
  AsyncResult<Unit> delete(int id) async {
    externalEvents?.add('delete:$id');
    if (deleteError case final error?) return Failure(error);
    _users = _users.where((user) => user.id != id).toList();
    return const Success(unit);
  }

  @override
  AsyncResult<List<String>> readPhotoReferences() async {
    externalEvents?.add('readReferences');
    return Success(
      photoReferences.isNotEmpty
          ? photoReferences
          : _users
              .map((user) => user.photoReference)
              .nonNulls
              .toList(growable: false),
    );
  }
}

class _ImageSelectionFake implements ImageSelectionService {
  final ImageSelection selection;

  _ImageSelectionFake({
    this.selection = const ImageSelectionCanceled(),
  });

  @override
  AsyncResult<ImageSelection> select() async => Success(selection);
}

class _ImageCompressionFake implements ImageCompressionService {
  ImageSelected? received;

  @override
  AsyncResult<PreparedUserImage> compress(ImageSelected image) async {
    received = image;
    return const Success(_preparedImage);
  }
}

class _ImageStorageFake implements UserImageStorageService {
  final List<String> events = [];
  final List<String>? externalEvents;
  bool failPromotion = false;
  bool failRemove = false;

  _ImageStorageFake({this.externalEvents});

  void _record(String event) {
    events.add(event);
    externalEvents?.add(event);
  }

  @override
  AsyncResult<StoredUserImage> promote(PreparedUserImage image) async {
    _record('promote');
    if (failPromotion) {
      return const Failure(
        AppError(
          code: AppErrorCode.imageStorageWriteFailed,
          message: 'promotion failed',
        ),
      );
    }
    return const Success(StoredUserImage(reference: _storedReference));
  }

  @override
  AsyncResult<Unit> remove(String reference) async {
    _record('remove:$reference');
    if (failRemove) {
      return const Failure(
        AppError(
          code: AppErrorCode.imageStorageDeleteFailed,
          message: 'remove failed',
        ),
      );
    }
    return const Success(unit);
  }

  @override
  AsyncResult<Unit> cleanUnused(Set<String> referencedImages) async {
    final references = referencedImages.toList()..sort();
    _record('clean:${references.join(',')}');
    return const Success(unit);
  }
}
