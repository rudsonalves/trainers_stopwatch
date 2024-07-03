import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:onboarding_overlay/onboarding_overlay.dart';

import '../../common/functions/share_functions.dart';
import '../../common/icons/stopwatch_icons_icons.dart';
import '../../common/singletons/app_settings.dart';
import '../../common/theme/app_font_style.dart';
import '../../common/models/training_model.dart';
import '../history_page/history_page.dart';
import '../widgets/common/user_card.dart';
import '../widgets/common/generic_dialog.dart';
import 'trainings_page_controller.dart';
import 'trainings_page_state.dart';
import 'widgets/dismissible_training.dart';
import 'widgets/select_user_popup_menu.dart';

class TrainingsPage extends StatefulWidget {
  const TrainingsPage({super.key});

  @override
  State<TrainingsPage> createState() => _TrainingsPageState();
}

class _TrainingsPageState extends State<TrainingsPage> {
  final _controller = TrainingsPageController();
  late final OnboardingState? overlay;
  final app = AppSettings.instance;

  List<TrainingModel> get trainings => _controller.trainings;

  @override
  void initState() {
    super.initState();
    _controller.init();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        overlay = Onboarding.of(context);
      },
    );
  }

  void _startTutorial() {
    if (overlay != null) {
      overlay!.show();
    }
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
    _controller.selectAllTraining();
  }

  void _deselectAllTraining() {
    _controller.deselectAllTraining();
  }

  void _sendEmail() {
    final trainings = <TrainingModel>[];
    for (final item in _controller.selectedTraining) {
      if (item.selected) {
        trainings.add(
          _controller.trainings.firstWhere((t) => t.id == item.trainingId),
        );
      }
    }

    AppShare.sendEmail(
      user: _controller.user!,
      recipient: _controller.user!.email,
      trainings: trainings,
    );
  }

  void _sendWhatsApp() {
    final trainings = <TrainingModel>[];
    for (final item in _controller.selectedTraining) {
      if (item.selected) {
        trainings.add(
          _controller.trainings.firstWhere((t) => t.id == item.trainingId),
        );
      }
    }

    AppShare.sendWhatsApp(
      user: _controller.user!,
      trainings: trainings,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('TPTitle'.tr()),
        elevation: 5,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.menu),
            itemBuilder: (context) => <PopupMenuEntry>[
              PopupMenuItem(
                onTap: () {
                  _startTutorial();
                },
                child: const ListTile(
                  leading: Icon(Icons.question_mark),
                  title: Text('Tutorial'),
                ),
              ),
            ],
          ),
        ],
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
                    SelectUserPopupMenu(
                      colorScheme: colorScheme,
                      controller: _controller,
                    ),
                    if (_controller.user != null)
                      UserCard(
                        isChecked: true,
                        user: _controller.user!,
                      ),
                    Focus(
                      focusNode: app.focusNodes[25],
                      child: ButtonBar(
                        alignment: MainAxisAlignment.spaceAround,
                        children: [
                          MenuAnchor(
                            builder: (context, controller, child) {
                              return IconButton.filledTonal(
                                focusNode: app.focusNodes[28],
                                onPressed: _controller.haveTrainingSelected
                                    ? () {
                                        if (controller.isOpen) {
                                          controller.close();
                                        } else {
                                          controller.open();
                                        }
                                      }
                                    : null,
                                icon: const Icon(Icons.share),
                                tooltip: 'Show menu',
                              );
                            },
                            menuChildren: [
                              MenuItemButton(
                                onPressed: _sendEmail,
                                child: const Row(
                                  children: [
                                    Icon(
                                      StopwatchIcons.mail,
                                      color: Colors.amber,
                                    ),
                                    SizedBox(width: 12),
                                    Text('Email'),
                                  ],
                                ),
                              ),
                              MenuItemButton(
                                onPressed: _sendWhatsApp,
                                child: const Row(
                                  children: [
                                    Icon(
                                      StopwatchIcons.whatsapp,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 12),
                                    Text('WhatsApp'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          IconButton.filledTonal(
                            focusNode: app.focusNodes[27],
                            onPressed: _controller.haveTrainingSelected
                                ? _removeSelected
                                : null,
                            tooltip: 'GenericRemove'.tr(),
                            icon: const Icon(Icons.delete),
                          ),
                          _controller.areAllSelecting()
                              ? IconButton.filledTonal(
                                  focusNode: app.focusNodes[26],
                                  onPressed: _controller.haveTrainingSelected
                                      ? _deselectAllTraining
                                      : _controller.trainings.isEmpty
                                          ? null
                                          : _selectAllTraining,
                                  tooltip: 'TPDeselectAll'.tr(),
                                  icon: const Icon(Icons.deselect),
                                )
                              : IconButton.filledTonal(
                                  focusNode: app.focusNodes[26],
                                  onPressed: _controller.trainings.isEmpty
                                      ? null
                                      : _selectAllTraining,
                                  tooltip: 'TPSelectAll'.tr(),
                                  icon: const Icon(Icons.select_all),
                                ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.secondaryContainer,
                          ),
                        ),
                        child: Focus(
                          focusNode: app.focusNodes[24],
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
                                            .selectedTraining[revIndex]
                                            .selected,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
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
