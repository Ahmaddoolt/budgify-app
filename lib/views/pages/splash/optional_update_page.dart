import 'package:budgify/core/constants/app_constants.dart';
import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/initialization.dart';
import 'package:budgify/core/navigation/bottom_nativgation/bottom_navigation_bar.dart';
import 'package:budgify/views/pages/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class OptionalUpdatePage extends StatelessWidget {
  final String storeUrl;

  const OptionalUpdatePage({
    super.key,
    required this.storeUrl,
  });

  // Helper to launch the store URL
  Future<void> _launchStoreUrl() async {
    if (storeUrl.isEmpty) return;
    final uri = Uri.parse(storeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // Helper to skip the update and navigate to the main app
  void _skipAndUpdate() {
    // This logic determines where the user should go after skipping.
    final onboardingCompleted =
        sharedPreferences.getBool(AppConstants.onboardingCompletedKey) ?? false;
    
    Get.offAll(() =>
        onboardingCompleted ? const Bottom() : const OnBoardingScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // **ADD a Lottie file to your assets folder named 'update_animation.json'**
              // You can find great animations on lottiefiles.com
              Lottie.asset(
                'assets/money_s.json', 
                height: 250,
              ),
              const SizedBox(height: 32),
              Text(
                'Update Available'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ve added new features and fixed some bugs to improve your experience. Update now to get the best of Budgify!'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),

              // "Update Now" Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _launchStoreUrl,
                child: Text(
                  'Update Now'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // "Skip" Button
              TextButton(
                onPressed: _skipAndUpdate,
                child: Text(
                  'Maybe Later'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}