import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import '/core/result/result.dart';
import '/domain/common/report/models/training_report_content.dart';
import '/domain/common/report/models/training_report_row.dart';
import '/domain/common/report/models/training_report_section.dart';
import '/domain/common/report/services/training_report_pdf_renderer.dart';
import '/domain/common/training/events/training_event.dart';
import '../../../ui/components/presentation/training_value_formatter.dart';

class TrainingReportPdfRendererImpl implements TrainingReportPdfRenderer {
  final AssetBundle _assetBundle;
  final String _iconAssetPath;
  final String _fontAssetPath;

  TrainingReportPdfRendererImpl({
    AssetBundle? assetBundle,
    String iconAssetPath = 'assets/icons/stopwatch.png',
    String fontAssetPath = 'assets/fonts/IBMPlexMono-Regular.ttf',
  })  : _assetBundle = assetBundle ?? rootBundle,
        _iconAssetPath = iconAssetPath,
        _fontAssetPath = fontAssetPath;

  @override
  AsyncResult<Uint8List> render({
    required TrainingReportContent content,
    required TrainingReportPdfTexts texts,
  }) async {
    try {
      await initializeDateFormatting(texts.locale);

      final imageData = await _assetBundle.load(_iconAssetPath);
      final fontData = await _assetBundle.load(_fontAssetPath);
      final font = pw.Font.ttf(fontData);

      final image = pw.MemoryImage(
        imageData.buffer.asUint8List(
          imageData.offsetInBytes,
          imageData.lengthInBytes,
        ),
      );

      final document = pw.Document(
        theme: pw.ThemeData.withFont(
          base: font,
          bold: font,
        ),
      );

      for (final section in content.sections) {
        document.addPage(
          _buildPage(
            content: content,
            section: section,
            texts: texts,
            image: image,
          ),
        );
      }

      return Success(await document.save());
    } on AppError catch (error) {
      return Failure(error);
    } catch (error) {
      return Failure(
        AppError(
          code: AppErrorCode.unexpected,
          message: 'Training report PDF rendering failed.',
          details: error,
        ),
      );
    }
  }

  pw.Page _buildPage({
    required TrainingReportContent content,
    required TrainingReportSection section,
    required TrainingReportPdfTexts texts,
    required pw.MemoryImage image,
  }) {
    final training = section.training;
    final totals = section.totals;

    return pw.Page(
      build: (context) => pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                texts.reportTitle,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Image(
                image,
                width: 50,
                height: 50,
              ),
            ],
          ),
          _pdfText(texts.userLabel, content.user.name),
          _pdfText(
            texts.dateLabel,
            DateFormat.yMd(texts.locale).add_Hms().format(training.date),
          ),
          _pdfText(
            texts.totalDistanceLabel,
            '${totals.distance.value.toStringAsFixed(1)} '
            '${totals.distance.unit.symbol}',
          ),
          _pdfText(
            texts.totalTimeLabel,
            TrainingValueFormatter.formatDuration(totals.duration),
          ),
          _pdfText(
            texts.averageSpeedLabel,
            '${totals.averageSpeed.value.toStringAsFixed(2)} '
            '${totals.averageSpeed.unit.symbol}',
          ),
          _pdfText(
            texts.lapDistanceLabel,
            '${training.lapDistance.value} '
            '${training.lapDistance.unit.symbol}',
          ),
          _pdfText(
            texts.splitDistanceLabel,
            '${training.splitDistance.value} '
            '${training.splitDistance.unit.symbol}',
          ),
          _pdfText(
            texts.lapCountLabel,
            totals.lapCount.toString(),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            context: context,
            data: [
              [
                texts.eventColumnLabel,
                texts.timeColumnLabel,
                '${texts.speedColumnLabel} '
                    '(${training.speedUnit.symbol})',
                texts.commentsColumnLabel,
              ],
              ...section.rows.map(
                (row) => _buildRow(
                  row: row,
                  section: section,
                  texts: texts,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<String> _buildRow({
    required TrainingReportRow row,
    required TrainingReportSection section,
    required TrainingReportPdfTexts texts,
  }) {
    final event = row.event;

    return [
      _eventLabel(event, texts),
      TrainingValueFormatter.formatDuration(_eventDuration(event)),
      _eventSpeed(event, section),
      event.comments ?? '',
    ];
  }

  String _eventLabel(
    TrainingEvent event,
    TrainingReportPdfTexts texts,
  ) =>
      switch (event) {
        TrainingStarted() => texts.trainingStartedLabel,
        SplitRecorded(:final splitIndex) => '${texts.splitLabel}[$splitIndex]',
        LapRecorded(:final lapIndex) => '${texts.lapLabel}[$lapIndex]',
      };

  Duration _eventDuration(TrainingEvent event) => switch (event) {
        TrainingStarted() => Duration.zero,
        SplitRecorded(:final duration) => duration,
        LapRecorded(:final duration) => duration,
      };

  String _eventSpeed(
    TrainingEvent event,
    TrainingReportSection section,
  ) =>
      switch (event) {
        TrainingStarted() => '0.00 ${section.training.speedUnit.symbol}',
        SplitRecorded(:final speed) =>
          '${speed.value.toStringAsFixed(2)} ${speed.unit.symbol}',
        LapRecorded(:final speed) =>
          '${speed.value.toStringAsFixed(2)} ${speed.unit.symbol}',
      };

  pw.Text _pdfText(String label, String value) {
    return pw.Text(
      '$label: $value',
      textAlign: pw.TextAlign.left,
    );
  }
}
