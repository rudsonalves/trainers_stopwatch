import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AppSettings {
  AppSettings._();
  static final _instance = AppSettings._();
  static AppSettings get instance => _instance;

  late final String _imagePath;
  late final Directory _appDocDir;

  String get imagePath => _imagePath;

  Future<void> init() async {
    _appDocDir = await getApplicationDocumentsDirectory();
    _imagePath = '${_appDocDir.path}/athletes_images';

    final athletesImageDir = Directory(_imagePath);
    if (!await athletesImageDir.exists()) {
      await athletesImageDir.create(recursive: true);
    }
  }
}
