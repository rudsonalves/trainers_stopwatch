import 'dart:convert';

class TrainingModel {
  int? id;
  int athleteId;
  DateTime date;
  String? comments;
  double splitLength;
  double lapLength;
  int? maxlaps;
  String distanceUnit;
  String speedUnit;

  TrainingModel({
    this.id,
    required this.athleteId,
    required this.date,
    this.comments,
    this.splitLength = 200,
    this.lapLength = 1000,
    this.maxlaps,
    this.distanceUnit = 'm',
    this.speedUnit = 'm/s',
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'athleteId': athleteId,
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
      athleteId: map['athleteId'] as int,
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
        ' athleteId:'
        ' $athleteId,'
        ' date: $date,'
        ' comments: $comments,'
        ' splitLength: $splitLength,'
        ' lapLength: $lapLength,'
        ' maxlaps: $maxlaps,'
        ' distanceUnit: $distanceUnit,'
        ' speedUnit: $speedUnit';
  }
}
