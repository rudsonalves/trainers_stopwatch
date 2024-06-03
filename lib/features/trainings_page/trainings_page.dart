import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../common/theme/app_font_style.dart';
import '../../models/training_model.dart';
import '../history_page/history_page.dart';
import '../widgets/common/user_card.dart';
import '../widgets/common/generic_dialog.dart';
import 'trainings_page_controller.dart';
import 'trainings_page_state.dart';
import 'widgets/dismissible_training.dart';

class TrainingsPage extends StatefulWidget {
  const TrainingsPage({super.key});

  static const routeName = '/trainings';

  @override
  State<TrainingsPage> createState() => _TrainingsPageState();
}

class _TrainingsPageState extends State<TrainingsPage> {
  final _controller = TrainingsPageController();
  bool _allSelected = false;

  List<TrainingModel> get trainings => _controller.trainings;

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  Future<void> _editTraining(TrainingModel training) async {
    Navigator.pushNamed(
      context,
      HistoryPage.routeName,
      arguments: {
        'user': _controller.user,
        'training': training,
      },
    );
  }

  Future<bool> _removeTraining(TrainingModel training) async {
    final result = await GenericDialog.open(
      context,
      title: 'TPRemoveTrainingTitle'.tr(),
      message: 'TPRemoveTrainingMsg'.tr(),
      actions: DialogActions.yesNo,
    );

    if (result) {
      await _controller.removeTraining(training);
    }
    return result;
  }

  Future<void> _removeSelected() async {
    final result = await GenericDialog.open(
      context,
      title: 'TPRemoveSelectedTitle'.tr(),
      message: 'TPRemoveSelectedMsg'.tr(),
      actions: DialogActions.yesNo,
    );

    if (result) {
      await _controller.removeSelected();
    }
  }

  void _selectAllTraining() {
    _allSelected = true;
    _controller.selectAllTraining();
  }

  void _deselectAllTraining() {
    _allSelected = false;
    _controller.deselectAllTraining();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('TPTitle'.tr()),
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            switch (_controller.state) {
              // Trainings Page State Loading...
              case TrainingsPageStateLoading():
                return const Center(
                  child: CircularProgressIndicator(),
                );
              // Trainings Page State Success...
              case TrainingsPageStateSuccess():
                return Column(
                  children: [
                    // Select User
                    Row(
                      children: [
                        Text(
                          'TPSelectUser'.tr(),
                          style: AppFontStyle.roboto16,
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButton<int>(
                            borderRadius: BorderRadius.circular(12),
                            dropdownColor: colorScheme.primaryContainer,
                            value: _controller.userId,
                            items: _controller.users
                                .map(
                                  (user) => DropdownMenuItem<int>(
                                    value: user.id!,
                                    child: Text(user.name),
                                  ),
                                )
                                .toList(),
                            onChanged: _controller.selectUser,
                          ),
                        ),
                      ],
                    ),
                    if (_controller.user != null)
                      UserCard(
                        isChecked: true,
                        user: _controller.user!,
                      ),
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceAround,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _controller.haveTrainingSelected
                              ? _removeSelected
                              : null,
                          label: Text('GenericRemove'.tr()),
                          icon: const Icon(Icons.delete),
                        ),
                        _allSelected
                            ? OutlinedButton.icon(
                                onPressed: _controller.haveTrainingSelected
                                    ? _deselectAllTraining
                                    : null,
                                label: Text('TPDeselectAll'.tr()),
                                icon: const Icon(Icons.deselect),
                              )
                            : OutlinedButton.icon(
                                onPressed: _selectAllTraining,
                                label: Text('TPSelectAll'.tr()),
                                icon: const Icon(Icons.select_all),
                              ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.primary,
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'TPTrainings'.tr(),
                                style: AppFontStyle.roboto18SemiBold,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListView.builder(
                                  itemCount: _controller.trainings.length,
                                  itemBuilder: (context, index) {
                                    final revIndex =
                                        trainings.length - index - 1;
                                    return DismissibleTraining(
                                      training: trainings[revIndex],
                                      editTraining: _editTraining,
                                      removeTraining: _removeTraining,
                                      onTapSelect: _controller.selectTraining,
                                      selected: _controller
                                          .selectedTraining[revIndex].selected,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              // Trainings Page State Error...
              default:
                return Center(
                  child: Text('TPError'.tr()),
                );
            }
          },
        ),
      ),
    );
  }
}
