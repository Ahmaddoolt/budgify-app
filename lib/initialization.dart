// lib/your_path/initialize_core_services.dart (or wherever this file is located)

import 'dart:typed_data';
// import 'package:alarm/alarm.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:budgify/data/repo/category_repositry.dart';
import 'package:budgify/core/notifications/notification_handlers.dart';
import 'package:budgify/core/notifications/notification_service.dart';
import 'package:budgify/data/services/hive_services.dart/budget_adapter.dart';
import 'package:budgify/data/services/hive_services.dart/category_adaptarr.dart';
import 'package:budgify/data/services/hive_services.dart/expenses_adaptar.dart';
// --- UPDATE #1: Import the new TransferAdapter (assuming you put it here) ---
import 'package:budgify/data/services/hive_services.dart/transfer_adapter.dart';
import 'package:budgify/data/services/hive_services.dart/wallet_adaptar.dart';
import 'package:budgify/domain/models/transfer%20.dart';
import 'package:budgify/viewmodels/providers/sound_toggle_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/domain/models/category.dart';
// --- UPDATE #2: Import the new Transfer model ---
import 'package:budgify/domain/models/wallet.dart';
import 'package:budgify/domain/models/budget.dart';
import 'package:budgify/domain/models/expense.dart';

// Global SharedPreferences instance
late SharedPreferences sharedPreferences;

Future<void> initializeCoreServices() async {
  debugPrint(
    "INITIALIZATION: Starting core services initialization at ${DateTime.now()}...",
  );

  // Initialize SharedPreferences
  try {
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.reload();
    debugPrint("INITIALIZATION: SharedPreferences initialized.");
  } catch (e) {
    debugPrint("INITIALIZATION: Error initializing SharedPreferences: $e");
    try {
      await SharedPreferences.getInstance().then((prefs) => prefs.clear());
      sharedPreferences = await SharedPreferences.getInstance();
      debugPrint("INITIALIZATION: Recovered SharedPreferences after clear.");
    } catch (e) {
      debugPrint(
        "INITIALIZATION: FATAL: Could not initialize SharedPreferences",
      );
      rethrow;
    }
  }

  // Request permissions
  await _handlePermissions();

  // Initialize Hive
  await _initializeHive();

  // Initialize other services
  await _initializeOtherServices();

  debugPrint("INITIALIZATION: Core services initialization completed.");
}

Future<void> _handlePermissions() async {
  debugPrint("PERMISSIONS: Starting permission handling...");

  final isFirstLaunch = sharedPreferences.getBool('first_launch') ?? true;
  if (isFirstLaunch) {
    debugPrint(
      "PERMISSIONS: First launch detected - will request all permissions",
    );
    await sharedPreferences.setBool('first_launch', false);
  }

  try {
    // await requestAlarmPermissions();
    debugPrint("PERMISSIONS: Alarm permissions requested");
  } catch (e) {
    debugPrint("PERMISSIONS: Error requesting alarm permissions: $e");
  }

  bool notificationAllowed = false;
  int retryCount = 0;

  while (!notificationAllowed && retryCount < 2) {
    notificationAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!notificationAllowed) {
      debugPrint(
        "PERMISSIONS: Notification not allowed - requesting (attempt ${retryCount + 1})",
      );
      await AwesomeNotifications().requestPermissionToSendNotifications(
        channelKey: awesomeAlarmChannelKey,
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
          NotificationPermission.Light,
          NotificationPermission.FullScreenIntent,
        ],
      );
      await Future.delayed(const Duration(milliseconds: 500));
    }
    retryCount++;
  }

  if (!notificationAllowed) {
    debugPrint(
      "PERMISSIONS: WARNING: Notification permissions not granted after retries",
    );
  } else {
    debugPrint("PERMISSIONS: Notification permissions granted");

    List<NotificationPermission> missingPermissions =
        await AwesomeNotifications().checkPermissionList(
      permissions: [NotificationPermission.FullScreenIntent],
    );

    if (missingPermissions.isNotEmpty) {
      await AwesomeNotifications().requestPermissionToSendNotifications(
        permissions: [NotificationPermission.FullScreenIntent],
      );
    }
  }
}

