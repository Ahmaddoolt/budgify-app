// import 'package:budgify/core/constants/app_constants.dart';
// import 'package:budgify/domain/models/budget.dart';
// import 'package:budgify/domain/models/expense.dart';
// import 'package:budgify/domain/models/wallet.dart';
// import 'package:budgify/initialization.dart';
// import 'package:budgify/views/pages/categories_wallets/categories_view/categories_list.dart';
// import 'package:budgify/views/pages/onboarding/onboarding_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:get/get.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:lottie/lottie.dart';
// import 'package:budgify/domain/models/category.dart';
// import 'package:budgify/data/repo/category_repositry.dart';
// import 'package:budgify/viewmodels/currency_symbol.dart';
// import 'package:budgify/viewmodels/lang_provider.dart';
// import 'package:budgify/views/navigation/bottom_nativgation/bottom_navigation_bar.dart';
// import 'package:budgify/views/navigation/app_routes.dart';
// import 'package:budgify/views/pages/alarm/alarmservices/alarm_display_service.dart';

// class Splash extends ConsumerStatefulWidget {
//   const Splash({super.key});

//   @override
//   ConsumerState<Splash> createState() => _SplashState();
// }

// class _SplashState extends ConsumerState<Splash> {
//   static const _kSplashDelay = Duration(milliseconds: 1200);
//   static const _kPrefsLoadDelay = Duration(milliseconds: 500); // Added to ensure SharedPreferences is ready
//   bool _hasError = false;
//   bool _isInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback(
//       (_) => _initializeAndNavigate(),
//     );
//   }

//   Future<void> _initializeAndNavigate() async {
//     debugPrint('Splash: Starting initialization and navigation at ${DateTime.now()}.');

//     try {
//       // Ensure SharedPreferences is fully loaded
//       await Future.delayed(_kPrefsLoadDelay); // Add delay to avoid race conditions
//       await sharedPreferences.reload();
//       debugPrint('Splash: SharedPreferences reloaded.');

//       // First check if we need to show alarm screen
//       final shouldShowAlarm = await _checkAlarmState();
//       if (shouldShowAlarm) return;

//       // Check first launch status and handle data initialization
//       await _checkFirstLaunchStatus();

//       // Perform heavy initialization
//       await _performHeavyInitialization();

//       // Check alarm state again after initialization
//       final shouldStillShowAlarm = await _checkAlarmState();
//       if (shouldStillShowAlarm) return;

//       // Normal navigation after delay
//       await Future.delayed(_kSplashDelay);
//       await _handleNormalNavigation();
//     } catch (e, s) {
//       debugPrint("Splash: CRITICAL - Initialization failed: $e\nStack: $s");
//       if (mounted) {
//         setState(() {
//           _hasError = true;
//         });
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isInitialized = true;
//         });
//       }
//     }
//   }

//   Future<void> _checkFirstLaunchStatus() async {
//     await sharedPreferences.reload();
//     final isFirstLaunch = sharedPreferences.getBool('first_launch') ?? true;
//     debugPrint('Splash: First launch status: $isFirstLaunch');

//     if (isFirstLaunch) {
//       // Clear existing data for a clean state on first launch
//       await _clearExistingData();
//       // Set first_launch to false and verify
//       await sharedPreferences.setBool('first_launch', false);
//       await sharedPreferences.reload();
//       final firstLaunchAfterSet = sharedPreferences.getBool('first_launch') ?? true;
//       debugPrint('Splash: Set first_launch to false, verified: $firstLaunchAfterSet');
//       if (firstLaunchAfterSet) {
//         debugPrint('Splash: WARNING - Failed to set first_launch flag');
//       }
//       // Set onboarding_completed to false
//       await sharedPreferences.setBool(AppConstants.onboardingCompletedKey, false);
//       await sharedPreferences.reload();
//       final onboardingStatus = sharedPreferences.getBool(AppConstants.onboardingCompletedKey) ?? false;
//       debugPrint('Splash: Set onboarding_completed to false, verified: $onboardingStatus');
//     } else {
//       // Verify onboarding status and data integrity
//       final onboardingCompleted = sharedPreferences.getBool(AppConstants.onboardingCompletedKey) ?? false;
//       debugPrint('Splash: Not first launch, onboarding completed: $onboardingCompleted');

//       // Check for critical data (currency, language)
//       final currency = sharedPreferences.getString('currency');
//       final language = sharedPreferences.getString('language');
//       debugPrint('Splash: Current settings - currency: $currency, language: $language');

//       if (onboardingCompleted && (currency == null || language == null)) {
//         debugPrint('Splash: Onboarding completed but missing critical data. Resetting onboarding.');
//         await sharedPreferences.setBool(AppConstants.onboardingCompletedKey, false);
//         await sharedPreferences.reload();
//         debugPrint('Splash: Reset onboarding_completed to false, verified: ${sharedPreferences.getBool(AppConstants.onboardingCompletedKey)}');
//       }
//     }
//   }

