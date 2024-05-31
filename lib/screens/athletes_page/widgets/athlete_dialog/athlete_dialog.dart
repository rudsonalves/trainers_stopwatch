import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../common/constants.dart';
import '../../../../common/theme/app_font_style.dart';
import '../../../../models/athlete_model.dart';
import '../../../widgets/common/show_athlete_image.dart';
import 'athlete_controller.dart';
import 'validator.dart';
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

  void _addButton() {
    final valit =
        _formKey.currentState != null && _formKey.currentState!.validate();

    if (!valit) return;

    Navigator.pop(context, true);

    final id = isAddAthlete ? null : widget.athlete!.id;

    final athlete = AthleteModel(
      id: id,
      name: _controller.name.text,
      email: _controller.email.text,
      photo: _controller.image(),
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
                    isAddAthlete ? 'ADNew'.tr() : 'ADEdit'.tr(),
                    style: AppFontStyle.roboto18SemiBold,
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
                ButtonBar(
                  children: [
                    FilledButton(
                      onPressed: _addButton,
                      child: Text(
                        isAddAthlete ? 'GenericAdd'.tr() : 'GenericUpdate'.tr(),
                      ),
                    ),
                    FilledButton(
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
