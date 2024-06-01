import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:signals/signals_flutter.dart';

import '../../../../common/constants.dart';
import '../../../../common/singletons/app_settings.dart';
import '../../../../models/athlete_model.dart';

class AthleteController {
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();

  final image = signal<String>(defaultPhotoImage);

  void init(AthleteModel? athlete) {
    if (athlete != null) {
      name.text = athlete.name;
      email.text = athlete.email;
      phone.text = athlete.phone ?? '';
      image.value = athlete.photo ?? defaultPhotoImage;
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

    if (image().isNotEmpty && image() != defaultPhotoImage) {
      oldImageFile = File(image());
    }

    final finalPath = '$destinyPath/$fileName';
    await originFile.copy(finalPath);

    image.value = finalPath;

    if (oldImageFile != null) {
      await oldImageFile.delete();
    }
  }
}