//   Future<void> _clearExistingData() async {
//     try {
//       // Clear Hive data
//       await Hive.deleteBoxFromDisk('categories');
//       await Hive.deleteBoxFromDisk('wallets');
//       await Hive.deleteBoxFromDisk('budgets');
//       await Hive.deleteBoxFromDisk('expenses');

//       // Clear alarm-related data
//       await sharedPreferences.remove('current_ringing_alarm_id');
//       await sharedPreferences.remove('current_ringing_alarm_title');
//       await sharedPreferences.setBool(
//         AlarmDisplayService.prefsKeyIsAlarmScreenActive,
//         false,
//       );

//       // Clear user preferences
//       await sharedPreferences.remove('currency');
//       await sharedPreferences.remove('language');
//       await sharedPreferences.remove('switchState');

//       debugPrint('Splash: Cleared all existing data for first launch');
//     } catch (e) {
//       debugPrint('Splash: Error clearing existing data: $e');
//       throw e;
//     }
//   }

//   Future<bool> _checkAlarmState() async {
//     await sharedPreferences.reload();
//     bool isAlarmScreenActive =
//         sharedPreferences.getBool(
//           AlarmDisplayService.prefsKeyIsAlarmScreenActive,
//         ) ??
//         false;
//     int? storedAlarmId = sharedPreferences.getInt('current_ringing_alarm_id');
//     String? storedAlarmTitle =
//         sharedPreferences.getString('current_ringing_alarm_title');

//     debugPrint('Splash: Alarm check - isActive: $isAlarmScreenActive, alarmId: $storedAlarmId, alarmTitle: $storedAlarmTitle');

//     if (isAlarmScreenActive &&
//         storedAlarmId != null &&
//         storedAlarmTitle != null) {
//       debugPrint(
//         'Splash: Alarm is active. Navigating to AlarmScreen with ID: $storedAlarmId, Title: $storedAlarmTitle',
//       );
//       final alarmArgs = {'id': storedAlarmId, 'title': storedAlarmTitle};
//       if (mounted) {
//         Get.offAllNamed(YourAppRoutes.alarmScreen, arguments: alarmArgs);
//       }
//       return true;
//     } else if (isAlarmScreenActive) {
//       debugPrint(
//         'Splash: WARNING - Alarm flag TRUE but ID/Title missing. Clearing alarm state.',
//       );
//       await sharedPreferences.setBool(
//         AlarmDisplayService.prefsKeyIsAlarmScreenActive,
//         false,
//       );
//       await sharedPreferences.remove('current_ringing_alarm_id');
//       await sharedPreferences.remove('current_ringing_alarm_title');
//       await sharedPreferences.reload();
//       debugPrint('Splash: Cleared invalid alarm state');
//     }
//     return false;
//   }

//   Future<void> _performHeavyInitialization() async {
//     debugPrint('Splash: Starting heavy initialization.');
//     try {
//       await _initializeAndOpenEssentialBoxes();
//       await Future.wait([_setupCurrencyAndLanguage(), _initializeCategories()]);
//       debugPrint('Splash: Heavy initialization completed.');
//     } catch (e) {
//       debugPrint('Splash: Error during heavy initialization: $e');
//       rethrow;
//     }
//   }

//   Future<void> _initializeAndOpenEssentialBoxes() async {
//     try {
//       if (!Hive.isBoxOpen('categories')) {
//         await Hive.openBox<Category>('categories');
//       }
//       if (!Hive.isBoxOpen('wallets')) {
//         await Hive.openBox<Wallet>('wallets');
//       }
//       if (!Hive.isBoxOpen('budgets')) {
//         await Hive.openBox<Budget>('budgets');
//       }
//       if (!Hive.isBoxOpen('expenses')) {
//         await Hive.openBox<CashFlow>('expenses');
//       }
//       debugPrint('Splash: Hive boxes opened successfully');
//     } catch (e) {
//       debugPrint('Splash: Error opening Hive boxes: $e');
//       // Attempt recovery
//       try {
//         await Hive.deleteBoxFromDisk('categories');
//         await Hive.deleteBoxFromDisk('wallets');
//         await Hive.deleteBoxFromDisk('budgets');
//         await Hive.deleteBoxFromDisk('expenses');

//         await Hive.openBox<Category>('categories');
//         await Hive.openBox<Wallet>('wallets');
//         await Hive.openBox<Budget>('budgets');
//         await Hive.openBox<CashFlow>('expenses');

//         debugPrint('Splash: Successfully recovered Hive boxes');
//       } catch (e) {
//         debugPrint('Splash: FATAL: Could not recover Hive boxes: $e');
//         rethrow;
//       }
//     }
//   }

