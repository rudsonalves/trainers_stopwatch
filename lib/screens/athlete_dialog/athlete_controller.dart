import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../common/singletons/app_settings.dart';
import '../../models/athlete_model.dart';

class AthleteController {
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();

  final image = ValueNotifier('');

  void init(AthleteModel? athlete) {
    if (athlete != null) {
      name.text = athlete.name;
      email.text = athlete.email;
      phone.text = athlete.phone ?? '';
      image.value = athlete.photo ?? '';
    }
  }

  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    image.dispose();
  }

  Future<void> setImage(String imagePath) async {
    final originFile = File(imagePath);
    final fileName = p.basename(imagePath);
    final destinyPath = AppSettings.instance.imagePath;
    File? oldImageFile;

    if (image.value.isNotEmpty) {
      oldImageFile = File(image.value);
    }

    final finalPath = '$destinyPath/$fileName';
    await originFile.copy(finalPath);

    image.value = finalPath;

    if (oldImageFile != null) {
      await oldImageFile.delete();
    }
  }
}
