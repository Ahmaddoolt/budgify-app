import 'dart:async';
import 'package:budgify/initialization.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:budgify/core/constants/app_constants.dart';
import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/data/services/hive_services.dart/app_update_service.dart';
import 'package:budgify/core/navigation/bottom_nativgation/bottom_navigation_bar.dart';
import 'package:budgify/views/pages/onboarding/onboarding_screen.dart';
import 'package:budgify/views/pages/splash/optional_update_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashController {
  static const _kSplashDelay = Duration(milliseconds: 1200);
  final _updateService = AppUpdateService();
  final _connectivity = Connectivity();

  final hasError = ValueNotifier<bool>(false);
  final isInitialized = ValueNotifier<bool>(false);

  // --- NEW: Key to remember if a forced update is pending ---
  static const String _prefsKeyForceUpdate = 'force_update_pending';

  Future<void> initializeAndNavigate(
    BuildContext context,
    WidgetRef ref,
  ) async {
    debugPrint(
        'SplashController: Starting initialization at ${DateTime.now()}.');

    try {
      if (await _shouldCheckForUpdate()) {
        debugPrint("SplashController: Update check conditions met...");
        if (await _hasInternet()) {
          debugPrint(
              "SplashController: Internet found. Checking for update...");
          try {
            final updateResult = await _updateService
                .checkForUpdate()
                .timeout(const Duration(seconds: 8));

            // 1. Handle Forced Update
            if (context.mounted && updateResult.isForced) {
              debugPrint(
                  "SplashController: Forced update required. Saving flag and showing dialog.");
              // --- NEW: Save the fact that a force update is required ---
              await sharedPreferences.setBool(_prefsKeyForceUpdate, true);
              _showForceUpdateDialog(context, updateResult.storeUrl);
              return; // Stop execution here
            }

            // 2. Handle Optional Update
            else if (updateResult.isOptional) {
              debugPrint(
                  "SplashController: Optional update available. Navigating to OptionalUpdatePage.");
              // --- NEW: Ensure the forced update flag is cleared ---
              await sharedPreferences.setBool(_prefsKeyForceUpdate, false);
              await _resetUpdateCheckTimers(); // It's safe to reset here
              Get.offAll(
                  () => OptionalUpdatePage(storeUrl: updateResult.storeUrl));
              return; // Stop execution here
            }

            // 3. Handle No Update
            debugPrint(
                "SplashController: No update needed. Clearing flags and resetting timers.");
            // --- NEW: Clear the flag and reset timers ONLY when no update is found ---
            await sharedPreferences.setBool(_prefsKeyForceUpdate, false);
            await _resetUpdateCheckTimers();
          } catch (e) {
            debugPrint(
                "SplashController: Error or timeout during update check: $e. Proceeding to normal launch.");
          }
        } else {
          debugPrint(
              "SplashController: No internet connection. Skipping update check and proceeding.");
        }
      } else {
        debugPrint(
            "SplashController: Conditions not met. Skipping update check and proceeding.");
      }

      // 4. Proceed to Normal Navigation
      debugPrint("SplashController: Proceeding to main app navigation.");
      await sharedPreferences.reload();
      await Future.delayed(_kSplashDelay);
      await _handleNormalNavigation(context);
    } catch (e, s) {
      debugPrint(
          "SplashController: CRITICAL - Initialization failed: $e\nStack: $s");
      if (context.mounted) hasError.value = true;
    } finally {
      if (context.mounted) isInitialized.value = true;
    }
  }

  Future<bool> _hasInternet() async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi);
  }

  Future<bool> _shouldCheckForUpdate() async {
    // --- NEW LOGIC: Always check for updates if the force flag is set ---
    final isForceUpdatePending =
        sharedPreferences.getBool(_prefsKeyForceUpdate) ?? false;
    if (isForceUpdatePending) {
      debugPrint(
          "SplashController: Force update flag is set. Forcing update check.");
      return true;
    }

    int openCount = sharedPreferences.getInt('app_open_count') ?? 0;
    openCount++;
    await sharedPreferences.setInt('app_open_count', openCount);
    debugPrint("SplashController: App Open Count: $openCount.");
    // For production, you can change '1' to a higher number like '8'
    return openCount >= 8;
  }

  Future<void> _resetUpdateCheckTimers() async {
    await sharedPreferences.setInt('app_open_count', 0);
    debugPrint("SplashController: Update check open count has been reset.");
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
    debugPrint(
        'SplashController: Onboarding completed status: $onboardingCompleted');
    await _navigateTo(context,
        onboardingCompleted ? const Bottom() : const OnBoardingScreen());
  }

  Future<void> _navigateTo(BuildContext context, Widget page) async {
    if (!context.mounted) return;
    await Get.offAll(() => page, transition: Transition.fade);
    debugPrint('SplashController: Navigated to ${page.runtimeType}.');
  }

  void _showForceUpdateDialog(BuildContext context, String storeUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text('Update Required'.tr),
            content: Text(
              'A newer version of the app is required to continue. Please update from the store.'
                  .tr,
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Update Now'.tr,
                    style: TextStyle(color: AppColors.accentColor)),
                onPressed: () => _launchStoreUrl(storeUrl),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchStoreUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
