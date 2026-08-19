final class PreparedUserImage {
  final String temporaryReference;
  final String fileName;

  const PreparedUserImage({
    required this.temporaryReference,
    required this.fileName,
  })  : assert(temporaryReference != ''),
        assert(fileName != '');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreparedUserImage &&
          temporaryReference == other.temporaryReference &&
          fileName == other.fileName;

  @override
  int get hashCode => Object.hash(temporaryReference, fileName);
}
