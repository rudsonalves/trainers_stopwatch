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

import '../../../common/constants.dart';

class ShowUserImage extends StatelessWidget {
  final String image;
  final double? size;

  const ShowUserImage(
    this.image, {
    super.key,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? photoImageSize,
      height: size ?? photoImageSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: image == defaultPhotoImage
            ? Image.asset(image)
            : Image.file(
                File(image),
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
