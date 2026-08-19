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

import 'package:flutter/material.dart';

import '../../../../common/constants.dart';
import '../../../../domain/common/user/models/user.dart';
import '../../../../domain/models/prepared_user_image.dart';
import '../../../../ui/pages/users/models/user_form_result.dart';

class UserController {
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();

  final image = ValueNotifier<String>(defaultPhotoImage);
  PreparedUserImage? _preparedImage;
  User? _originalUser;

  PreparedUserImage? get preparedImage => _preparedImage;

  void init(User? user) {
    _originalUser = user;
    if (user != null) {
      name.text = user.name;
      email.text = user.email;
      phone.text = user.phone ?? '';
      image.value = user.photoReference ?? defaultPhotoImage;
    }
  }

  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    image.dispose();
  }

  PreparedUserImage? setPreparedImage(PreparedUserImage image) {
    final previous = _preparedImage;
    _preparedImage = image;
    this.image.value = image.temporaryReference;
    return previous;
  }

  UserFormResult buildResult() => UserFormResult(
        user: User(
          id: _originalUser?.id,
          name: name.text,
          email: email.text,
          phone: phone.text,
          photoReference: _originalUser?.photoReference,
        ),
        preparedImage: _preparedImage,
      );
}
