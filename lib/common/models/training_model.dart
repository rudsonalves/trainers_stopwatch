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

import 'dart:convert';

import 'package:flutter/material.dart';

import '../constants.dart';

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
