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

import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:share_plus/share_plus.dart';

import '../models/training_model.dart';
import '../models/user_model.dart';
import 'build_pdf.dart';

sealed class AppShare {
  AppShare._();

  static Future<void> sendWhatsApp({
    required UserModel user,
    required List<TrainingModel> trainings,
  }) async {
    final pdfFile = await BuildPdf.makeReport(user, trainings);
    final XFile xfile = XFile(pdfFile.path);

    await Share.shareXFiles(
      [xfile],
      subject: 'Training',
    );
  }

  static Future<void> sendEmail({
    required UserModel user,
    required String recipient,
    required List<TrainingModel> trainings,
  }) async {
    const subject = 'Training logs';
    final body = _createBody(trainings);

    final file = await BuildPdf.makeReport(user, trainings);

    final email = Email(
      subject: subject,
      body: body,
      recipients: [recipient],
      isHTML: true,
      attachmentPaths: [file.path],
    );

    try {
      await FlutterEmailSender.send(email);
      await file.delete();
    } catch (err) {
      final message = 'Share.sendEmail: $err';
      log(message);
      throw Exception(message);
    }
  }

  static String _createBody(List<TrainingModel> trainings) {
    String body = '''
    <html>
    <body>
  ''';

    body += _headerLine('Training Logs', 1, 'font-size: 24px; color: #333;');

    for (final training in trainings) {
      final unit = training.distanceUnit;
      final date = DateFormat.yMd().add_Hms().format(training.date);
      final lap = training.lapLength;
      final split = training.splitLength;

      body += '<div class="training-block">\n';
      body += _headerLine('Training', 2);
      body += _line('Date', date);
      body += _line('Split Length', '$split $unit');
      body += _line('Lap Length', '$lap $unit');

      if (training.comments != null && training.comments!.isNotEmpty) {
        body += _line('Comments', training.comments!);
      }

      body += '</div>\n';
    }
    body += '</body>\n</html>\n';
    return body;
  }

  static String _headerLine(String title, [int index = 1, String? style]) {
    return style != null
        ? '<h$index style="$style">$title</h$index>\n'
        : '<h$index>$title</h$index>\n';
  }

  static String _line(String title, String value) {
    return '<p><strong>$title:</strong> $value</p>\n';
  }
}
