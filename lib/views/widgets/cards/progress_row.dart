import 'package:budgify/core/utils/scale_config.dart';
import 'package:flutter/material.dart';
import 'package:budgify/core/themes/app_colors.dart';

class ProgressRow extends StatelessWidget {
  final double progress; // Progress in percentage (0.0 to 1.0)
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
    final scale = context.scaleConfig;
    final safeProgress = progress.isNaN ? 0.0 : progress.clamp(0.0, 1.0);

    // Responsive sizing
    final progressBarWidth =
        scale.isTablet
            ? scale.widthPercentage(0.4) // Wider on tablets
            : scale.widthPercentage(0.45); // Slightly narrower on phones

    final progressBarHeight =
        scale.isTablet
            ? scale.scale(22) // Slightly taller on tablets
            : scale.scale(20);

    final borderRadius = scale.scale(10);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: scale.scale(2)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: progressBarWidth,
              minWidth: progressBarWidth, // Ensure consistent width
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Background container
                    Container(
                      width: constraints.maxWidth,
                      height: progressBarHeight,
                      decoration: BoxDecoration(
                        color: _getBackgroundColor(label),
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                    ),
                    // Foreground progress bar
                    Container(
                      width: constraints.maxWidth * safeProgress,
                      height: progressBarHeight,
                      decoration: BoxDecoration(
                        gradient: _getProgressGradient(type),
                        borderRadius: BorderRadius.circular(borderRadius),
                        boxShadow: [
                          if (safeProgress >
                              0.05) // Only add shadow if progress is visible
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

          // Amount display with responsive sizing
          // if (amount.isNotEmpty)
          //   SizedBox(
          //     width: scale.isTablet
          //         ? scale.widthPercentage(1)
          //         : scale.widthPercentage(0.2),
          //     child: Text(
          //       amount,
          //       style: TextStyle(
          //         fontSize: scale.scaleText(scale.isTablet ? 13 : 14),
          //         fontWeight: FontWeight.w500,
          //       ),
          //       maxLines: 1,
          //       overflow: TextOverflow.ellipsis,
          //     ),
          //   ),
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
      return LinearGradient(
        colors: [AppColors.accentColor, const Color.fromARGB(255, 0, 124, 140)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    }
    return LinearGradient(
      colors: [AppColors.accentColor2, const Color.fromARGB(255, 183, 44, 2)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }
}
