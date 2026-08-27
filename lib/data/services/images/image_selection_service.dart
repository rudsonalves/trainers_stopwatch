import '/core/result/result.dart';
import '/domain/models/image_selection.dart';

abstract interface class ImageSelectionService {
  AsyncResult<ImageSelection> select();
}
