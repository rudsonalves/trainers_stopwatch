import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../../common/constants.dart';
import '../../../../common/singletons/app_settings.dart';
import '../../../../common/models/user_model.dart';

class UserController {
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();

  final image = ValueNotifier<String>(defaultPhotoImage);

  void init(UserModel? user) {
    if (user != null) {
      name.text = user.name;
      email.text = user.email;
      phone.text = user.phone ?? '';
      image.value = user.photo ?? defaultPhotoImage;
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

    if (image.value.isNotEmpty && image.value != defaultPhotoImage) {
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
