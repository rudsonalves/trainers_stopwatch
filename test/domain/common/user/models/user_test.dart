import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/domain/common/user/models/user.dart';

void main() {
  test('represents a user not persisted yet', () {
    const user = User(name: 'Ana', email: 'ana@example.com');

    expect(user.id, isNull);
    expect(user.name, 'Ana');
    expect(user.email, 'ana@example.com');
  });

  test('has value equality', () {
    const first = User(
      id: 1,
      name: 'Ana',
      email: 'ana@example.com',
      phone: '123',
      photoReference: 'ana.png',
    );
    const second = User(
      id: 1,
      name: 'Ana',
      email: 'ana@example.com',
      phone: '123',
      photoReference: 'ana.png',
    );

    expect(first, second);
    expect(first.hashCode, second.hashCode);
  });
}
