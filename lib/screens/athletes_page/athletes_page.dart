import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:onboarding_overlay/onboarding_overlay.dart';

import '../../common/singletons/app_settings.dart';
import '../../models/athlete_model.dart';
import 'widgets/athlete_dialog/athlete_dialog.dart';
import '../stopwatch_page/stopwatch_page_controller.dart';
import '../widgets/common/generic_dialog.dart';
import 'athletes_page_controller.dart';
import 'athletes_page_state.dart';
import 'widgets/dismissible_athlete_tile.dart';

class AthletesPage extends StatefulWidget {
  const AthletesPage({
    super.key,
  });

  @override
  State<AthletesPage> createState() => _AthletesPageState();
}

class _AthletesPageState extends State<AthletesPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final app = AppSettings.instance;
  final _controller = AthletesPageController();
  final List<AthleteModel> _selectedAthletes = [];
  final List<int> _preSelectedAthleteIds = [];
  late final OnboardingState? overlay;

  @override
  void initState() {
    super.initState();
    _startingPage();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        overlay = Onboarding.of(context);
        _startTutorial();
      },
    );
  }

  void _startTutorial() {
    if (app.tutorialOn) {
      if (overlay != null) {
        overlay!.show();
      }
    }
  }

  Future<void> _startingPage() async {
    await _controller.init();

    final athletesList = StopwatchPageController.instance.athletesList;

    _preSelectedAthleteIds.addAll(
      athletesList.map(
        (athlete) => athlete.id!,
      ),
    );

    _selectedAthletes.addAll(athletesList);
  }

  Future<void> _addNewAthlete() async {
    final result = await AthleteDialog.open(
      context,
      addAthlete: _controller.addAthlete,
    );

    await Future.delayed(const Duration(milliseconds: 150));
    if (result != null && result) {
      _continueTutorial();
    } else {
      app.tutorialOn = false;
    }
  }

  Future<void> _continueTutorial() async {
    if (app.tutorialOn && mounted) {
      final overlay = Onboarding.of(context);
      if (overlay != null) {
        if (app.focusNodes[9].context?.mounted ?? false) {
          overlay.showFromIndex(4);
        } else {
          await Future.delayed(const Duration(microseconds: 100), () {
            if (app.focusNodes[9].context?.mounted ?? false) {
              overlay.showFromIndex(4);
            }
          });
        }
      }
    }
  }

  void _backPage() {
    // overlay!.deactivate();
    Navigator.pop(context);
  }

  void selectAthlete(bool select, AthleteModel athlete) {
    if (select) {
      _selectedAthletes.add(athlete);
    } else {
      _selectedAthletes.removeWhere((item) => item.id == athlete.id);
    }
  }

  Future<bool> editAthlete(AthleteModel athlete) async {
    final result = await AthleteDialog.open(
          context,
          athlete: athlete,
          addAthlete: _controller.updateAthlete,
        ) ??
        false;
    return result;
  }

  bool isSelected(AthleteModel athlete) {
    final list = _selectedAthletes.map((athlete) => athlete.id).toList();
    return list.contains(athlete.id!);
  }

  Future<bool> deleteAthlete(AthleteModel athlete) async {
    if (isSelected(athlete)) {
      await GenericDialog.open(
        context,
        title: 'APBlockedTitle'.tr(),
        message: 'APBlockedMsg'.tr(),
        actions: DialogActions.close,
      );
      return false;
    }

    final result = await GenericDialog.open(
      context,
      title: 'APDeleteAthlete'.tr(),
      message: 'APDeleteAthleteMsg'.tr(),
      actions: DialogActions.yesNo,
    );
    if (result) {
      _controller.deleteAthlete(athlete);
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        final stopwatchController = StopwatchPageController.instance;
        stopwatchController.addNewAthletes(_selectedAthletes);
      },
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          elevation: 5,
          title: Text('APAthleteList'.tr()),
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.menu),
              itemBuilder: (context) => <PopupMenuEntry>[
                PopupMenuItem(
                  onTap: () {
                    app.tutorialOn = true;
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
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListenableBuilder(
                listenable: _controller,
                builder: (context, child) {
                  switch (_controller.state) {
                    // Athletes Page State Loading
                    case AthletesPageStateLoading():
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    // Athletes Page State Success
                    case AthletesPageStateSuccess():
                      final athletes = _controller.athletes;
                      if (athletes.isEmpty) {
                        return Center(
                          child: Text('APRegisterSome'.tr()),
                        );
                      }
                      return Expanded(
                        child: ListView.builder(
                          itemCount: athletes.length,
                          itemBuilder: (context, index) => Focus(
                            focusNode: app.isTutorial(athletes[index].id!)
                                ? app.focusNodes[9]
                                : null,
                            child: DismissibleAthleteTile(
                              athlete: athletes[index],
                              selectAthlete: selectAthlete,
                              editFunction: editAthlete,
                              deleteFunction: deleteAthlete,
                              blockedAthleteIds: _preSelectedAthleteIds,
                              isChecked: _preSelectedAthleteIds.contains(
                                athletes[index].id!,
                              ),
                            ),
                          ),
                        ),
                      );
                    // Athletes Page State Error
                    default:
                      return Center(
                        child: Text(
                          'TPError'.tr(),
                        ),
                      );
                  }
                },
              ),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              focusNode: app.focusNodes[10],
              heroTag: 'fab1',
              onPressed: _backPage,
              child: Icon(
                Icons.arrow_back,
                color: primary.withOpacity(.5),
              ),
            ),
            const SizedBox(width: 18),
            FloatingActionButton(
              focusNode: app.focusNodes[8],
              heroTag: 'fab2',
              onPressed: _addNewAthlete,
              child: Icon(
                Icons.person_add,
                color: primary.withOpacity(.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
