// lib/views/pages/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:budgify/core/constants/app_constants.dart';
import 'package:budgify/core/constants/onboarding_data.dart';
import 'package:budgify/core/utils/snackbar_helper.dart';
import 'package:budgify/core/navigation/bottom_nativgation/bottom_navigation_bar.dart';
import 'package:budgify/viewmodels/providers/currency_symbol.dart';
import 'package:budgify/viewmodels/providers/lang_provider.dart';
import 'package:budgify/viewmodels/providers/switchOnOffIncome.dart';
import 'onboarding_widgets/onboarding_button.dart';
import 'onboarding_widgets/onboarding_dots.dart';
import 'onboarding_widgets/onboarding_slider.dart';

class OnBoardingScreen extends ConsumerStatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  ConsumerState<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends ConsumerState<OnBoardingScreen> {
  late final PageController _pageController;
  late SettingsRepository _settingsRepository;
  int _currentPage = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initialize();
  }

  void _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _settingsRepository = SettingsRepository(prefs);
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (!_isInitialized) return; // Prevent action if not ready

    if (_currentPage == 0) {
      final language = ref.read(languageProvider).languageCode;
      if (language.isEmpty) {
        showFeedbackSnackbar(context, 'Please select a language'.tr);
        return;
      }
    }

    if (_currentPage == onBoardingList.length - 1) {
      await _completeOnboarding();
    } else {
      _goToNextPage();
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      // Get the full Currency object from the provider's state
      final selectedCurrency = ref.read(currencyProvider).displayCurrency;

      await _settingsRepository.saveSettings(
        currencyCode: selectedCurrency.code, // SAVING THE CODE
        languageCode: ref.read(languageProvider).languageCode,
        isSwitched: ref.read(switchProvider).isSwitched,
      );
      await _settingsRepository.setOnboardingCompleted(true);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const Bottom()),
        );
      }
    } catch (e) {
      debugPrint('OnBoarding: Error completing onboarding: $e');
      if (mounted) {
        showFeedbackSnackbar(
          context,
          'Error saving settings. Please try again.'.tr,
        );
      }
    }
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: AppConstants.pageTransitionDuration,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == onBoardingList.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: OnBoardingSlider(
                pageController: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMedium,
                vertical: AppConstants.spacingLarge,
              ),
              child: Column(
                children: [
                  OnBoardingDots(currentPage: _currentPage),
                  const SizedBox(height: AppConstants.spacingLarge * 2),
                  OnBoardingButton(
                    onNext: _next,
                    label: isLastPage ? 'Get Started'.tr : 'Next'.tr,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  Future<void> saveSettings({
    required String currencyCode,
    required String languageCode,
    required bool isSwitched,
  }) async {
    try {
      await Future.wait([
        _prefs.setString('currency_code', currencyCode), // Save the code
        _prefs.setString(AppConstants.languageKey, languageCode),
        _prefs.setBool(AppConstants.switchStateKey, isSwitched),
      ]);
      await _prefs.reload();
      if (_prefs.getString('currency_code') != currencyCode ||
          _prefs.getString(AppConstants.languageKey) != languageCode ||
          _prefs.getBool(AppConstants.switchStateKey) != isSwitched) {
        throw Exception('Failed to save settings');
      }
    } catch (e) {
      throw Exception('Error saving settings: $e');
    }
  }

  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool(AppConstants.onboardingCompletedKey, value);
    await _prefs.reload();
    if (_prefs.getBool(AppConstants.onboardingCompletedKey) != value) {
      throw Exception('Failed to set onboarding completed flag');
    }
  }
}
