import 'package:budgify/core/utils/scale_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // For translations if needed

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
    final scaleConfig = ScaleConfig(context);
    final theme = Theme.of(context);

    return PopupMenuButton<int>(
      tooltip: 'View type',
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCurrentIcon(),
            color: Colors.white,
            size: scaleConfig.scale(17),
          ),
          SizedBox(width: scaleConfig.scale(1)),
          Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
            size: scaleConfig.scale(21),
          ),
        ],
      ),
      onSelected: onChanged,
      color: theme.appBarTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      offset: Offset(0, scaleConfig.scale(40)),
      itemBuilder: (context) => [
        _buildMenuItem(
          context,
          value: 0,
          icon: Icons.list,
          label: 'List View'.tr, // Using translation
          scaleConfig: scaleConfig,
        ),
        _buildMenuItem(
          context,
          value: 1,
          icon: Icons.grid_view,
          label: 'Grid View'.tr,
          scaleConfig: scaleConfig,
        ),
        _buildMenuItem(
          context,
          value: 2,
          icon: Icons.table_chart,
          label: 'Table View'.tr,
          scaleConfig: scaleConfig,
        ),
      ],
    );
  }

  PopupMenuItem<int> _buildMenuItem(
    BuildContext context, {
    required int value,
    required IconData icon,
    required String label,
    required ScaleConfig scaleConfig,
  }) {
    return PopupMenuItem<int>(
      value: value,
      height: scaleConfig.scale(40),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: scaleConfig.scale(16),
          ),
          SizedBox(width: scaleConfig.scale(10)),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: scaleConfig.scaleText(13),
            ),
          ),
        ],
      ),
    );
  }
}