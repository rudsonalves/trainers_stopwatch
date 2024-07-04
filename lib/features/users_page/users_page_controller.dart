import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../common/constants.dart';
import '../../common/singletons/app_settings.dart';
import '../../manager/user_manager.dart';
import '../../common/models/user_model.dart';
import 'users_page_state.dart';

class UsersPageController extends ChangeNotifier {
  final _usersManager = UserManager.instance;
  UsersPageState _state = UsersPageStateInitial();

  UsersPageState get state => _state;
  List<UserModel> get users => _usersManager.users;

  final app = AppSettings.instance;

  void _changeState(UsersPageState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> init() async {
    await _usersManager.init();
    getAllUsers();
  }

  Future<void> getAllUsers() async {
    try {
      _changeState(UsersPageStateLoading());
      await _usersManager.getAllUsers();
      _changeState(UsersPageStateSuccess());
    } catch (err) {
      log('UsersPageState.getAllUsers: $err');
      _changeState(UsersPageStateError());
    }
  }

  Future<void> addUser(UserModel user) async {
    try {
      _changeState(UsersPageStateLoading());
      await _usersManager.insert(user);
      if (app.tutorialOn) {
        app.tutorialId = user.id!;
      }
      _changeState(UsersPageStateSuccess());
    } catch (err) {
      log('UsersPageState.addUser: $err');
      _changeState(UsersPageStateError());
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      _changeState(UsersPageStateLoading());
      await _usersManager.update(user);
      _changeState(UsersPageStateSuccess());
    } catch (err) {
      log('UsersPageState.updateUser: $err');
      _changeState(UsersPageStateError());
    }
  }

  Future<void> deleteUser(UserModel user) async {
    try {
      _changeState(UsersPageStateLoading());
      await _usersManager.delete(user);
      _changeState(UsersPageStateSuccess());
    } catch (err) {
      log('UsersPageState.updateUser: $err');
      _changeState(UsersPageStateError());
    }
  }

  Future<XFile?> resizeAndSaveImage(XFile file) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final fileName = path.basename(file.path);
    final imageDir = Directory(path.join(appDocDir.path, 'images'));
    final newFilePath = path.join(imageDir.path, 'resized_$fileName');

    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      newFilePath,
      quality: 95,
      minHeight: photoImageSize.toInt(),
      // minWidth: 80,
    );

    return result;
  }

  Future<void> removeUnusedImages() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(path.join(appDocDir.path, 'images'));

    final imagesInUse = (await _usersManager.getImagesList())
        .map((item) => path.basename(item))
        .toList();

    if (!await imageDir.exists()) return;
    final List<FileSystemEntity> files = imageDir.listSync();
    for (final file in files) {
      final filename = path.basename(file.path);
      if (file is File && !imagesInUse.contains(filename)) {
        await file.delete();
      }
    }
  }
}
