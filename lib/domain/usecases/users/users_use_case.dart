import '/core/result/result.dart';
import '/data/repositories/users/user_repository.dart';
import '/data/services/images/image_compression_service.dart';
import '/data/services/images/image_selection_service.dart';
import '/data/services/images/user_image_storage_service.dart';
import '/domain/common/user/models/user.dart';
import '/domain/models/image_preparation.dart';
import '/domain/models/image_selection.dart';
import '/domain/models/prepared_user_image.dart';
import '/domain/models/stored_user_image.dart';

class UsersUseCase {
  final UserRepository _repository;
  final ImageSelectionService _imageSelection;
  final ImageCompressionService _imageCompression;
  final UserImageStorageService _imageStorage;

  UsersUseCase({
    required UserRepository repository,
    required ImageSelectionService imageSelection,
    required ImageCompressionService imageCompression,
    required UserImageStorageService imageStorage,
  })  : _repository = repository,
        _imageSelection = imageSelection,
        _imageCompression = imageCompression,
        _imageStorage = imageStorage;

  List<User> get users => _repository.users;

  AsyncResult<List<User>> loadAll() => _repository.loadAll();

  AsyncResult<List<String>> readPhotoReferences() =>
      _repository.readPhotoReferences();

  AsyncResult<ImagePreparation> prepareImage() async {
    final selection = await _imageSelection.select();
    if (selection.isFailure) return Failure(selection.error!);

    final selected = selection.value!;
    if (selected is ImageSelectionCanceled) {
      return const Success(ImagePreparationCanceled());
    }
    return _prepareSelectedImage(selected as ImageSelected);
  }

  AsyncResult<Unit> discardPreparedImage(PreparedUserImage image) =>
      _imageStorage.remove(image.temporaryReference);

  /// Inserts a new user into the repository. If a [preparedImage] is
  /// provided, it will be promoted to a stored image and associated
  /// with the user. If the insertion fails after promoting the image,
  /// the image will be rolled back (removed) to maintain consistency.
  AsyncResult<User> insert({
    required User user,
    PreparedUserImage? preparedImage,
  }) async {
    if (preparedImage == null) return _repository.insert(user);

    final promotion = await _imageStorage.promote(preparedImage);
    if (promotion.isFailure) return Failure(promotion.error!);

    final storedImage = promotion.value!;
    final insertion = await _repository.insert(
      _withPhoto(user, storedImage.reference),
    );
    if (insertion.isSuccess) return insertion;

    return _rollbackUserFailure<User>(
      storedImage: storedImage,
      primaryError: insertion.error!,
    );
  }

  /// Updates an existing user in the repository. If a [preparedImage] is
  /// provided, it will be promoted to a stored image and associated with the user.
  /// If the update fails after promoting the image, the image will be rolled back
  /// (removed) to maintain consistency. After a successful update, unused images
  /// will be cleaned up from the storage.
  AsyncResult<Unit> update({
    required User user,
    PreparedUserImage? preparedImage,
  }) async {
    if (preparedImage == null) return _repository.update(user);

    final promotion = await _imageStorage.promote(preparedImage);
    if (promotion.isFailure) return Failure(promotion.error!);

    final storedImage = promotion.value!;
    final update = await _repository.update(
      _withPhoto(user, storedImage.reference),
    );
    if (update.isFailure) {
      return _rollbackUserFailure<Unit>(
        storedImage: storedImage,
        primaryError: update.error!,
      );
    }

    return _cleanUnusedImages();
  }

  /// Deletes an existing user from the repository. If the user has an associated
  /// image, it will be removed from the storage after the user is deleted.
  AsyncResult<Unit> delete(User user) async {
    final id = user.id;
    if (id == null) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'A persisted user id is required for deletion.',
        ),
      );
    }

    final deletion = await _repository.delete(id);
    if (deletion.isFailure) return deletion;
    return _cleanUnusedImages();
  }

  /// Rolls back a failed user operation by removing the associated stored image.
  Future<Result<T>> _rollbackUserFailure<T extends Object>({
    required StoredUserImage storedImage,
    required AppError primaryError,
  }) async {
    final rollback = await _imageStorage.remove(storedImage.reference);
    if (rollback.isSuccess) return Failure(primaryError);

    return Failure(
      AppError(
        code: rollback.error!.code,
        message:
            'The user operation failed and its new image could not be removed.',
        details: (
          primaryError: primaryError,
          compensationError: rollback.error!,
          imageReference: storedImage.reference,
        ),
      ),
    );
  }

  /// Cleans up unused images from the storage by comparing the current photo
  /// references against the stored images.
  AsyncResult<Unit> _cleanUnusedImages() async {
    final references = await _repository.readPhotoReferences();
    if (references.isFailure) return Failure(references.error!);
    return _imageStorage.cleanUnused(references.value!.toSet());
  }

  AsyncResult<ImagePreparation> _prepareSelectedImage(
    ImageSelected image,
  ) async {
    final compression = await _imageCompression.compress(image);
    if (compression.isFailure) return Failure(compression.error!);
    return Success(ImagePrepared(compression.value!));
  }

  /// Creates a new [User] instance with the provided photo reference.
  User _withPhoto(User user, String photoReference) => User(
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        photoReference: photoReference,
      );
}
