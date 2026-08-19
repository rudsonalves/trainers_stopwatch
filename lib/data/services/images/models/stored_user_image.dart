final class StoredUserImage {
  final String reference;

  const StoredUserImage({required this.reference}) : assert(reference != '');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoredUserImage && reference == other.reference;

  @override
  int get hashCode => reference.hashCode;
}
