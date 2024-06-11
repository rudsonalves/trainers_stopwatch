import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/training_model.dart';

sealed class BuildPdf {
  BuildPdf._();

  static Future<File> makeTraining(List<TrainingModel> trainings) async {
    final pdf = pw.Document();
    final imageData = await rootBundle.load('assets/icons/stopwatch.png');
    final image = pw.MemoryImage(imageData.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Training Logs',
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
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Date', 'Split Length', 'Lap Length', 'Comments'],
                  ...trainings.map(
                    (training) => [
                      DateFormat.yMd().add_Hms().format(training.date),
                      '${training.splitLength} ${training.distanceUnit}',
                      '${training.lapLength} ${training.distanceUnit}',
                      training.comments ?? ''
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/training_logs.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
