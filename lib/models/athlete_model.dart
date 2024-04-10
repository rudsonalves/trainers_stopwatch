import 'dart:convert';

class AthleteModel {
  int? id;
  String name;
  String email;
  String? phone;
  String? photo;

  AthleteModel({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photo,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photo': photo,
    };
  }

  factory AthleteModel.fromMap(Map<String, dynamic> map) {
    return AthleteModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      photo: map['photo'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory AthleteModel.fromJson(String source) =>
      AthleteModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AthleteModel(id: $id,'
        ' name: $name,'
        ' email: $email,'
        ' phone: $phone,'
        ' photo: $photo)';
  }
}
