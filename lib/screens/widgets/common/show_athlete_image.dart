import 'dart:io';

import 'package:flutter/material.dart';

import '../../../common/constants.dart';

class ShowAthleteImage extends StatelessWidget {
  final String image;
  final double? size;

  const ShowAthleteImage(
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
