import 'dart:convert';

class HistoryModel {
  int? id;
  int trainingId;
  int? lap;
  int split;
  Duration duration;
  String? comments;

  HistoryModel({
    this.id,
    required this.trainingId,
    this.lap,
    required this.split,
    required this.duration,
    this.comments,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'trainingId': trainingId,
      'lap': lap,
      'split': split,
      'duration': duration.inMilliseconds,
      'comments': comments,
    };
  }

  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      id: map['id'] as int?,
      trainingId: map['trainingId'] as int,
      lap: map['lap'] as int?,
      split: map['split'] as int,
      duration: Duration(milliseconds: map['duration'] as int),
      comments: map['comments'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory HistoryModel.fromJson(String source) =>
      HistoryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'HistoryModel(id: $id,'
        ' trainingId: $trainingId,'
        ' lap: $lap,'
        ' split: $split,'
        ' duration: $duration,'
        ' comments: $comments)';
  }
}
