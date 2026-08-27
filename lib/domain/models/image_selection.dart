sealed class ImageSelection {
  const ImageSelection();
}

final class ImageSelectionCanceled extends ImageSelection {
  const ImageSelectionCanceled();
}

final class ImageSelected extends ImageSelection {
  final String sourceReference;
  final String fileName;

  const ImageSelected({
    required this.sourceReference,
    required this.fileName,
  })  : assert(sourceReference != ''),
        assert(fileName != '');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageSelected &&
          sourceReference == other.sourceReference &&
          fileName == other.fileName;

  @override
  int get hashCode => Object.hash(sourceReference, fileName);
}
