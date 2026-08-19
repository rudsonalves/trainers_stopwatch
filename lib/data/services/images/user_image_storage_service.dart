import '/core/result/result.dart';
import 'models/prepared_user_image.dart';
import 'models/stored_user_image.dart';

abstract interface class UserImageStorageService {
  /// Promotes a prepared image to a stored image.
  ///
  /// The [image] must be a prepared image that is ready to be stored. The
  /// method will copy the image to a permanent location and return a
  /// [StoredUserImage] that contains the reference to the stored image.
  AsyncResult<StoredUserImage> promote(PreparedUserImage image);

  /// Removes a stored image from the storage.
  ///
  /// The [reference] must be a valid reference to a stored image. The method
  /// will delete the image from the storage and return a [Unit] to indicate
  /// that the operation was successful. If the image does not exist, the method
  /// will return a failure with an appropriate error code.
  AsyncResult<Unit> remove(String reference);

  /// Cleans up unused images from the storage.
  ///
  /// The [referencedImages] must be a set of valid references to stored images
  /// that are currently in use. The method will delete any stored images that are
  /// not referenced in the set and return a [Unit] to indicate that the operation
  /// was successful. If any of the images do not exist, the method will ignore them
  /// and continue with the cleanup process. If an error occurs during the cleanup,
  /// the method will return a failure with an appropriate error code.
  AsyncResult<Unit> cleanUnused(Set<String> referencedImages);
}
