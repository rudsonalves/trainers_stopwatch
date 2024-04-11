import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class TrainingModel {
  int? id;
  int athleteId;
  DateTime date;
  String? comments;
  double? splitLength;
  double? lapLength;

  TrainingModel({
    this.id,
    required this.athleteId,
    required this.date,
    this.comments,
    this.splitLength,
    this.lapLength,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'athleteId': athleteId,
      'date': date.millisecondsSinceEpoch,
      'comments': comments,
      'splitLength': splitLength,
      'lapLength': lapLength,
    };
  }

  factory TrainingModel.fromMap(Map<String, dynamic> map) {
    return TrainingModel(
      id: map['id'] as int?,
      athleteId: map['athleteId'] as int,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      comments: map['comments'] as String?,
      splitLength: map['splitLength'] as double?,
      lapLength: map['lapLength'] as double?,
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
        ' comments: $comments)'
        ' splitLength: $splitLength'
        ' lapLength: $lapLength';
  }
}
