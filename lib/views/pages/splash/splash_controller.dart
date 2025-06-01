import 'package:budgify/core/constants/app_constants.dart';
import 'package:budgify/initialization.dart';
import 'package:budgify/views/navigation/app_routes.dart';
import 'package:budgify/views/navigation/bottom_nativgation/bottom_navigation_bar.dart';
import 'package:budgify/views/pages/alarm/alarmservices/alarm_display_service.dart';
import 'package:budgify/views/pages/onboarding/onboarding_screen.dart';
import 'package:budgify/views/pages/splash/splash_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class SplashController {
  static const _kSplashDelay = Duration(milliseconds: 1200);
  static const _kPrefsLoadDelay = Duration(milliseconds: 500);

  final hasError = ValueNotifier<bool>(false);
  final isInitialized = ValueNotifier<bool>(false);
  final _service = SplashService();

  Future<void> initializeAndNavigate(BuildContext context, WidgetRef ref) async {
    debugPrint('SplashController: Starting initialization at ${DateTime.now()}.');
    try {
      await Future.delayed(_kPrefsLoadDelay);
      await sharedPreferences.reload();
      debugPrint('SplashController: SharedPreferences reloaded.');

      final shouldShowAlarm = await _service.checkAlarmState();
      if (shouldShowAlarm) return;

      await _service.checkFirstLaunchStatus();
      await _service.performHeavyInitialization(ref);

      final shouldStillShowAlarm = await _service.checkAlarmState();
      if (shouldStillShowAlarm) return;

      await Future.delayed(_kSplashDelay);
      await _handleNormalNavigation(context);
    } catch (e, s) {
      debugPrint("SplashController: CRITICAL - Initialization failed: $e\nStack: $s");
      if (context.mounted) {
        hasError.value = true;
      }
    } finally {
      if (context.mounted) {
        isInitialized.value = true;
      }
    }
  }

  Future<void> retryInitialization(BuildContext context, WidgetRef ref) async {
    try {
      await sharedPreferences.clear();
      await sharedPreferences.setBool('first_launch', true);
      hasError.value = false;
      await initializeAndNavigate(context, ref);
    } catch (e) {
      debugPrint('SplashController: Retry failed: $e');
    }
  }

  Future<void> _handleNormalNavigation(BuildContext context) async {
    if (!context.mounted) return;

    await sharedPreferences.reload();
    final onboardingCompleted =
        sharedPreferences.getBool(AppConstants.onboardingCompletedKey) ?? false;
    debugPrint('SplashController: Onboarding completed status: $onboardingCompleted');

    final currency = sharedPreferences.getString('currency');
    final language = sharedPreferences.getString('language');
    final switchState = sharedPreferences.getBool('switchState');
    debugPrint('SplashController: Settings - currency: $currency, language: $language, switchState: $switchState');

    _navigateTo(context, onboardingCompleted ? const Bottom() : const OnBoardingScreen());
  }

  void _navigateTo(BuildContext context, Widget page) {
    if (!context.mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await sharedPreferences.reload();
      bool isAlarmActive = sharedPreferences.getBool(AlarmDisplayService.prefsKeyIsAlarmScreenActive) ?? false;

      if (isAlarmActive) {
        int? alarmId = sharedPreferences.getInt('current_ringing_alarm_id');
        String? alarmTitle = sharedPreferences.getString('current_ringing_alarm_title');
        if (alarmId != null && alarmTitle != null && Get.currentRoute != YourAppRoutes.alarmScreen) {
          debugPrint('SplashController: Alarm active. Navigating to AlarmScreen.');
          Get.offAllNamed(YourAppRoutes.alarmScreen, arguments: {'id': alarmId, 'title': alarmTitle});
          return;
        }
      }

      Get.offAll(() => page, transition: Transition.fade);
      debugPrint('SplashController: Navigated to ${page.runtimeType}.');
    });
  }
}