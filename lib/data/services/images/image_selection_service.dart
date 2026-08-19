import '/core/result/result.dart';
import 'models/image_selection.dart';

abstract interface class ImageSelectionService {
  AsyncResult<ImageSelection> select();
}
