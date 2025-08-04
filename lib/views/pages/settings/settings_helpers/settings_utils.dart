import 'package:budgify/views/pages/categories_wallets/categories_view/categories_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgify/core/utils/snackbar_helper.dart';
import 'package:budgify/data/repo/category_repositry.dart';
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
import 'package:budgify/viewmodels/providers/total_expenses_amount.dart';
import 'package:budgify/viewmodels/providers/total_expenses_monthly.dart';
import 'package:budgify/viewmodels/providers/total_incomes.dart';
import 'package:budgify/viewmodels/providers/total_incomes_monthly.dart';
import 'package:budgify/viewmodels/providers/wallet_provider.dart';
import 'package:budgify/views/pages/settings/settings_helpers/settings_dialogs.dart';

class SettingsUtils {
  static Future<void> setupDefaultSettings(WidgetRef ref) async {
    const defaultCurrencyCode = 'USD';
    const defaultLanguage = 'English';
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('currency_code')) {
      await prefs.setString('currency_code', defaultCurrencyCode);
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

    ref.read(currencyProvider.notifier).changeDisplayCurrency(
        prefs.getString('currency_code') ?? defaultCurrencyCode);

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
      title: 'Reset App?'.tr,
      content:
          'This will permanently delete ALL data, including transactions, wallets, budgets, and settings. The app will be reset to its original state. This action cannot be undone.'
              .tr,
      confirmText: 'Reset'.tr,
      cancelText: 'Cancel'.tr,
    );

    if (confirm == true) {
      try {
        debugPrint("SETTINGS (Reset App): Manually clearing all Hive boxes...");
        await Hive.box<CashFlow>('expenses').clear();
        await Hive.box<Category>('categories').clear();
        await Hive.box<Budget>('budgets').clear();
        await Hive.box<Wallet>('wallets').clear();
        debugPrint("SETTINGS (Reset App): All Hive boxes cleared.");

        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        debugPrint("SETTINGS (Reset App): SharedPreferences cleared.");

        final categoryRepository = CategoryRepository(
          Hive.box<Category>('categories'),
        );
        categoryRepository.prepopulateStandardCategories();
        ref.read(walletProvider.notifier).initializeWallets();
        debugPrint(
          "SETTINGS (Reset App): Default categories and wallets repopulated.",
        );

        await setupDefaultSettings(ref);
        debugPrint("SETTINGS (Reset App): Default settings re-applied.");

        debugPrint("SETTINGS (Reset App): Invalidating all providers...");
        ref.invalidate(categoryProvider);
        ref.invalidate(walletProvider);
        ref.invalidate(totalAmountProvider);
        ref.invalidate(monthlyAmountProvider);
        ref.invalidate(totalIncomesAmountProvider);
        ref.invalidate(monthlyIncomesAmountProvider);
        ref.invalidate(currencyProvider);
        ref.invalidate(languageProvider);
        ref.invalidate(notificationProvider);
        ref.invalidate(switchProvider);
        ref.invalidate(themeNotifierProvider);
        ref.invalidate(separatorProvider);

        debugPrint("SETTINGS (Reset App): All providers invalidated.");

        if (context.mounted) {
          showFeedbackSnackbar(context, 'App has been reset successfully!'.tr);
        }
      } catch (e, stackTrace) {
        debugPrint("SETTINGS (Reset App): Error: $e\n$stackTrace");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error resetting app: ${e.toString()}'.tr)),
          );
        }
      }
    }
  }

  static Future<void> deleteExpenses(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirm = await SettingsDialogs.showConfirmationDialog(
      context: context,
      title: 'Clear Financial Records?'.tr,
      content:
          'This will permanently delete all your transactions, categories, budgets, and wallets. Your app settings will NOT be changed. This action cannot be undone.'
              .tr,
      confirmText: 'Clear Records'.tr,
      cancelText: 'Cancel'.tr,
    );

    if (confirm == true) {
      try {
        await Hive.box<CashFlow>('expenses').clear();
        await Hive.box<Category>('categories').clear();
        await Hive.box<Budget>('budgets').clear();
        await Hive.box<Wallet>('wallets').clear();
        debugPrint("SETTINGS: Cleared all financial data boxes.");

        final categoryRepository = CategoryRepository(
          Hive.box<Category>('categories'),
        );
        categoryRepository.prepopulateStandardCategories();
        ref.read(walletProvider.notifier).initializeWallets();

        ref.invalidate(categoryProvider);
        ref.invalidate(walletProvider);
        ref.invalidate(totalAmountProvider);
        ref.invalidate(monthlyAmountProvider);
        ref.invalidate(totalIncomesAmountProvider);
        ref.invalidate(monthlyIncomesAmountProvider);

        if (context.mounted) {
          showFeedbackSnackbar(
            context,
            'Financial records cleared successfully!'.tr,
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
