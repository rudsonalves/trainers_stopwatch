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
    _controller.init();

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
    final result = await GenericDialog.callDialog(
      context,
      title: 'Delete Athlete',
      message: 'When removing an athlete all their training data will be lost.'
          '\n\nDo you confirm the removal?',
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
          title: const Text('Athletes List'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListenableBuilder(
                listenable: _controller,
                builder: (context, child) {
                  switch (_controller.state) {
                    case AthletesPageStateLoading():
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    case AthletesPageStateSuccess():
                      final athletes = _controller.athletes;
                      if (athletes.isEmpty) {
                        return const Center(
                          child: Text('Register some athletes to start'),
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
                    default:
                      return const Text('Error!');
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
