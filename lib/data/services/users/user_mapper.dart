import '/core/result/result.dart';
import '/domain/common/user/models/user.dart';
import '../database/table_attributes.dart';

class UserMapper {
  const UserMapper();

  Result<User> fromMap(Map<String, Object?> map) {
    try {
      return Success(
        User(
          id: map[userId] as int?,
          name: map[userName] as String,
          email: map[userEmail] as String,
          phone: map[userPhone] as String?,
          photoReference: map[userPhoto] as String?,
        ),
      );
    } catch (error, stackTrace) {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Invalid persisted user data.',
          details: (error: error, stackTrace: stackTrace, data: map),
        ),
      );
    }
  }

  Map<String, Object?> toMap(User user) => <String, Object?>{
        if (user.id != null) userId: user.id,
        userName: user.name,
        userEmail: user.email,
        userPhone: user.phone,
        userPhoto: user.photoReference,
      };
}
