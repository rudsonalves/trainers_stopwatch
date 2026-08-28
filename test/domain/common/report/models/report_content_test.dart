import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/errors/app_error.dart';
import 'package:trainers_stopwatch/domain/common/report/models/training_report_build_outcome.dart';
import 'package:trainers_stopwatch/domain/common/report/models/training_report_content.dart';
import 'package:trainers_stopwatch/domain/common/report/models/training_report_issue.dart';
import 'package:trainers_stopwatch/domain/common/report/models/training_report_row.dart';
import 'package:trainers_stopwatch/domain/common/report/models/training_report_section.dart';
import 'package:trainers_stopwatch/domain/common/report/models/training_report_totals.dart';
import 'package:trainers_stopwatch/domain/common/training/events/training_event.dart';
import 'package:trainers_stopwatch/domain/common/training/models/training.dart';
import 'package:trainers_stopwatch/domain/common/training/values/distance.dart';
import 'package:trainers_stopwatch/domain/common/training/values/speed.dart';
import 'package:trainers_stopwatch/domain/common/user/models/user.dart';

void main() {
  const user = User(
    id: 1,
    name: 'Ana',
    email: 'ana@example.com',
  );

  final training = Training.create(
    id: 10,
    userId: 1,
    date: DateTime(2026, 8, 25),
  ).value!;

  final distance = Distance.create(value: 200).value!;
  final speed = Speed.create(value: 10).value!;

  TrainingReportTotals totals() => TrainingReportTotals(
        distance: distance,
        duration: const Duration(seconds: 20),
        lapCount: 0,
        averageSpeed: speed,
      );

  TrainingReportRow row() => const TrainingReportRow(
        event: TrainingStarted(
          historyId: 1,
          comments: 'started',
        ),
      );

  TrainingReportSection section() => TrainingReportSection(
        training: training,
        rows: [row()],
        totals: totals(),
      );

  group('TrainingReportContent', () {
    test('has value equality across the complete report structure', () {
      final first = TrainingReportContent(
        user: user,
        sections: [section()],
      );
      final second = TrainingReportContent(
        user: user,
        sections: [section()],
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('copies and protects the received section list', () {
      final source = [section()];
      final report = TrainingReportContent(
        user: user,
        sections: source,
      );

      source.clear();

      expect(report.sections, hasLength(1));
      expect(
        () => report.sections.add(section()),
        throwsUnsupportedError,
      );
    });
  });

  group('TrainingReportSection', () {
    test('has value equality', () {
      expect(section(), section());
      expect(section().hashCode, section().hashCode);
    });

    test('copies and protects the received row list', () {
      final source = [row()];
      final reportSection = TrainingReportSection(
        training: training,
        rows: source,
        totals: totals(),
      );

      source.clear();

      expect(reportSection.rows, hasLength(1));
      expect(
        () => reportSection.rows.add(row()),
        throwsUnsupportedError,
      );
    });
  });

  test('TrainingReportRow has value equality', () {
    expect(row(), row());
    expect(row().hashCode, row().hashCode);
  });

  test('TrainingReportTotals has value equality', () {
    expect(totals(), totals());
    expect(totals().hashCode, totals().hashCode);
  });

  TrainingReportIssue issue() => TrainingReportIssue(
        training: training,
        error: const AppError(
          code: AppErrorCode.zeroElapsedTime,
          message: 'Training has no measurements.',
        ),
      );

  group('TrainingReportIssue', () {
    test('has value equality', () {
      expect(issue(), issue());
      expect(issue().hashCode, issue().hashCode);
    });
  });

  group('TrainingReportBuildOutcome', () {
    TrainingReportContent content({
      required bool withSection,
    }) =>
        TrainingReportContent(
          user: user,
          sections: withSection ? [section()] : [],
        );

    test('identifies an empty result', () {
      final outcome = TrainingReportBuildOutcome(
        content: content(withSection: false),
        issues: const [],
      );

      expect(outcome.status, TrainingReportBuildStatus.empty);
      expect(outcome.hasContent, isFalse);
      expect(outcome.hasIssues, isFalse);
      expect(outcome.validTrainingCount, 0);
      expect(outcome.rejectedTrainingCount, 0);
    });

    test('identifies a complete result', () {
      final outcome = TrainingReportBuildOutcome(
        content: content(withSection: true),
        issues: const [],
      );

      expect(outcome.status, TrainingReportBuildStatus.complete);
      expect(outcome.validTrainingCount, 1);
      expect(outcome.rejectedTrainingCount, 0);
    });

    test('identifies a partial result', () {
      final outcome = TrainingReportBuildOutcome(
        content: content(withSection: true),
        issues: [issue()],
      );

      expect(outcome.status, TrainingReportBuildStatus.partial);
      expect(outcome.hasContent, isTrue);
      expect(outcome.hasIssues, isTrue);
      expect(outcome.validTrainingCount, 1);
      expect(outcome.rejectedTrainingCount, 1);
    });

    test('identifies a fully rejected result', () {
      final outcome = TrainingReportBuildOutcome(
        content: content(withSection: false),
        issues: [issue()],
      );

      expect(outcome.status, TrainingReportBuildStatus.rejected);
      expect(outcome.hasContent, isFalse);
      expect(outcome.hasIssues, isTrue);
    });

    test('copies and protects the received issue list', () {
      final source = [issue()];
      final outcome = TrainingReportBuildOutcome(
        content: content(withSection: false),
        issues: source,
      );

      source.clear();

      expect(outcome.issues, hasLength(1));
      expect(
        () => outcome.issues.add(issue()),
        throwsUnsupportedError,
      );
    });

    test('has value equality', () {
      final first = TrainingReportBuildOutcome(
        content: content(withSection: true),
        issues: [issue()],
      );
      final second = TrainingReportBuildOutcome(
        content: content(withSection: true),
        issues: [issue()],
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });
  });
}
