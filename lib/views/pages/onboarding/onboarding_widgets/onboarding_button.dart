import 'package:flutter/material.dart';
import 'package:budgify/core/constants/app_constants.dart';
import 'package:budgify/core/themes/app_colors.dart';

class OnBoardingButton extends StatelessWidget {
  final VoidCallback onNext;
  final String label;

  const OnBoardingButton({super.key, required this.onNext, required this.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onNext,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.buttonVerticalPadding,
          horizontal: AppConstants.buttonHorizontalPadding * 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
        ),
        backgroundColor: AppColors.accentColor,
        foregroundColor: Colors.white,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: AppConstants.buttonFontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}