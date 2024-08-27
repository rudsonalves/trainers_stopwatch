// Copyright (C) 2024 Rudson Alves
//
// This file is part of trainers_stopwatch.
//
// trainers_stopwatch is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// trainers_stopwatch is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with trainers_stopwatch.  If not, see <https://www.gnu.org/licenses/>.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../common/theme/app_font_style.dart';
import '../../../../common/models/user_model.dart';
import '../../../widgets/common/show_athlete_image.dart';
import 'user_controller.dart';
import 'validator.dart';
import 'widgets/custom_text_field.dart';

class UserDialog extends StatefulWidget {
  final UserModel? user;
  final void Function(UserModel)? addUser;
  final Future<XFile?> Function(XFile file) resizeAndSaveImage;

  const UserDialog({
    super.key,
    this.user,
    this.addUser,
    required this.resizeAndSaveImage,
  });

  static Future<bool?> open(
    BuildContext context, {
    UserModel? user,
    void Function(UserModel)? addUser,
    required Future<XFile?> Function(XFile file) resizeAndSaveImage,
  }) async {
    final bool result = await showDialog<bool?>(
          context: context,
          builder: (context) => UserDialog(
            user: user,
            addUser: addUser,
            resizeAndSaveImage: resizeAndSaveImage,
          ),
        ) ??
        false;

    return result;
  }

  @override
  State<UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends State<UserDialog> {
  bool isAddUser = false;
  final _controller = UserController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      isAddUser = false;
      _controller.init(widget.user);
    } else {
      isAddUser = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _photoImageOnTap() async {
    final ImagePicker picker = ImagePicker();
    final XFile? xfile = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (xfile != null) {
      final resizedFile = await widget.resizeAndSaveImage(xfile);
      if (resizedFile != null) {
        _controller.setImage(resizedFile.path);
      }
    }
  }

  void _addButton() {
    final valit =
        _formKey.currentState != null && _formKey.currentState!.validate();

    if (!valit) return;

    Navigator.pop(context, true);

    final id = isAddUser ? null : widget.user!.id;

    final user = UserModel(
      id: id,
      name: _controller.name.text,
      email: _controller.email.text,
      photo: _controller.image.value,
      phone: _controller.phone.text,
    );

    if (widget.addUser != null) {
      widget.addUser!(user);
    }
  }

  void _cancelButton() => Navigator.pop(context, false);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    isAddUser ? 'ADNew'.tr() : 'ADEdit'.tr(),
                    style: AppFontStyle.roboto18SemiBold,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _photoImageOnTap,
                  child: ValueListenableBuilder(
                    valueListenable: _controller.image,
                    builder: (context, value, _) => ShowUserImage(value),
                  ),
                ),
                CustomTextField(
                  controller: _controller.name,
                  validator: Validador.name,
                  label: 'ADName'.tr(),
                ),
                CustomTextField(
                  controller: _controller.email,
                  validator: Validador.email,
                  label: 'ADEmail'.tr(),
                ),
                CustomTextField(
                  controller: _controller.phone,
                  label: 'ADPhone'.tr(),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                OverflowBar(
                  children: [
                    FilledButton.tonal(
                      onPressed: _addButton,
                      child: Text(
                        isAddUser ? 'GenericAdd'.tr() : 'GenericUpdate'.tr(),
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: _cancelButton,
                      child: Text('GenericCancel'.tr()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
