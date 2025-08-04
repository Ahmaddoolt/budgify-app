// UPDATED: Import the new responsive utility
import 'package:budgify/core/utils/scale_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ViewTypeSelector extends StatelessWidget {
  final int chartType;
  final void Function(int?)? onChanged;

  const ViewTypeSelector({
    super.key,
    required this.chartType,
    required this.onChanged,
  });

  IconData _getCurrentIcon() {
    switch (chartType) {
      case 0:
        return Icons.list;
      case 1:
        return Icons.grid_view;
      case 2:
        return Icons.table_chart;
      default:
        return Icons.list;
    }
  }

  @override
  Widget build(BuildContext context) {
    // UPDATED: Use the new responsive extension
    final responsive = context.responsive;
    final theme = Theme.of(context);

    return PopupMenuButton<int>(
      tooltip: 'View type',
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCurrentIcon(),
            color: Colors.white,
            // UPDATED: Use setWidth for general scaling like icon size
            size: responsive.setWidth(17),
          ),
          SizedBox(width: responsive.setWidth(1)),
          Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
            size: responsive.setWidth(21),
          ),
        ],
      ),
      onSelected: onChanged,
      color: theme.appBarTheme.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      // UPDATED: Use setHeight for vertical offset
      offset: Offset(0, responsive.setHeight(40)),
      itemBuilder:
          (context) => [
            _buildMenuItem(
              context,
              value: 0,
              icon: Icons.list,
              label: 'List View'.tr,
              // UPDATED: Pass the new responsive object
              responsive: responsive,
            ),
            _buildMenuItem(
              context,
              value: 1,
              icon: Icons.grid_view,
              label: 'Grid View'.tr,
              responsive: responsive,
            ),
            _buildMenuItem(
              context,
              value: 2,
              icon: Icons.table_chart,
              label: 'Table View'.tr,
              responsive: responsive,
            ),
          ],
    );
  }

  PopupMenuItem<int> _buildMenuItem(
    BuildContext context, {
    required int value,
    required IconData icon,
    required String label,
    // UPDATED: The helper method now expects the ResponsiveUtil object
    required ResponsiveUtil responsive,
  }) {
    return PopupMenuItem<int>(
      value: value,
      // UPDATED: Use setHeight for item height
      height: responsive.setHeight(40),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            // UPDATED: Use setWidth for icon size
            size: responsive.setWidth(16),
          ),
          // UPDATED: Use setWidth for horizontal spacing
          SizedBox(width: responsive.setWidth(10)),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              // UPDATED: Use setSp for font size
              fontSize: responsive.setSp(13),
            ),
          ),
        ],
      ),
    );
  }
}
