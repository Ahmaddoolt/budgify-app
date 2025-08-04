import 'package:budgify/initialization.dart';
import 'package:budgify/core/navigation/bottom_nativgation/bottom_navigation_bar.dart';
import 'package:budgify/views/pages/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For SharedPreferences
// import 'package:budgify/app_routes.dart'; // Self import for constants

class YourAppRoutes {
  static const String splashScreen = "/splash";
  static const String alarmScreen = "/alarm";
  static const String homeScreen = "/home";
  // *** ADD THIS STATIC CONSTANT FOR THE ALARM LIST PAGE ROUTE NAME ***
  static const String alarmListPage = "/alarm-list";

  // Constants for argument keys, ensure consistency
  static const String argKeyAlarmId = "id";
  static const String argKeyAlarmTitle = "title";


  static List<GetPage> routes = [
    GetPage(name: splashScreen, page: () => const SplashScreen()),
    GetPage(name: homeScreen, page: () => const Bottom()),

    GetPage(
      name: alarmScreen,
      page: () {
        debugPrint("AppRoutes (GetPage for AlarmScreen): BUILDER EXECUTED.");
        debugPrint("AppRoutes: Current Get.arguments: ${Get.arguments}");
        debugPrint("AppRoutes: Current Get.routing.args: ${Get.routing.args}");

        dynamic routeArgs = Get.arguments ?? Get.routing.args;
        int? screenId;
        String? screenTitle;

        if (routeArgs is Map<String, dynamic>) {
          screenId = routeArgs[argKeyAlarmId] as int?;
          screenTitle = routeArgs[argKeyAlarmTitle] as String?;
          debugPrint("AppRoutes: Extracted from routeArgs (Get.arguments or Get.routing.args) - ID: $screenId, Title: $screenTitle");
        } else {
            debugPrint("AppRoutes: routeArgs is NULL or not a Map. Trying SharedPreferences fallback.");
            // Fallback: If arguments are somehow lost, try to get from SharedPreferences
            // This is a recovery mechanism.
            final SharedPreferences prefs = sharedPreferences; // Use global instance from main.dart
            // bool isAlarmFlagStillSet = prefs.getBool(AlarmDisplayService.prefsKeyIsAlarmScreenActive) ?? false;
            // if (isAlarmFlagStillSet) {
            //     screenId = prefs.getInt('current_ringing_alarm_id');
            //     screenTitle = prefs.getString('current_ringing_alarm_title');
            //     debugPrint("AppRoutes: Fallback from SharedPreferences - ID: $screenId, Title: $screenTitle (Flag was: $isAlarmFlagStillSet)");
            //     if (screenId == null || screenTitle == null) {
            //         debugPrint("AppRoutes: ERROR - SharedPreferences fallback failed, ID/Title still null despite flag.");
            //     }
            // } else {
            //      debugPrint("AppRoutes: SharedPreferences fallback skipped, alarm flag is false.");
            // }
        }

        if (screenId != null && screenTitle != null) {
          debugPrint("AppRoutes: Successfully found ID and Title. Navigating to AlarmScreen(id: $screenId, title: '$screenTitle')");
          // return AlarmScreen(id: screenId, title: screenTitle);
        }

        debugPrint("AppRoutes: CRITICAL ERROR - AlarmScreen route missing ID or Title AFTER all checks. Displaying error screen.");
        return Scaffold(
          backgroundColor: Colors.red[100],
          appBar: AppBar(title: const Text("Alarm Data Error"), backgroundColor: Colors.red, centerTitle: true,),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 70),
                  const SizedBox(height: 25),
                  const Text(
                    "Error: Alarm Data Missing",
                    style: TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Could not display the alarm because the required information (ID and Title) was not found. Please try again later.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                   const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.home),
                    label: const Text("Go to Home Screen", style: TextStyle(fontSize: 16)),
                    onPressed: () => Get.offAllNamed(YourAppRoutes.homeScreen),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey, foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    ),

    // *** ADD THE GetPage DEFINITION FOR YOUR ALARM LIST PAGE ***
    // GetPage(
    //   name: alarmListPage, // Use the constant defined above
    //   page: () => const AlarmListPage(), // Your AlarmListPage widget
    // ),
  ];
}