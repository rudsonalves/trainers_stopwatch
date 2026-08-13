final class User {
  final int? id;
  final String name;
  final String email;
  final String? phone;
  final String? photoReference;

  const User({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoReference,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          phone == other.phone &&
          photoReference == other.photoReference;

  @override
  int get hashCode => Object.hash(id, name, email, phone, photoReference);
}
