import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgify/core/constants/app_constants.dart';
import 'package:budgify/core/constants/onboarding_data.dart';
import 'package:budgify/core/utils/snackbar_helper.dart';
import 'package:budgify/views/navigation/bottom_nativgation/bottom_navigation_bar.dart';
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
  late final SettingsRepository _settingsRepository;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    SharedPreferences.getInstance().then((prefs) {
      _settingsRepository = SettingsRepository(prefs);
      _verifyInitialState();
    });
  }

  Future<void> _verifyInitialState() async {
    debugPrint('OnBoarding: Initial state at ${DateTime.now()}');
    debugPrint(
      'OnBoarding: onboarding_completed: ${await _settingsRepository.isOnboardingCompleted()}',
    );
    debugPrint(
      'OnBoarding: Currency: ${await _settingsRepository.getCurrency()}',
    );
    debugPrint(
      'OnBoarding: Language: ${await _settingsRepository.getLanguage()}',
    );
    debugPrint(
      'OnBoarding: Switch state: ${await _settingsRepository.getSwitchState()}',
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_currentPage == 0) {
      final language = ref.read(languageProvider).languageCode;
      if (language.isEmpty) {
        showFeedbackSnackbar(context, 'Please select a language');
        return;
      }
    } else if (_currentPage == 2) {
      final currentCurrency = ref.read(currencyProvider).currencySymbol;
      if (currentCurrency.isEmpty) {
        showFeedbackSnackbar(context, 'Please Choose the Currency Symbol');

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
      await _settingsRepository.saveSettings(
        currency: ref.read(currencyProvider).currencySymbol,
        languageCode: ref.read(languageProvider).languageCode,
        isSwitched: ref.read(switchProvider).isSwitched,
      );
      await _settingsRepository.setOnboardingCompleted(true);

      debugPrint(
        'OnBoarding: Final settings - Currency: ${await _settingsRepository.getCurrency()}, Language: ${await _settingsRepository.getLanguage()}, Switch: ${await _settingsRepository.getSwitchState()}',
      );

      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const Bottom()));
        debugPrint(
          'OnBoarding: Navigated to Bottom screen at ${DateTime.now()}',
        );
      }
    } catch (e) {
      debugPrint('OnBoarding: Error completing onboarding: $e');
      // ignore: use_build_context_synchronously
      showFeedbackSnackbar(context, 'Error saving settings. Please try again.');
    }
  }

  void _goToNextPage() {
    setState(() => _currentPage++);
    _pageController.animateToPage(
      _currentPage,
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
              child: OnBoardingSlider(pageController: _pageController),
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
                    label: isLastPage ? 'Get Started' : 'Next',
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
    required String currency,
    required String languageCode,
    required bool isSwitched,
  }) async {
    try {
      await Future.wait([
        _prefs.setString(AppConstants.currencyKey, currency),
        _prefs.setString(AppConstants.languageKey, languageCode),
        _prefs.setBool(AppConstants.switchStateKey, isSwitched),
      ]);

      await _prefs.reload();
      if (_prefs.getString(AppConstants.currencyKey) != currency ||
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

  Future<bool> isOnboardingCompleted() async {
    await _prefs.reload();
    return _prefs.getBool(AppConstants.onboardingCompletedKey) ?? false;
  }

  Future<String> getCurrency() async {
    await _prefs.reload();
    return _prefs.getString(AppConstants.currencyKey) ?? '';
  }

  Future<String> getLanguage() async {
    await _prefs.reload();
    return _prefs.getString(AppConstants.languageKey) ?? 'en';
  }

  Future<bool> getSwitchState() async {
    await _prefs.reload();
    return _prefs.getBool(AppConstants.switchStateKey) ?? false;
  }
}