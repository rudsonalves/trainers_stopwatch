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

import '../../../../common/theme/app_font_style.dart';

class CounterRow extends StatelessWidget {
  const CounterRow({
    super.key,
    required this.counter,
    required this.label,
  });

  final ValueNotifier<int> counter;
  final String label;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppFontStyle.roboto12,
        ),
        const SizedBox(width: 8),
        ValueListenableBuilder(
          valueListenable: counter,
          builder: (context, value, _) => Text(
            value.toString(),
            style: AppFontStyle.ibm14SemiBold.copyWith(
              color: primary,
            ),
          ),
        ),
      ],
    );
  }
}
