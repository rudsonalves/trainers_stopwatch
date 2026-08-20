import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/data/services/database/table_sql_scripts.dart';

void main() {
  String normalized(String sql) => sql.replaceAll(RegExp(r'\s+'), ' ').trim();

  test('training belongs to a user with delete cascade', () {
    final sql = normalized(createTrainingTableSQL);

    expect(
      sql,
      contains(
        'FOREIGN KEY (userId) REFERENCES userTable (id) ON DELETE CASCADE',
      ),
    );
  });

  test('history belongs to a training with delete cascade', () {
    final sql = normalized(createHistoryTableSQL);

    expect(
      sql,
      contains(
        'FOREIGN KEY (trainingId) REFERENCES trainingTable (id) '
        'ON DELETE CASCADE',
      ),
    );
  });
}
