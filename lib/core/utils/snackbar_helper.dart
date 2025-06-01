import 'package:budgify/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

const double kPadding = 16.0;
const double kCardRadius = 12.0;

void showFeedbackSnackbar(
  BuildContext context,
  String message, {
  bool isError = false,
  int durationSeconds = 3,
}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: isError ? AppColors.accentColor2 : AppColors.accentColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius * 0.8),
      ),
      margin: const EdgeInsets.all(kPadding),
      duration: Duration(seconds: durationSeconds),
    ),
  );
}
