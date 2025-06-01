import 'package:flutter/material.dart';
import 'package:budgify/core/constants/app_constants.dart';
import 'package:budgify/core/constants/onboarding_data.dart';
import 'package:budgify/core/themes/app_colors.dart';

class OnBoardingDots extends StatelessWidget {
  final int currentPage;

  const OnBoardingDots({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(onBoardingList.length, (index) {
        return AnimatedContainer(
          duration: AppConstants.dotAnimationDuration,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: AppConstants.dotSize,
          width: index == currentPage ? AppConstants.dotSize * 2 : AppConstants.dotSize,
          decoration: BoxDecoration(
            color: currentPage == index ? AppColors.accentColor : Colors.grey,
            borderRadius: BorderRadius.circular(AppConstants.dotSize),
          ),
        );
      }),
    );
  }
}