Future<void> _initializeHive() async {
  debugPrint("HIVE: Initializing Hive at ${DateTime.now()}");
  try {
    await Hive.initFlutter();

    // Register adapters only if not already registered
    if (!Hive.isAdapterRegistered(CategoryAdapter().typeId)) {
      Hive.registerAdapter(CategoryAdapter());
      debugPrint("HIVE: Registered CategoryAdapter");
    }
    if (!Hive.isAdapterRegistered(WalletAdapter().typeId)) {
      Hive.registerAdapter(WalletAdapter());
      debugPrint("HIVE: Registered WalletAdapter");
    }
    if (!Hive.isAdapterRegistered(BudgetAdapter().typeId)) {
      Hive.registerAdapter(BudgetAdapter());
      debugPrint("HIVE: Registered BudgetAdapter");
    }
    if (!Hive.isAdapterRegistered(CashFlowAdapter().typeId)) {
      Hive.registerAdapter(CashFlowAdapter());
      debugPrint("HIVE: Registered CashFlowAdapter");
    }
    // --- UPDATE #3: Register the new TransferAdapter ---
    if (!Hive.isAdapterRegistered(TransferAdapter().typeId)) {
      Hive.registerAdapter(TransferAdapter());
      debugPrint("HIVE: Registered TransferAdapter");
    }

    // Initialize CashFlowAdapter
    final cashFlowAdapter = CashFlowAdapter();
    await cashFlowAdapter.initialize();
    debugPrint("HIVE: CashFlowAdapter initialized");

    // Open boxes safely
    await _openHiveBoxes();

    // Prepopulate categories
    final categoryBox = Hive.box<Category>('categories');
    final categoryRepository = CategoryRepository(categoryBox);
    if (categoryBox.isEmpty) {
      categoryRepository.prepopulateStandardCategories();
      debugPrint("HIVE: Prepopulated standard categories");
    } else {
      debugPrint("HIVE: Categories already populated, skipping prepopulation");
    }

    debugPrint("HIVE: Initialization completed successfully");
  } catch (e, s) {
    debugPrint("HIVE: Error initializing Hive: $e\nStack: $s");
    // Attempt recovery
    await _recoverHive();
  }
}

Future<void> _openHiveBoxes() async {
  try {
    await Future.wait([
      if (!Hive.isBoxOpen('categories')) Hive.openBox<Category>('categories'),
      if (!Hive.isBoxOpen('wallets')) Hive.openBox<Wallet>('wallets'),
      if (!Hive.isBoxOpen('budgets')) Hive.openBox<Budget>('budgets'),
      if (!Hive.isBoxOpen('expenses')) Hive.openBox<CashFlow>('expenses'),
      // --- UPDATE #4: Open the new 'transfers' box ---
      if (!Hive.isBoxOpen('transfers')) Hive.openBox<Transfer>('transfers'),
    ]);
    debugPrint("HIVE: All boxes opened successfully");
  } catch (e) {
    debugPrint("HIVE: Error opening boxes: $e");
    rethrow;
  }
}

Future<void> _recoverHive() async {
  debugPrint("HIVE: Attempting recovery...");
  try {
    // Close any open boxes to avoid conflicts
    await Hive.close();

    // Delete corrupted boxes
    await Future.wait([
      Hive.deleteBoxFromDisk('categories'),
      Hive.deleteBoxFromDisk('wallets'),
      Hive.deleteBoxFromDisk('budgets'),
      Hive.deleteBoxFromDisk('expenses'),
      // --- UPDATE #5: Delete the 'transfers' box during recovery ---
      Hive.deleteBoxFromDisk('transfers'),
    ]);

    // Re-initialize Hive
    await Hive.initFlutter();

    // Re-register adapters
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(WalletAdapter());
    Hive.registerAdapter(BudgetAdapter());
    Hive.registerAdapter(CashFlowAdapter());
    // --- UPDATE #6: Re-register the TransferAdapter during recovery ---
    Hive.registerAdapter(TransferAdapter());

    // Re-open boxes
    await _openHiveBoxes();

    // Repopulate categories
    final categoryBox = Hive.box<Category>('categories');
    final categoryRepository = CategoryRepository(categoryBox);
    categoryRepository.prepopulateStandardCategories();
    debugPrint("HIVE: Recovery successful, categories repopulated");
  } catch (e) {
    debugPrint("HIVE: FATAL: Recovery failed: $e");
    rethrow;
  }
}

Future<void> _initializeOtherServices() async {
  await Get.putAsync(() async => SoundService().init(), permanent: true);
  debugPrint("SERVICES: SoundService initialized via GetX");

  // ... (your alarm code comments remain) ...

  await _initializeNotifications();

  // The orientation lock has been removed.
}

Future<void> _initializeNotifications() async {
  try {
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
        debug: true);

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
    debugPrint("NOTIFICATIONS: Initialized and listeners set");

    await AwesomeNotifications().cancelAll();
    debugPrint("NOTIFICATIONS: Canceled all existing notifications");

    final bool isNotificationEnabled =
        sharedPreferences.getBool('notification_enabled') ?? true;
    if (isNotificationEnabled) {
      await scheduleDailyNotification(sharedPreferences);
      debugPrint("NOTIFICATIONS: Daily notification scheduled");
    } else {
      debugPrint("NOTIFICATIONS: Daily notifications disabled in preferences");
    }
  } catch (e) {
    debugPrint("NOTIFICATIONS: Error initializing: $e");
  }
}
