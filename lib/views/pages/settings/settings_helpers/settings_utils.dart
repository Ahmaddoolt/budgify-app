import 'dart:typed_data';
import 'package:budgify/core/notifications/notification_handlers.dart';
import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/snackbar_helper.dart';
import 'package:budgify/domain/models/budget.dart';
import 'package:budgify/domain/models/category.dart';
import 'package:budgify/domain/models/expense.dart';
import 'package:budgify/domain/models/wallet.dart';
import 'package:budgify/viewmodels/providers/currency_symbol.dart';
import 'package:budgify/viewmodels/providers/lang_provider.dart';
import 'package:budgify/viewmodels/providers/notification_provider.dart';
import 'package:budgify/viewmodels/providers/switchOnOffIncome.dart';
import 'package:budgify/viewmodels/providers/theme_provider.dart';
import 'package:budgify/viewmodels/providers/thousands_separator_provider.dart';
import 'package:budgify/views/pages/alarm/alarmservices/alarm_handlers.dart';
import 'package:budgify/views/pages/settings/settings_helpers/settings_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:alarm/alarm.dart';
import 'package:budgify/data/repo/category_repositry.dart';
import 'package:budgify/data/services/hive_services.dart/category_adaptarr.dart';
import 'package:budgify/data/services/hive_services.dart/wallet_adaptar.dart';
import 'package:budgify/data/services/hive_services.dart/budget_adapter.dart';
import 'package:budgify/data/services/hive_services.dart/expenses_adaptar.dart';
import 'package:budgify/core/notifications/notification_service.dart';
import 'package:budgify/viewmodels/providers/sound_toggle_provider.dart';

class SettingsUtils {
  static Future<void> setupDefaultSettings(WidgetRef ref) async {
    const defaultCurrency = '\$';
    const defaultLanguage = 'English';
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('currency')) {
      await prefs.setString('currency', defaultCurrency);
    }
    if (!prefs.containsKey('language')) {
      await prefs.setString('language', defaultLanguage);
    }
    if (!prefs.containsKey('switchState')) {
      await prefs.setBool('switchState', true);
    }
    if (!prefs.containsKey('soundToggleState')) {
      await prefs.setBool('soundToggleState', true);
    }
    if (!prefs.containsKey('notification_enabled')) {
      await prefs.setBool('notification_enabled', true);
    }
    if (!prefs.containsKey('separatorEnabled')) {
      await prefs.setBool('separatorEnabled', false);
    }
    if (!prefs.containsKey('theme')) {
      await prefs.setString('theme', 'dark');
    }

