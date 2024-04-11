import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signals/signals_flutter.dart';

import '../../common/constants.dart';
import '../../common/theme/app_font_style.dart';
import '../../models/athlete_model.dart';
import '../widgets/common/show_athlete_image.dart';
import 'athlete_controller.dart';
import 'validator.dart';
import 'widgets/custom_text_field.dart';

class AthleteDialog extends StatefulWidget {
  final AthleteModel? athlete;
  final void Function(AthleteModel)? sueAthlete;

  const AthleteDialog({
    super.key,
    this.athlete,
    this.sueAthlete,
  });

  static Future<bool?> open(
    BuildContext context, {
    AthleteModel? athlete,
    void Function(AthleteModel)? sueAthlete,
  }) async {
    final bool result = await showDialog<bool?>(
          context: context,
          builder: (context) => AthleteDialog(
            athlete: athlete,
            sueAthlete: sueAthlete,
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
      _controller.init(widget.athlete);
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
      maxHeight: photoImageSize * 1.2,
      maxWidth: photoImageSize,
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

    final id = isAddAthlete ? null : widget.athlete!.id;

    final athlete = AthleteModel(
      id: id,
      name: _controller.name.text,
      email: _controller.email.text,
      photo: _controller.image(),
      phone: _controller.phone.text,
    );

    if (widget.sueAthlete != null) {
      widget.sueAthlete!(athlete);
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
                    style: AppFontStyle.roboto18Bold,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _photoImageOnTap,
                  child: ShowAthleteImage(_controller.image.watch(context)),
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
                      child: Text(
                        isAddAthlete ? 'Add' : 'Update',
                      ),
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
