import 'package:budgify/core/constants/app_constants.dart';
import 'package:budgify/data/repo/category_repositry.dart';
import 'package:budgify/domain/models/budget.dart';
import 'package:budgify/domain/models/category.dart';
import 'package:budgify/domain/models/expense.dart';
import 'package:budgify/domain/models/wallet.dart';
import 'package:budgify/initialization.dart';
import 'package:budgify/viewmodels/providers/currency_symbol.dart';
import 'package:budgify/viewmodels/providers/lang_provider.dart';
import 'package:budgify/views/navigation/app_routes.dart';
import 'package:budgify/views/pages/alarm/alarmservices/alarm_display_service.dart';
import 'package:budgify/views/pages/categories_wallets/categories_view/categories_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SplashService {
  Future<bool> checkAlarmState() async {
    await sharedPreferences.reload();
    bool isAlarmScreenActive = sharedPreferences.getBool(AlarmDisplayService.prefsKeyIsAlarmScreenActive) ?? false;
    int? storedAlarmId = sharedPreferences.getInt('current_ringing_alarm_id');
    String? storedAlarmTitle = sharedPreferences.getString('current_ringing_alarm_title');

    debugPrint('SplashService: Alarm check - isActive: $isAlarmScreenActive, alarmId: $storedAlarmId, alarmTitle: $storedAlarmTitle');

    if (isAlarmScreenActive && storedAlarmId != null && storedAlarmTitle != null) {
      debugPrint('SplashService: Alarm is active. Navigating to AlarmScreen with ID: $storedAlarmId, Title: $storedAlarmTitle');
      Get.offAllNamed(YourAppRoutes.alarmScreen, arguments: {'id': storedAlarmId, 'title': storedAlarmTitle});
      return true;
    } else if (isAlarmScreenActive) {
      debugPrint('SplashService: WARNING - Alarm flag TRUE but ID/Title missing. Clearing alarm state.');
      await sharedPreferences.setBool(AlarmDisplayService.prefsKeyIsAlarmScreenActive, false);
      await sharedPreferences.remove('current_ringing_alarm_id');
      await sharedPreferences.remove('current_ringing_alarm_title');
      await sharedPreferences.reload();
      debugPrint('SplashService: Cleared invalid alarm state');
    }
    return false;
  }

  Future<void> checkFirstLaunchStatus() async {
    await sharedPreferences.reload();
    final isFirstLaunch = sharedPreferences.getBool('first_launch') ?? true;
    debugPrint('SplashService: First launch status: $isFirstLaunch');

    if (isFirstLaunch) {
      await _clearExistingData();
      await sharedPreferences.setBool('first_launch', false);
      await sharedPreferences.reload();
      final firstLaunchAfterSet = sharedPreferences.getBool('first_launch') ?? true;
      debugPrint('SplashService: Set first_launch to false, verified: $firstLaunchAfterSet');
      if (firstLaunchAfterSet) {
        debugPrint('SplashService: WARNING - Failed to set first_launch flag');
      }
      await sharedPreferences.setBool(AppConstants.onboardingCompletedKey, false);
      await sharedPreferences.reload();
      final onboardingStatus = sharedPreferences.getBool(AppConstants.onboardingCompletedKey) ?? false;
      debugPrint('SplashService: Set onboarding_completed to false, verified: $onboardingStatus');
    } else {
      final onboardingCompleted = sharedPreferences.getBool(AppConstants.onboardingCompletedKey) ?? false;
      debugPrint('SplashService: Not first launch, onboarding completed: $onboardingCompleted');

      final currency = sharedPreferences.getString('currency');
      final language = sharedPreferences.getString('language');
      debugPrint('SplashService: Current settings - currency: $currency, language: $language');

      if (onboardingCompleted && (currency == null || language == null)) {
        debugPrint('SplashService: Onboarding completed but missing critical data. Resetting onboarding.');
        await sharedPreferences.setBool(AppConstants.onboardingCompletedKey, false);
        await sharedPreferences.reload();
        debugPrint('SplashService: Reset onboarding_completed to false, verified: ${sharedPreferences.getBool(AppConstants.onboardingCompletedKey)}');
      }
    }
  }

  Future<void> performHeavyInitialization(WidgetRef ref) async {
    debugPrint('SplashService: Starting heavy initialization.');
    try {
      await _initializeAndOpenEssentialBoxes();
      await Future.wait([_setupCurrencyAndLanguage(ref), _initializeCategories(ref)]);
      debugPrint('SplashService: Heavy initialization completed.');
    } catch (e) {
      debugPrint('SplashService: Error during heavy initialization: $e');
      rethrow;
    }
  }

  Future<void> _initializeAndOpenEssentialBoxes() async {
    try {
      if (!Hive.isBoxOpen('categories')) {
        await Hive.openBox<Category>('categories');
      }
      if (!Hive.isBoxOpen('wallets')) {
        await Hive.openBox<Wallet>('wallets');
      }
      if (!Hive.isBoxOpen('budgets')) {
        await Hive.openBox<Budget>('budgets');
      }
      if (!Hive.isBoxOpen('expenses')) {
        await Hive.openBox<CashFlow>('expenses');
      }
      debugPrint('SplashService: Hive boxes opened successfully');
    } catch (e) {
      debugPrint('SplashService: Error opening Hive boxes: $e');
      try {
        await Hive.deleteBoxFromDisk('categories');
        await Hive.deleteBoxFromDisk('wallets');
        await Hive.deleteBoxFromDisk('budgets');
        await Hive.deleteBoxFromDisk('expenses');

        await Hive.openBox<Category>('categories');
        await Hive.openBox<Wallet>('wallets');
        await Hive.openBox<Budget>('budgets');
        await Hive.openBox<CashFlow>('expenses');

        debugPrint('SplashService: Successfully recovered Hive boxes');
      } catch (e) {
        debugPrint('SplashService: FATAL: Could not recover Hive boxes: $e');
        rethrow;
      }
    }
  }

  Future<void> _setupCurrencyAndLanguage(WidgetRef ref) async {
    try {
      await ref.read(currencyProvider.notifier).loadStoredValues();
      if (sharedPreferences.getString('currency') == null) {
        await sharedPreferences.setString('currency', '\$');
        ref.read(currencyProvider.notifier).setCurrencySymbol('\$');
        await sharedPreferences.reload();
        debugPrint('SplashService: Set default currency to \$, verified: ${sharedPreferences.getString('currency')}');
      }
      if (sharedPreferences.getString('language') == null) {
        await ref.read(languageProvider.notifier).setLanguage('English');
        await sharedPreferences.reload();
        debugPrint('SplashService: Set default language to English, verified: ${sharedPreferences.getString('language')}');
      }
    } catch (e) {
      debugPrint('SplashService: Error setting up currency or language: $e');
      await sharedPreferences.setString('currency', '\$');
      ref.read(currencyProvider.notifier).setCurrencySymbol('\$');
      await ref.read(languageProvider.notifier).setLanguage('English');
      await sharedPreferences.reload();
      debugPrint('SplashService: Applied fallback defaults - currency: ${sharedPreferences.getString('currency')}, language: ${sharedPreferences.getString('language')}');
    }
  }

  Future<void> _initializeCategories(WidgetRef ref) async {
    try {
      if (!Hive.isBoxOpen('categories')) {
        await Hive.openBox<Category>('categories');
      }
      final categoryBox = Hive.box<Category>('categories');
      if (categoryBox.isEmpty) {
        CategoryRepository(categoryBox).prepopulateStandardCategories();
        debugPrint('SplashService: Prepopulated standard categories');
      }
      ref.read(categoryProvider.notifier).loadCategories();
    } catch (e) {
      debugPrint('SplashService: Error initializing categories: $e');
      rethrow;
    }
  }

  Future<void> _clearExistingData() async {
    try {
      await Hive.deleteBoxFromDisk('categories');
      await Hive.deleteBoxFromDisk('wallets');
      await Hive.deleteBoxFromDisk('budgets');
      await Hive.deleteBoxFromDisk('expenses');

      await sharedPreferences.remove('current_ringing_alarm_id');
      await sharedPreferences.remove('current_ringing_alarm_title');
      await sharedPreferences.setBool(AlarmDisplayService.prefsKeyIsAlarmScreenActive, false);

      await sharedPreferences.remove('currency');
      await sharedPreferences.remove('language');
      await sharedPreferences.remove('switchState');

      debugPrint('SplashService: Cleared all existing data for first launch');
    } catch (e) {
      debugPrint('SplashService: Error clearing existing data: $e');
      rethrow;
    }
  }
}