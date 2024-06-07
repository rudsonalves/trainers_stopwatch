import 'dart:convert';

class UserModel {
  int? id;
  String name;
  String email;
  String? phone;
  String? photo;

  UserModel({
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

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      photo: map['photo'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id,'
        ' name: $name,'
        ' email: $email,'
        ' phone: $phone,'
        ' photo: $photo)';
  }
}
