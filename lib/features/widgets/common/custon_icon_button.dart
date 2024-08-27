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

import '../../../common/singletons/app_settings.dart';
import '../../../common/theme/app_font_style.dart';

class CustomIconButton extends StatelessWidget {
  final void Function()? onPressed;
  final void Function()? onLongPressed;
  final FocusNode? focusNode;
  final String? label;
  final Widget icon;

  const CustomIconButton({
    super.key,
    this.onPressed,
    this.onLongPressed,
    required this.icon,
    this.label,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final app = AppSettings.instance;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: Focus(
        focusNode: focusNode,
        child: ValueListenableBuilder(
          valueListenable: app.brightnessMode,
          builder: (context, value, _) => Card(
            elevation: 2,
            margin: EdgeInsets.zero,
            color: value == Brightness.light
                ? colorScheme.onPrimary.withOpacity(0.3)
                : colorScheme.primary.withOpacity(0.2),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(5),
              child: InkWell(
                borderRadius: BorderRadius.circular(5),
                onLongPress: onLongPressed,
                onTap: onPressed,
                child: SizedBox(
                  width: 48,
                  height: label == null ? 48 : 54,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: label != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              icon,
                              const SizedBox(height: 2),
                              Text(
                                label!,
                                style: AppFontStyle.roboto12,
                              ),
                            ],
                          )
                        : icon,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
