import 'package:flutter/material.dart';

import '../common/constants.dart';

class MessagesModel {
  String title;
  String subTitle;
  String body;
  Color color;

  MessagesModel({
    this.title = "",
    this.subTitle = "",
    this.body = "",
    this.color = primaryColor,
  });

  @override
  String toString() =>
      'MessagesModel(title: "$title", subTitle: "$subTitle", body: "$body")';

  bool get isNotEmpty =>
      title.isNotEmpty || subTitle.isNotEmpty || body.isNotEmpty;
}
