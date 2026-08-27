import '/core/result/result.dart';
import '/domain/models/image_selection.dart';
import '/domain/models/prepared_user_image.dart';

abstract interface class ImageCompressionService {
  /// Compresses the selected image to a prepared image.
  ///
  /// The [image] must be a selected image that is ready to be compressed. The
  /// method will compress the image and return a [PreparedUserImage] that contains
  /// the reference to the compressed image. If an error occurs during the compression
  /// process, the method will return a failure with an appropriate error code.
  AsyncResult<PreparedUserImage> compress(ImageSelected image);
}
