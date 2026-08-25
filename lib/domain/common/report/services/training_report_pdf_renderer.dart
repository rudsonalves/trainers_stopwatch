import 'dart:typed_data';

import '/core/result/result.dart';
import '../models/training_report_content.dart';

abstract interface class TrainingReportPdfRenderer {
  AsyncResult<Uint8List> render({
    required TrainingReportContent content,
    required TrainingReportPdfTexts texts,
  });
}

class TrainingReportPdfTexts {
  final String locale;
  final String reportTitle;
  final String userLabel;
  final String dateLabel;
  final String totalDistanceLabel;
  final String totalTimeLabel;
  final String averageSpeedLabel;
  final String lapDistanceLabel;
  final String splitDistanceLabel;
  final String lapCountLabel;
  final String eventColumnLabel;
  final String timeColumnLabel;
  final String speedColumnLabel;
  final String commentsColumnLabel;
  final String trainingStartedLabel;
  final String splitLabel;
  final String lapLabel;

  const TrainingReportPdfTexts({
    required this.locale,
    required this.reportTitle,
    required this.userLabel,
    required this.dateLabel,
    required this.totalDistanceLabel,
    required this.totalTimeLabel,
    required this.averageSpeedLabel,
    required this.lapDistanceLabel,
    required this.splitDistanceLabel,
    required this.lapCountLabel,
    required this.eventColumnLabel,
    required this.timeColumnLabel,
    required this.speedColumnLabel,
    required this.commentsColumnLabel,
    required this.trainingStartedLabel,
    required this.splitLabel,
    required this.lapLabel,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingReportPdfTexts &&
          locale == other.locale &&
          reportTitle == other.reportTitle &&
          userLabel == other.userLabel &&
          dateLabel == other.dateLabel &&
          totalDistanceLabel == other.totalDistanceLabel &&
          totalTimeLabel == other.totalTimeLabel &&
          averageSpeedLabel == other.averageSpeedLabel &&
          lapDistanceLabel == other.lapDistanceLabel &&
          splitDistanceLabel == other.splitDistanceLabel &&
          lapCountLabel == other.lapCountLabel &&
          eventColumnLabel == other.eventColumnLabel &&
          timeColumnLabel == other.timeColumnLabel &&
          speedColumnLabel == other.speedColumnLabel &&
          commentsColumnLabel == other.commentsColumnLabel &&
          trainingStartedLabel == other.trainingStartedLabel &&
          splitLabel == other.splitLabel &&
          lapLabel == other.lapLabel;

  @override
  int get hashCode => Object.hashAll([
        locale,
        reportTitle,
        userLabel,
        dateLabel,
        totalDistanceLabel,
        totalTimeLabel,
        averageSpeedLabel,
        lapDistanceLabel,
        splitDistanceLabel,
        lapCountLabel,
        eventColumnLabel,
        timeColumnLabel,
        speedColumnLabel,
        commentsColumnLabel,
        trainingStartedLabel,
        splitLabel,
        lapLabel,
      ]);
}