//   Future<void> _setupCurrencyAndLanguage() async {
//     try {
//       await ref.read(currencyProvider.notifier).loadStoredValues();
//       // Ensure default currency is set if none exists
//       if (sharedPreferences.getString('currency') == null) {
//         await sharedPreferences.setString('currency', '\$');
//         ref.read(currencyProvider.notifier).setCurrencySymbol('\$');
//         await sharedPreferences.reload();
//         debugPrint('Splash: Set default currency to \$, verified: ${sharedPreferences.getString('currency')}');
//       }
//       // Ensure default language is set if none exists
//       if (sharedPreferences.getString('language') == null) {
//         await ref.read(languageProvider.notifier).setLanguage('English');
//         await sharedPreferences.reload();
//         debugPrint('Splash: Set default language to English, verified: ${sharedPreferences.getString('language')}');
//       }
//     } catch (e) {
//       debugPrint('Splash: Error setting up currency or language: $e');
//       // Set defaults as fallback
//       await sharedPreferences.setString('currency', '\$');
//       ref.read(currencyProvider.notifier).setCurrencySymbol('\$');
//       await ref.read(languageProvider.notifier).setLanguage('English');
//       await sharedPreferences.reload();
//       debugPrint('Splash: Applied fallback defaults - currency: ${sharedPreferences.getString('currency')}, language: ${sharedPreferences.getString('language')}');
//     }
//   }

//   Future<void> _initializeCategories() async {
//     try {
//       if (!Hive.isBoxOpen('categories')) {
//         await Hive.openBox<Category>('categories');
//       }
//       final categoryBox = Hive.box<Category>('categories');
//       if (categoryBox.isEmpty) {
//         CategoryRepository(categoryBox).prepopulateStandardCategories();
//         debugPrint('Splash: Prepopulated standard categories');
//       }
//       ref.read(categoryProvider.notifier).loadCategories();
//     } catch (e) {
//       debugPrint('Splash: Error initializing categories: $e');
//       rethrow;
//     }
//   }

//   Future<void> _handleNormalNavigation() async {
//     if (!mounted) return;

//     await sharedPreferences.reload();
//     final onboardingCompleted =
//         sharedPreferences.getBool(AppConstants.onboardingCompletedKey) ?? false;
//     debugPrint('Splash: Onboarding completed status: $onboardingCompleted');

//     // Log current settings for debugging
//     final currency = sharedPreferences.getString('currency');
//     final language = sharedPreferences.getString('language');
//     final switchState = sharedPreferences.getBool('switchState');
//     debugPrint('Splash: Current settings before navigation - currency: $currency, language: $language, switchState: $switchState');

//     if (!onboardingCompleted) {
//       _navigateTo(const OnBoardingScreen());
//     } else {
//       _navigateTo(const Bottom());
//     }
//   }

//   void _navigateTo(Widget page) {
//     if (!mounted) return;

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await sharedPreferences.reload();
//       bool isAlarmActive =
//           sharedPreferences.getBool(
//             AlarmDisplayService.prefsKeyIsAlarmScreenActive,
//           ) ??
//           false;

//       if (isAlarmActive) {
//         int? alarmId = sharedPreferences.getInt('current_ringing_alarm_id');
//         String? alarmTitle = sharedPreferences.getString(
//           'current_ringing_alarm_title',
//         );
//         if (alarmId != null &&
//             alarmTitle != null &&
//             Get.currentRoute != YourAppRoutes.alarmScreen) {
//           debugPrint(
//             'Splash: Alarm active during navigation. Navigating to AlarmScreen.',
//           );
//           Get.offAllNamed(
//             YourAppRoutes.alarmScreen,
//             arguments: {'id': alarmId, 'title': alarmTitle},
//           );
//           return;
//         }
//       }

//       Get.offAll(() => page, transition: Transition.fade);
//       debugPrint('Splash: Navigated to ${page.runtimeType}.');
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     Color? backgroundcolor = Theme.of(context).appBarTheme.backgroundColor;

//     if (_hasError) {
//       return Scaffold(
//         backgroundColor: backgroundcolor,
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline, color: Colors.white, size: 60),
//               const SizedBox(height: 20),
//               const Text(
//                 'Failed to initialize the app.',
//                 style: TextStyle(color: Colors.white, fontSize: 18),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 10),
//               ElevatedButton(
//                 onPressed: () async {
//                   try {
//                     // Clear all preferences and reset first_launch
//                     await sharedPreferences.clear();
//                     await sharedPreferences.setBool('first_launch', true);
//                     setState(() {
//                       _hasError = false;
//                     });
//                     await _initializeAndNavigate();
//                   } catch (e) {
//                     debugPrint('Splash: Retry failed: $e');
//                   }
//                 },
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: backgroundcolor,
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Center(
//             child: Lottie.asset(
//               "assets/bud_splash.json",
//               width: MediaQuery.of(context).size.width * 0.8,
//               fit: BoxFit.contain,
//             ),
//           ),
//           if (!_isInitialized) const SizedBox(height: 20),
//           if (!_isInitialized)
//             Center(
//               child: Text(
//                 "Speak money fluently".tr,
//                 style: const TextStyle(
//                   fontFamily: 'Montserrat',
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }