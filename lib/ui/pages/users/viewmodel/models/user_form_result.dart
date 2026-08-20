import '/domain/common/user/models/user.dart';
import '/domain/models/prepared_user_image.dart';

class UserFormResult {
  final User user;
  final PreparedUserImage? preparedImage;

  const UserFormResult({
    required this.user,
    required this.preparedImage,
  });
}
