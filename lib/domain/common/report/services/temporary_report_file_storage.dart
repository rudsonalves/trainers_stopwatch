import 'dart:typed_data';

import '/core/result/result.dart';

class TemporaryReportFile {
  final String path;
  final String name;
  final String mimeType;

  const TemporaryReportFile({
    required this.path,
    required this.name,
    required this.mimeType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemporaryReportFile &&
          path == other.path &&
          name == other.name &&
          mimeType == other.mimeType;

  @override
  int get hashCode => Object.hash(
        path,
        name,
        mimeType,
      );
}

abstract interface class TemporaryReportFileStorage {
  AsyncResult<TemporaryReportFile> write({
    required String suggestedName,
    required String mimeType,
    required Uint8List bytes,
  });

  AsyncResult<Unit> delete(TemporaryReportFile file);
}
