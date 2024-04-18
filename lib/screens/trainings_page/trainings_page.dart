import 'package:flutter/material.dart';

import '../../common/theme/app_font_style.dart';
import '../../models/athlete_model.dart';
import '../../models/training_model.dart';
import '../widgets/common/athlete_card.dart';
import '../widgets/common/generic_dialog.dart';
import 'trainings_page_controller.dart';
import 'trainings_page_state.dart';
import 'widgets/dismissible_training.dart';
import 'widgets/edit_training_dialog.dart';

class TrainingsPage extends StatefulWidget {
  const TrainingsPage({super.key});

  static const routeName = '/trainings';

  @override
  State<TrainingsPage> createState() => _TrainingsPageState();
}

class _TrainingsPageState extends State<TrainingsPage> {
  final _controller = TrainingsPageController();
  AthleteModel? athlete;
  bool _allSelected = false;

  List<TrainingModel> get trainings => _controller.trainings;

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  Future<void> _editTraining(TrainingModel training) async {
    final result = await EditTrainingDialog.open(context, training);
    if (result) {
      _controller.updateTraining(training);
    }
  }

  Future<bool> _removeTraining(TrainingModel training) async {
    final result = await GenericDialog.open(
      context,
      title: 'Delete Training',
      message: 'Do you want to delete this training?',
      actions: DialogActions.yesNo,
    );

    if (result) {
      _controller.removeTraining(training);
    }
    return result;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainings'),
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
                    Row(
                      children: [
                        const Text(
                          'Select Athlete:',
                          style: AppFontStyle.roboto16,
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<int>(
                          value: _controller.athleteId,
                          items: _controller.athletes
                              .map(
                                (athlete) => DropdownMenuItem<int>(
                                  value: athlete.id!,
                                  child: Text(athlete.name),
                                ),
                              )
                              .toList(),
                          onChanged: _controller.selectAthlete,
                        ),
                      ],
                    ),
                    if (_controller.athlete != null)
                      AthleteCard(
                        isChecked: true,
                        athlete: _controller.athlete!,
                      ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Card(
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Trainings',
                                style: AppFontStyle.roboto18SemiBold,
                              ),
                            ),
                            ButtonBar(
                              alignment: MainAxisAlignment.spaceAround,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _controller.removeSelected,
                                  label: const Text('Remove'),
                                  icon: const Icon(Icons.delete),
                                ),
                                _allSelected
                                    ? OutlinedButton.icon(
                                        onPressed: _deselectAllTraining,
                                        label: const Text('Deselect'),
                                        icon: const Icon(Icons.deselect),
                                      )
                                    : OutlinedButton.icon(
                                        onPressed: _selectAllTraining,
                                        label: const Text('Select'),
                                        icon: const Icon(Icons.select_all),
                                      ),
                              ],
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
                return const Center(
                  child: Text('Error!!!'),
                );
            }
          },
        ),
      ),
    );
  }
}
