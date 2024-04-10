import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trainers_stopwatch/store/constants/table_sql_scripts.dart';
import 'package:trainers_stopwatch/store/database_create_tables.dart';

class MockBatch extends Mock implements Batch {}

void main() {
  group('DatabaseCreateTable', () {
    test('should execute athlete table creation SQL', () {
      final mockBatch = MockBatch();
      DatabaseCreateTable.athleteTable(mockBatch);

      verify(mockBatch.execute(createAthleteTableSQL)).called(1);
      verify(mockBatch.execute(createAthleteNameIndexSQL)).called(1);
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
