import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../models/athlete_model.dart';
import '../athlete_dialog/athlete_dialog.dart';
import '../stopwatch_page/stopwatch_page_controller.dart';
import '../widgets/common/generic_dialog.dart';
import 'athletes_page_controller.dart';
import 'athletes_page_state.dart';
import 'widgets/dismissible_athlete_tile.dart';

class AthletesPage extends StatefulWidget {
  const AthletesPage({
    super.key,
  });

  static const routeName = '/athletes';

  @override
  State<AthletesPage> createState() => _AthletesPageState();
}

class _AthletesPageState extends State<AthletesPage> {
  final _controller = AthletesPageController();
  final List<AthleteModel> _selectedAthletes = [];
  final List<int> _preSelectedAthleteIds = [];

  @override
  void initState() {
    super.initState();
    _startingPage();
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

  void _addNewAthlete() {
    AthleteDialog.open(
      context,
      sueAthlete: _controller.addAthlete,
    );
  }

  void _backPage() {
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
          sueAthlete: _controller.updateAthlete,
        ) ??
        false;
    return result;
  }

  Future<bool> deleteAthlete(AthleteModel athlete) async {
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
        appBar: AppBar(
          elevation: 5,
          title: Text('APAthleteList'.tr()),
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
                          itemBuilder: (context, index) =>
                              DismissibleAthleteTile(
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
              heroTag: 'fab1',
              onPressed: _backPage,
              child: Icon(
                Icons.arrow_back,
                color: primary.withOpacity(.5),
              ),
            ),
            const SizedBox(width: 18),
            FloatingActionButton(
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
