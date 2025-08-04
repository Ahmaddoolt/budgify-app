import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';

class BottomNavIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const BottomNavIcon({
    super.key,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      isSelected ? icon : _getOutlinedIcon(icon),
      size: 30,
      color: isSelected ? AppColors.accentColor : AppColors.textColorDarkTheme,
    );
  }

  IconData _getOutlinedIcon(IconData originalIcon) {
    if (originalIcon == Icons.home) {
      return Icons.home_outlined;
    } else if (originalIcon == Icons.pie_chart) {
      return Icons.pie_chart_outline;
    } else if (originalIcon == Icons.widgets) {
      return Icons.widgets_outlined;
    } else if (originalIcon == Icons.settings_applications) {
      return Icons.settings_applications_outlined;
    } else {
      return originalIcon;
    }
  }
}
