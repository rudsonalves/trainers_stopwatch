import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/theme/app_font_style.dart';
import '../../models/training_model.dart';
import '../widgets/common/dismissible_backgrounds.dart';
import 'trainings_page_controller.dart';
import 'trainings_page_state.dart';

class TrainingsPage extends StatefulWidget {
  const TrainingsPage({super.key});

  static const routeName = '/trainings';

  @override
  State<TrainingsPage> createState() => _TrainingsPageState();
}

class _TrainingsPageState extends State<TrainingsPage> {
  final _controller = TrainingsPageController();
  int? athleteId;

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  Future<void> _editTraining(TrainingModel training) async {
    print('Edit....');
  }

  Future<bool> _removeTraining(TrainingModel training) async {
    _controller.removeTraining(training);
    return false;
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
                          'Athlete:',
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
                    const SizedBox(height: 12),
                    Expanded(
                      child: Card(
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Tranings',
                                style: AppFontStyle.roboto18SemiBold,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListView.builder(
                                  itemCount: _controller.trainings.length,
                                  itemBuilder: (context, index) {
                                    return DismissibleTraining(
                                      training: _controller.trainings[index],
                                      editTraining: _editTraining,
                                      removeTraining: _removeTraining,
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

class DismissibleTraining extends StatelessWidget {
  final TrainingModel training;
  final Future<void> Function(TrainingModel training) editTraining;
  final Future<bool> Function(TrainingModel training) removeTraining;

  const DismissibleTraining({
    super.key,
    required this.training,
    required this.editTraining,
    required this.removeTraining,
  });

  (String title, String subtitle) _mountListTile(TrainingModel training) {
    final date = training.date;
    String title = '${DateFormat.yMMMEd().format(date)} - '
        '${DateFormat.Hm().format(date)}';
    String subtitle = training.comments ?? '';
    if (subtitle.isEmpty) {
      subtitle =
          'Distances: Lap ${training.lapLength} ${training.distanceUnit}  '
          'Split ${training.splitLength} ${training.distanceUnit}';
    }

    return (title, subtitle);
  }

  @override
  Widget build(BuildContext context) {
    String title;
    String subtitle;

    (title, subtitle) = _mountListTile(training);

    return Dismissible(
      background: DismissibleContainers.background(context),
      secondaryBackground: DismissibleContainers.secondaryBackground(context),
      key: GlobalKey(),
      child: Card(
        elevation: 5,
        child: ListTile(
          title: Text(
            title,
          ),
          subtitle: Text(subtitle),
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await editTraining(training);
        } else if (direction == DismissDirection.endToStart) {
          await removeTraining(training);
        }
        return false;
      },
    );
  }
}
