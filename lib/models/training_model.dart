import 'dart:convert';

import 'package:flutter/material.dart';

import '../common/constants.dart';

class TrainingModel {
  int? id;
  int userId;
  DateTime date;
  String? comments;
  double splitLength;
  double lapLength;
  int? maxlaps;
  String distanceUnit;
  String speedUnit;
  Color color;

  TrainingModel({
    this.id,
    required this.userId,
    required this.date,
    this.comments,
    this.splitLength = 200,
    this.lapLength = 1000,
    this.maxlaps,
    this.distanceUnit = 'm',
    this.speedUnit = 'm/s',
    this.color = primaryColor,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'date': date.millisecondsSinceEpoch,
      'comments': comments,
      'splitLength': splitLength,
      'lapLength': lapLength,
      'maxlaps': maxlaps,
      'distanceUnit': distanceUnit,
      'speedUnit': speedUnit,
    };
  }

  factory TrainingModel.fromMap(Map<String, dynamic> map) {
    return TrainingModel(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      comments: map['comments'] as String?,
      splitLength: map['splitLength'] as double,
      lapLength: map['lapLength'] as double,
      maxlaps: map['maxlaps'] as int?,
      distanceUnit: map['distanceUnit'] as String,
      speedUnit: map['speedUnit'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory TrainingModel.fromJson(String source) =>
      TrainingModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TrainingModel(id: $id,'
        ' userId:'
        ' $userId,'
        ' date: $date,'
        ' comments: $comments,'
        ' splitLength: $splitLength,'
        ' lapLength: $lapLength,'
        ' maxlaps: $maxlaps,'
        ' distanceUnit: $distanceUnit,'
        ' speedUnit: $speedUnit';
  }
}
