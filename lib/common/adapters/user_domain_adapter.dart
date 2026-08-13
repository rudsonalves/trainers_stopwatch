import '../../domain/common/user/models/user.dart';
import '../models/user_model.dart';

// Temporary legacy bridge. Remove with the user migration in backlog 005.
extension UserModelDomainAdapter on UserModel {
  User toDomain() => User(
        id: id,
        name: name,
        email: email,
        phone: phone,
        photoReference: photo,
      );
}

extension UserLegacyAdapter on User {
  UserModel toLegacy() => UserModel(
        id: id,
        name: name,
        email: email,
        phone: phone,
        photo: photoReference,
      );
}
