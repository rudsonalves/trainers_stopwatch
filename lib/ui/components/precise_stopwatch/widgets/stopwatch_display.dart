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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/application/stopwatch/bloc/stopwatch_bloc.dart';
import '/application/stopwatch/bloc/stopwatch_state.dart';
import '../../theme/app_font_style.dart';

class StopwatchDisplay extends StatelessWidget {
  final StopwatchBloc bloc;

  const StopwatchDisplay({
    super.key,
    required this.bloc,
  });

  String formatCs(Duration duration) {
    final durationStr = duration.toString();
    final point = durationStr.indexOf('.');
    return durationStr.substring(0, point + 3);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 1,
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: BlocBuilder<StopwatchBloc, StopwatchState>(
        bloc: bloc,
        builder: (context, state) => Text(
          formatCs(state.elapsed),
          style: AppFontStyle.ibm26.copyWith(
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
