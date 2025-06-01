import 'package:permission_handler/permission_handler.dart';

Future<void> requestAlarmPermissions() async {
  await [
    Permission.scheduleExactAlarm,
    Permission.notification,
    Permission.ignoreBatteryOptimizations,
  ].request();
  // print('Alarm permissions requested');
}