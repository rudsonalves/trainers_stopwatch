import 'prepared_user_image.dart';

sealed class ImagePreparation {
  const ImagePreparation();
}

final class ImagePreparationCanceled extends ImagePreparation {
  const ImagePreparationCanceled();
}

final class ImagePrepared extends ImagePreparation {
  final PreparedUserImage image;

  const ImagePrepared(this.image);
}
