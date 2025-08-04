// UPDATED: Import the new responsive utility
import 'package:budgify/core/utils/scale_config.dart';
import 'package:flutter/material.dart';
import 'package:budgify/core/themes/app_colors.dart';

class ProgressRow extends StatelessWidget {
  final double progress;
  final String label;
  final String amount;
  final Color progressColor;
  final String? type;

  const ProgressRow({
    super.key,
    required this.progress,
    required this.label,
    required this.amount,
    required this.progressColor,
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    // UPDATED: Use the new responsive extension
    final responsive = context.responsive;
    final safeProgress = progress.isNaN ? 0.0 : progress.clamp(0.0, 1.0);

    final progressBarWidth =
        responsive.isTablet
            ? responsive.widthPercent(0.4)
            : responsive.widthPercent(0.45);

    final progressBarHeight =
        responsive.isTablet
            ? responsive.setHeight(22)
            : responsive.setHeight(20);

    final borderRadius = responsive.setWidth(10);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: responsive.setHeight(2)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: progressBarWidth,
              minWidth: progressBarWidth,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      width: constraints.maxWidth,
                      height: progressBarHeight,
                      decoration: BoxDecoration(
                        color: _getBackgroundColor(label),
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                    ),
                    Container(
                      width: constraints.maxWidth * safeProgress,
                      height: progressBarHeight,
                      decoration: BoxDecoration(
                        gradient: _getProgressGradient(type),
                        borderRadius: BorderRadius.circular(borderRadius),
                        boxShadow: [
                          if (safeProgress > 0.05)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 2,
                              offset: const Offset(1, 1),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(String label) {
    if (label == "Savings Card" || label == 'Spent') {
      return AppColors.accentColor.withOpacity(0.9);
    }
    return Colors.black.withOpacity(0.9);
  }

  LinearGradient _getProgressGradient(String? type) {
    if (type == "Cash" || type == "Bank" || type == "Digital") {
      return const LinearGradient(
        colors: [AppColors.accentColor, Color.fromARGB(255, 0, 124, 140)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    }
    return const LinearGradient(
      colors: [AppColors.accentColor2, Color.fromARGB(255, 183, 44, 2)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }
}
