import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '/core/result/result.dart';
import '/domain/models/image_selection.dart';
import 'image_selection_service.dart';

typedef PickImage = Future<XFile?> Function();

final class ImageSelectionServiceImpl implements ImageSelectionService {
  final PickImage _pickImage;

  ImageSelectionServiceImpl({required PickImage pickImage})
      : _pickImage = pickImage;

  factory ImageSelectionServiceImpl.gallery({ImagePicker? picker}) {
    final imagePicker = picker ?? ImagePicker();
    return ImageSelectionServiceImpl(
      pickImage: () => imagePicker.pickImage(source: ImageSource.gallery),
    );
  }

  factory ImageSelectionServiceImpl.camera({ImagePicker? picker}) {
    final imagePicker = picker ?? ImagePicker();
    return ImageSelectionServiceImpl(
      pickImage: () => imagePicker.pickImage(source: ImageSource.camera),
    );
  }

  @override
  AsyncResult<ImageSelection> select() async {
    try {
      final image = await _pickImage();
      if (image == null) return const Success(ImageSelectionCanceled());

      final fileName =
          image.name.isEmpty ? path.basename(image.path) : image.name;
      if (image.path.isEmpty || fileName.isEmpty) {
        return const Failure(
          AppError(
            code: AppErrorCode.invalidData,
            message: 'The selected image has no usable reference.',
          ),
        );
      }

      return Success(
        ImageSelected(sourceReference: image.path, fileName: fileName),
      );
    } catch (error, stackTrace) {
      return Failure(
        AppError(
          code: AppErrorCode.imageSelectionFailed,
          message: 'Could not select an image.',
          details: (error: error, stackTrace: stackTrace),
        ),
      );
    }
  }
}
