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
