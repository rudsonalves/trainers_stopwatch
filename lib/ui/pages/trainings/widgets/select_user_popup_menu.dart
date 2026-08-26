import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '/common/theme/app_font_style.dart';
import '/domain/common/user/models/user.dart';

class SelectUserPopupMenu extends StatelessWidget {
  final ColorScheme colorScheme;
  final List<User> users;
  final int? selectedUserId;
  final ValueChanged<int?> onSelected;
  final bool enabled;

  const SelectUserPopupMenu({
    super.key,
    required this.colorScheme,
    required this.users,
    required this.selectedUserId,
    required this.onSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text('TPSelectUser'.tr(), style: AppFontStyle.roboto16),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<int>(
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                dropdownColor: colorScheme.primaryContainer,
                value: selectedUserId,
                items: users
                    .where((user) => user.id != null)
                    .map((user) => DropdownMenuItem<int>(
                          value: user.id,
                          child:
                              Text(user.name, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: enabled ? onSelected : null,
              ),
            ),
          ),
        ],
      );
}
