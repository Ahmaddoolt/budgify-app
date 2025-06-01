import 'package:budgify/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showExpenseContextMenu({
  required BuildContext context,
  required RenderBox row,
  required Function(String) onMenuSelected,
  required double scale,
}) {
  final Offset position = row.localToGlobal(Offset.zero);

  showMenu<String>(
    color: Theme.of(context).appBarTheme.backgroundColor,
    context: context,
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      position.dx + row.size.width,
      position.dy + row.size.height,
    ),
    items: [
      PopupMenuItem(
        value: 'update',
        child: Row(
          children: [
            Icon(
              Icons.edit,
              color: AppColors.accentColor,
              size: scale * 18,
            ),
            SizedBox(width: scale * 6),
            Text(
              'Update'.tr,
              style: TextStyle(fontSize: scale * 12),
            ),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(
              Icons.delete,
              color: Colors.red,
              size: scale * 18,
            ),
            SizedBox(width: scale * 6),
            Text(
              'Delete'.tr,
              style: TextStyle(fontSize: scale * 12),
            ),
          ],
        ),
      ),
    ],
  ).then((value) {
    if (value != null) onMenuSelected(value);
  });
}