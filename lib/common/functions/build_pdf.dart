// Copyright (C) 2024 Rudson Alves
// 
// This file is part of trainers_stopwatch.
// 
// trainers_stopwatch is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// trainers_stopwatch is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with trainers_stopwatch.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../repositories/history_repository/history_repository.dart';
import '../models/training_model.dart';
import '../models/user_model.dart';
import 'stopwatch_functions.dart';
import 'training_report.dart';

sealed class BuildPdf {
  BuildPdf._();

  static pw.Text pdfText(String label, String value) {
    return pw.Text(
      '$label: $value',
      textAlign: pw.TextAlign.left,
    );
  }

  static Future<File> makeReport(
    UserModel user,
    List<TrainingModel> trainings,
  ) async {
    final repository = HistoryRepository();
    final pdf = pw.Document();
    final imageData = await rootBundle.load('assets/icons/stopwatch.png');
    final image = pw.MemoryImage(imageData.buffer.asUint8List());

    for (final training in trainings) {
      final histories = await repository.queryAllFromTraining(training.id!);
      final report = TrainingReport(
        user: user,
        training: training,
        histories: histories,
      );
      report.createMessages();

      final numberOfSplits = histories.length - 1;
      final totalLength = numberOfSplits * training.splitLength;
      final totalOfLaps = (totalLength / training.lapLength).round();
      final totalDuration =
          histories.fold(Duration.zero, (sum, item) => sum + item.duration);
      final mediumSpeed = StopwatchFunctions.speedCalc(
        length: totalLength,
        time: totalDuration.inMilliseconds / 1000,
        training: training,
      );

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
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
                pdfText('User', user.name),
                pdfText(
                  'Date',
                  DateFormat.yMd().add_Hms().format(training.date),
                ),
                pdfText(
                  'Total Length',
                  '${totalLength.toStringAsFixed(1)} ${training.distanceUnit}:',
                ),
                pdfText(
                  'Total Time',
                  StopwatchFunctions.formatDuration(totalDuration),
                ),
                pdfText(
                  'Medium Speed',
                  '${mediumSpeed.value.toStringAsFixed(2)} ${mediumSpeed.speedUnit}',
                ),
                pdfText(
                  'Lap Length',
                  '${training.lapLength} ${training.distanceUnit}',
                ),
                pdfText(
                  'Split Length',
                  '${training.splitLength} ${training.distanceUnit}',
                ),
                pdfText('Number of Laps', totalOfLaps.toString()),
                pw.SizedBox(height: 20),
                pw.TableHelper.fromTextArray(
                  context: context,
                  data: <List<String>>[
                    <String>[
                      'Split/Lap',
                      'time (s)',
                      'Speed (${training.speedUnit})',
                      'Comments'
                    ],
                    ...report.messages.map(
                      (msg) => [
                        msg.label,
                        StopwatchFunctions.formatDuration(msg.duration),
                        msg.speedString,
                        msg.comments,
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/training_logs.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
