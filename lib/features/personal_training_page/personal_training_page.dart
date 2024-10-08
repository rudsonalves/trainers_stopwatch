// Copyright (C) 2024 Rudson Alves
// 
// This file is part of trainers_stopwatch.
// 
// trainers_stopwatch is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// trainers_stopwatch is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with trainers_stopwatch.  If not, see <https://www.gnu.org/licenses/>.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../common/abstract_classes/history_controller.dart';
import '../../common/theme/app_font_style.dart';
import '../widgets/common/history_list_view.dart';
import '../widgets/precise_stopwatch/precise_stopwatch.dart';
import 'personal_training_controller.dart';

class PersonalTrainingPage extends StatefulWidget {
  final PreciseStopwatch stopwatch;

  const PersonalTrainingPage({
    super.key,
    required this.stopwatch,
  });

  static const routeName = '/training';

  static PersonalTrainingPage fromContext(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final stopwatch = args['stopwatch']! as PreciseStopwatch;

    return PersonalTrainingPage(
      stopwatch: stopwatch,
    );
  }

  @override
  State<PersonalTrainingPage> createState() => _PersonalTrainingPageState();
}

class _PersonalTrainingPageState extends State<PersonalTrainingPage> {
  late final PersonalTrainingController controller;

  @override
  void initState() {
    super.initState();
    controller = PersonalTrainingController(widget.stopwatch);
    controller.init(
      user: widget.stopwatch.controller.user,
      training: widget.stopwatch.controller.training,
      histories: widget.stopwatch.controller.histories,
    );
    controller.getHistory();
  }

  @override
  Widget build(BuildContext context) {
    final training = controller.training;
    final user = controller.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stopwatch.user.name),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PreciseStopwatch(
              user: widget.stopwatch.user,
              controller: widget.stopwatch.controller,
              isNotClone: false,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Split: ${training.splitLength} ${training.speedUnit}',
                style: AppFontStyle.roboto16,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Lap: ${training.lapLength} ${training.distanceUnit}',
                style: AppFontStyle.roboto16,
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    switch (controller.state) {
                      case StateLoading():
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      case StateSuccess():
                        return HistoryListView(
                          controller: controller,
                          user: user,
                          training: training,
                          histories: controller.histories,
                          updateHistory: controller.updateHistory,
                          deleteHistory: controller.deleteHistory,
                          reversed: true,
                        );
                      default:
                        return Center(
                          child: Text('TPError'.tr()),
                        );
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
