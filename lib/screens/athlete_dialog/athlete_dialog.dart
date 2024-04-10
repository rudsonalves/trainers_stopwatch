// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trainers_stopwatch/screens/athlete_dialog/validator.dart';

import '../../common/constants.dart';
import '../../models/athlete_model.dart';
import 'athlete_controller.dart';
import 'widgets/custom_text_field.dart';

class AthleteDialog extends StatefulWidget {
  final AthleteModel? athlete;
  final void Function(AthleteModel)? addAthlete;

  const AthleteDialog({
    super.key,
    this.athlete,
    this.addAthlete,
  });

  static Future<bool?> open(
    BuildContext context, {
    AthleteModel? athlete,
    void Function(AthleteModel)? addAthlete,
  }) async {
    final bool result = await showDialog<bool?>(
          context: context,
          builder: (context) => AthleteDialog(
            athlete: athlete,
            addAthlete: addAthlete,
          ),
        ) ??
        false;

    return result;
  }

  @override
  State<AthleteDialog> createState() => _AthleteDialogState();
}

class _AthleteDialogState extends State<AthleteDialog> {
  bool isAddAthlete = false;
  final _controller = AthleteController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.athlete != null) {
      isAddAthlete = false;
    } else {
      isAddAthlete = true;
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
      maxHeight: 200,
      maxWidth: 200,
      source: ImageSource.camera,
    );

    if (xfile != null) {
      _controller.setImage(xfile.path);
    }
  }

  void _okButton() {
    final valit =
        _formKey.currentState != null && _formKey.currentState!.validate();

    if (valit) Navigator.pop(context, true);

    final athlete = AthleteModel(
      name: _controller.name.text,
      email: _controller.email.text,
      photo: _controller.image.value,
      phone: _controller.phone.text,
    );

    if (widget.addAthlete != null) {
      widget.addAthlete!(athlete);
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
                    isAddAthlete ? 'Add new Athlete' : 'Edit Athlete',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListenableBuilder(
                  listenable: _controller.image,
                  builder: (context, _) => SizedBox(
                    height: photoImageSize,
                    width: photoImageSize,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _photoImageOnTap,
                      child: _controller.image.value == ''
                          ? Image.asset(defaultPhotoImage)
                          : Image.file(File(_controller.image.value)),
                    ),
                  ),
                ),
                CustomTextField(
                  controller: _controller.name,
                  validator: Validador.name,
                  label: 'Name',
                ),
                CustomTextField(
                  controller: _controller.email,
                  validator: Validador.email,
                  label: 'Email',
                ),
                CustomTextField(
                  controller: _controller.phone,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                ButtonBar(
                  children: [
                    FilledButton(
                      onPressed: _okButton,
                      child: const Text('Add'),
                    ),
                    FilledButton(
                      onPressed: _cancelButton,
                      child: const Text('Cancel'),
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