    ref
        .read(currencyProvider.notifier)
        .setCurrencySymbol(prefs.getString('currency') ?? defaultCurrency);
    ref
        .read(languageProvider.notifier)
        .setLanguage(prefs.getString('language') ?? defaultLanguage);
    ref.read(switchProvider.notifier).loadSwitchState();
    ref.read(notificationProvider.notifier).loadNotificationState();
    ref.read(separatorProvider.notifier).loadSeparatorState();
    ref.read(themeNotifierProvider.notifier).loadTheme();
  }

  static Future<void> deleteCache(BuildContext context, WidgetRef ref) async {
    final confirm = await SettingsDialogs.showConfirmationDialog(
      context: context,
      title: 'Clear Cache'.tr,
      content:
          'Are you sure you want to clear all cached data and reset settings? This action cannot be undone.'.tr
              .tr,
      confirmText: 'Clear'.tr,
      cancelText: 'Cancel'.tr,
    );

    if (confirm == true) {
      try {
        // Cancel notifications and alarms
        await AwesomeNotifications().cancelAll();
        await Alarm.stopAll();
        globalAlarmSubscription?.cancel();
        debugPrint("SETTINGS: Canceled all notifications and alarms");

        // Close and delete Hive boxes
        await Hive.close();
        await Hive.deleteFromDisk();

        // Clear SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        debugPrint("SETTINGS: Cleared SharedPreferences");

        // Reinitialize Hive and register adapters if not already registered
        await Hive.initFlutter();
        if (!Hive.isAdapterRegistered(CategoryAdapter().typeId)) {
          Hive.registerAdapter(CategoryAdapter());
        }
        if (!Hive.isAdapterRegistered(WalletAdapter().typeId)) {
          Hive.registerAdapter(WalletAdapter());
        }
        if (!Hive.isAdapterRegistered(BudgetAdapter().typeId)) {
          Hive.registerAdapter(BudgetAdapter());
        }
        if (!Hive.isAdapterRegistered(CashFlowAdapter().typeId)) {
          Hive.registerAdapter(CashFlowAdapter());
        }
        debugPrint("SETTINGS: Hive initialized and adapters registered");

        // Open boxes
        await Future.wait([
          Hive.openBox<Category>('categories'),
          Hive.openBox<Wallet>('wallets'),
          Hive.openBox<Budget>('budgets'),
          Hive.openBox<CashFlow>('expenses'),
        ]);
        debugPrint("SETTINGS: Reinitialized Hive and opened boxes");

        // Repopulate standard categories
        final categoryBox = Hive.box<Category>('categories');
        final categoryRepository = CategoryRepository(categoryBox);
        categoryRepository.prepopulateStandardCategories();
        debugPrint("SETTINGS: Repopulated standard categories");

        // Reset default settings
        await setupDefaultSettings(ref);

        // Reinitialize SoundService
        await Get.delete<SoundService>();
        await Get.putAsync(() async => SoundService().init(), permanent: true);
        debugPrint("SETTINGS: Reinitialized SoundService");

        // Reinitialize notifications
        await AwesomeNotifications().initialize(
          'resource://mipmap/ic_launcher',
          [
            NotificationChannel(
              channelKey: 'basic_channel',
              channelName: 'Basic Notifications',
              channelDescription: 'Channel for general app notifications',
              importance: NotificationImportance.Default,
              defaultColor: AppColors.accentColor,
              ledColor: Colors.white,
              channelShowBadge: true,
            ),
            NotificationChannel(
              channelKey: awesomeAlarmChannelKey,
              channelName: 'Alarm Alerts (Budgify)',
              channelDescription: 'Channel for Budgify alarm reminders',
              importance: NotificationImportance.Max,
              defaultColor: AppColors.accentColor2,
              ledColor: AppColors.accentColor2,
              vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
              playSound: false,
              enableVibration: false,
              locked: true,
              criticalAlerts: true,
              channelShowBadge: true,
              defaultPrivacy: NotificationPrivacy.Public,
            ),
          ],
          debug: true,
        );
        if (prefs.getBool('notification_enabled') ?? true) {
          await scheduleDailyNotification(prefs);
        }
        debugPrint("SETTINGS: Reinitialized notifications");

        if (context.mounted) {
          showFeedbackSnackbar(context, 'Cache cleared and settings reset!'.tr);
        }
      } catch (e, stackTrace) {
        debugPrint("SETTINGS: Error clearing cache: $e\n$stackTrace");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error clearing cache: ${e.toString()}'.tr)),
          );
        }
      }
    }
  }

  static Future<void> deleteExpenses(BuildContext context) async {
    final confirm = await SettingsDialogs.showConfirmationDialog(
      context: context,
      title: 'Clear Financial Data'.tr,
      content:
          'Are you sure you want to clear ALL financial data including expenses, categories, budgets, and wallets? Settings will remain. This action cannot be undone.'
              .tr,
      confirmText: 'Clear Data'.tr,
      cancelText: 'Cancel'.tr,
    );

    if (confirm == true) {
      try {
        // Cancel notifications and alarms
        await AwesomeNotifications().cancelAll();
        await Alarm.stopAll();
        globalAlarmSubscription?.cancel();
        debugPrint("SETTINGS: Canceled all notifications and alarms");

        // Ensure Hive is initialized and adapters are registered
        await Hive.initFlutter();
        if (!Hive.isAdapterRegistered(CategoryAdapter().typeId)) {
          Hive.registerAdapter(CategoryAdapter());
        }
        if (!Hive.isAdapterRegistered(WalletAdapter().typeId)) {
          Hive.registerAdapter(WalletAdapter());
        }
        if (!Hive.isAdapterRegistered(BudgetAdapter().typeId)) {
          Hive.registerAdapter(BudgetAdapter());
        }
        if (!Hive.isAdapterRegistered(CashFlowAdapter().typeId)) {
          Hive.registerAdapter(CashFlowAdapter());
        }
        debugPrint("SETTINGS: Hive initialized and adapters registered");

        // Open boxes if not already open
        final boxes = [
          {'name': 'expenses', 'open': () => Hive.openBox<CashFlow>('expenses')},
          {'name': 'categories', 'open': () => Hive.openBox<Category>('categories')},
          {'name': 'budgets', 'open': () => Hive.openBox<Budget>('budgets')},
          {'name': 'wallets', 'open': () => Hive.openBox<Wallet>('wallets')},
        ];

        for (var box in boxes) {
          final boxName = box['name'] as String;
          if (!Hive.isBoxOpen(boxName)) {
            await (box['open'] as Future<Box> Function())();
            debugPrint("SETTINGS: Opened box '$boxName'");
          } else {
            debugPrint("SETTINGS: Box '$boxName' already open");
          }
        }

        // Clear Hive boxes
        await Hive.box<CashFlow>('expenses').clear();
        await Hive.box<Category>('categories').clear();
        await Hive.box<Budget>('budgets').clear();
        await Hive.box<Wallet>('wallets').clear();
        debugPrint("SETTINGS: Cleared all financial data boxes");

        // Repopulate standard categories
        final categoryBox = Hive.box<Category>('categories');
        final categoryRepository = CategoryRepository(categoryBox);
        categoryRepository.prepopulateStandardCategories();
        debugPrint("SETTINGS: Repopulated standard categories");

        // Reinitialize notifications if enabled
        final prefs = await SharedPreferences.getInstance();
        if (prefs.getBool('notification_enabled') ?? true) {
          await scheduleDailyNotification(prefs);
        }
        debugPrint("SETTINGS: Reinitialized notifications");

        if (context.mounted) {
          showFeedbackSnackbar(
            context,
            'Financial data cleared successfully!'.tr,
          );
        }
      } catch (e, stackTrace) {
        debugPrint("SETTINGS: Error clearing financial data: $e\n$stackTrace");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error clearing data: ${e.toString()}'.tr)),
          );
        }
      }
    }
  }
}