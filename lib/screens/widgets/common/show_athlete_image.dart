import 'dart:io';

import 'package:flutter/material.dart';

import '../../../common/constants.dart';

class ShowAthleteImage extends StatelessWidget {
  final String image;

  const ShowAthleteImage(
    this.image, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: photoImageSize,
      height: photoImageSize,
      child: image == defaultPhotoImage
          ? Image.asset(image)
          : Image.file(File(image)),
    );
  }
}
