import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trainers_stopwatch/store/constants/table_sql_scripts.dart';
import 'package:trainers_stopwatch/store/database/database_create_tables.dart';

class MockBatch extends Mock implements Batch {}

void main() {
  group('DatabaseCreateTable', () {
    test('should execute user table creation SQL', () {
      final mockBatch = MockBatch();
      DatabaseCreateTable.userTable(mockBatch);

      verify(mockBatch.execute(createUserTableSQL)).called(1);
      verify(mockBatch.execute(createUserNameIndexSQL)).called(1);
    });

    test('should execute training table creation SQL', () {
      final mockBatch = MockBatch();
      DatabaseCreateTable.trainingTable(mockBatch);

      verify(mockBatch.execute(createTrainingTableSQL)).called(1);
      verify(mockBatch.execute(createTrainingDateIndexSQL)).called(1);
    });

    test('should execute history table creation SQL', () {
      final mockBatch = MockBatch();
      DatabaseCreateTable.historyTable(mockBatch);

      verify(mockBatch.execute(createHistoryTableSQL)).called(1);
      verify(mockBatch.execute(createHistoryTrainingIndexSQL)).called(1);
    });
  });
}
