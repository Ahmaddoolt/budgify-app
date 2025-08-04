// main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:budgify/core/navigation/app_routes.dart';
import 'package:budgify/initialization.dart';
import 'package:budgify/app_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart'; // Import this

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("MAIN: App starting at ${DateTime.now()}...");

  await dotenv.load(fileName: ".env");

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  debugPrint(
      "MAIN: Supabase initialized successfully."); // Updated message for clarity

  String determinedInitialRoute = YourAppRoutes.splashScreen;
  Map<String, dynamic>? routeArgsForAlarm;

  try {
    await initializeCoreServices();

    final isFirstLaunch = sharedPreferences.getBool('first_launch') ?? true;
    if (isFirstLaunch) {
      // await sharedPreferences.setBool(AlarmDisplayService.prefsKeyIsAlarmScreenActive, false);
      // await sharedPreferences.remove('current_ringing_alarm_id');
      // await sharedPreferences.remove('current_ringing_alarm_title');
      // debugPrint("MAIN: First launch detected. Cleared alarm-related SharedPreferences keys.");
    }

    // final initialAlarmData = await getInitialAlarmNativeData();
    // if (initialAlarmData != null) {
    //   determinedInitialRoute = YourAppRoutes.alarmScreen;
    //   routeArgsForAlarm = initialAlarmData;
    //   await sharedPreferences.setBool(AlarmDisplayService.prefsKeyIsAlarmScreenActive, true);
    //   await sharedPreferences.setInt('current_ringing_alarm_id', initialAlarmData['id'] as int);
    //   await sharedPreferences.setString('current_ringing_alarm_title', initialAlarmData['title'] as String);
    //   debugPrint("MAIN: Initial route is ALARMSCREEN due to native intent. Args: $routeArgsForAlarm");
    // } else {
    //   debugPrint("MAIN: No native alarm data. Splash screen will handle stored alarm state.");
    // }

    // await cleanupOldAlarms();
  } catch (e, s) {
    debugPrint("MAIN: Initialization failed: $e\nStack: $s");
    // Only clear specific keys, not entire SharedPreferences
    await sharedPreferences.setBool('first_launch', true);
    debugPrint(
      "MAIN: Set first_launch to true due to initialization failure. Preserving other settings.",
    );
    determinedInitialRoute = YourAppRoutes.splashScreen;
  }

  if (determinedInitialRoute == YourAppRoutes.alarmScreen &&
      routeArgsForAlarm != null) {
    Get.routing.args = routeArgsForAlarm;
    debugPrint(
      "MAIN: Set Get.routing.args for AlarmScreen: ${Get.routing.args}",
    );
  }

  debugPrint(
    "MAIN: ===== PRE-RUN CHECKS COMPLETE. Running app with initialRoute: $determinedInitialRoute, Get.routing.args: ${Get.routing.args} =====",
  );

  runApp(ProviderScope(child: MyApp(initialRoute: determinedInitialRoute)));
}
