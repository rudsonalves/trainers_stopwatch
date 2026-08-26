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

import '/domain/common/user/models/user.dart';
import '/domain/models/prepared_user_image.dart';
import '/ui/components/show_athlete_image.dart';
import '/ui/components/theme/app_font_style.dart';
import '../../viewmodel/models/user_form_result.dart';
import 'user_controller.dart';
import 'validator.dart';
import 'widgets/custom_text_field.dart';

class UserDialog extends StatefulWidget {
  final User? user;
  final Future<PreparedUserImage?> Function() prepareImage;
  final Future<void> Function(PreparedUserImage image) discardImage;

  const UserDialog({
    super.key,
    this.user,
    required this.prepareImage,
    required this.discardImage,
  });

  static Future<UserFormResult?> open(
    BuildContext context, {
    User? user,
    required Future<PreparedUserImage?> Function() prepareImage,
    required Future<void> Function(PreparedUserImage image) discardImage,
  }) =>
      showDialog<UserFormResult?>(
        context: context,
        barrierDismissible: false,
        builder: (context) => UserDialog(
          user: user,
          prepareImage: prepareImage,
          discardImage: discardImage,
        ),
      );

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
    final prepared = await widget.prepareImage();
    if (!mounted || prepared == null) return;

    final previous = _controller.setPreparedImage(prepared);
    if (previous != null) await widget.discardImage(previous);
  }

  void _addButton() {
    final valit =
        _formKey.currentState != null && _formKey.currentState!.validate();

    if (!valit) return;

    Navigator.pop(context, _controller.buildResult());
  }

  Future<void> _cancelButton() async {
    final prepared = _controller.preparedImage;
    if (prepared != null) await widget.discardImage(prepared);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
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
      ),
    );
  }
}
