import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/bootstrap/bootstrap.dart';
import 'package:trainers_stopwatch/core/config/dependencies.dart';
import 'package:trainers_stopwatch/store/database/database_provider.dart';

void main() {
  test('setupDependencies is idempotent and resolves the bootstrap graph', () {
    setupDependencies();
    final firstProvider = injector.get<DatabaseProvider>();

    setupDependencies();
    final bootstrap = injector.get<Bootstrap>();

    expect(firstProvider, isA<DatabaseProvider>());
    expect(bootstrap, isA<Bootstrap>());
  });
}
