import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/domain/common/user/models/user.dart';
import 'package:trainers_stopwatch/domain/models/prepared_user_image.dart';
import 'package:trainers_stopwatch/features/users_page/widgets/user_dialog/user_controller.dart';

void main() {
  test('keeps persisted image separate from a prepared preview', () {
    const persisted = User(
      id: 1,
      name: 'Ana',
      email: 'ana@example.com',
      phone: '123',
      photoReference: '/stored/old.jpg',
    );
    const prepared = PreparedUserImage(
      temporaryReference: '/temporary/new.jpg',
      fileName: 'new.jpg',
    );
    final controller = UserController()..init(persisted);
    addTearDown(controller.dispose);

    final previous = controller.setPreparedImage(prepared);
    final result = controller.buildResult();

    expect(previous, isNull);
    expect(controller.image.value, prepared.temporaryReference);
    expect(result.user.photoReference, persisted.photoReference);
    expect(result.preparedImage, prepared);
  });

  test('returns the previous temporary image when preview is replaced', () {
    const first = PreparedUserImage(
      temporaryReference: '/temporary/first.jpg',
      fileName: 'first.jpg',
    );
    const second = PreparedUserImage(
      temporaryReference: '/temporary/second.jpg',
      fileName: 'second.jpg',
    );
    final controller = UserController();
    addTearDown(controller.dispose);

    controller.setPreparedImage(first);
    final replaced = controller.setPreparedImage(second);

    expect(replaced, first);
    expect(controller.preparedImage, second);
  });
}
