import 'package:flutter/material.dart';

import '../constants.dart';

enum MessageType {
  isLap,
  isSplit,
  isStarting,
}

class MessagesModel {
  String title;
  String subTitle;
  String body;
  Color color;
  int historyId;
  MessageType msgType;

  MessagesModel({
    this.title = "",
    this.subTitle = "",
    this.body = "",
    this.color = primaryColor,
    this.msgType = MessageType.isSplit,
    this.historyId = 0,
  });

  @override
  String toString() =>
      'MessagesModel(title: "$title", subTitle: "$subTitle", body: "$body")';

  bool get isNotEmpty =>
      title.isNotEmpty || subTitle.isNotEmpty || body.isNotEmpty;
}
