import 'package:budgify/views/pages/onboarding/onboarding_widgets/currency_dropdown.dart';
import 'package:budgify/views/pages/onboarding/onboarding_widgets/income_switch.dart';
import 'package:budgify/views/pages/onboarding/onboarding_widgets/language_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:budgify/core/constants/app_constants.dart';
import 'package:budgify/core/constants/onboarding_data.dart';

class OnBoardingSlider extends StatelessWidget {
  final PageController pageController;

  const OnBoardingSlider({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      itemCount: onBoardingList.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = onBoardingList[index];
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              item.image,
              height: AppConstants.lottieSize,
              width: AppConstants.lottieSize,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: AppConstants.spacingLarge),
            Text(
              item.title.tr,
              style: const TextStyle(
                fontSize: AppConstants.titleFontSize,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              item.body.tr,
              textAlign: TextAlign.center,
              maxLines: AppConstants.maxBodyLines,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w800,
              ),
            ),
            if (index == 0) const LanguageDropdown(),
            if (index == 1) const IncomeSwitch(),
            if (index == 2) const CurrencyDropdown(),
            if (index == 3)
              const SizedBox(height: AppConstants.spacingMedium * 2),
          ],
        );
      },
    );
  }
}