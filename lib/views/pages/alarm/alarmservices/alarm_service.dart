import 'dart:async';
// import 'package:alarm/alarm.dart'; // Keep this if you use Alarm.stop() etc.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgify/views/pages/alarm/alarmscreen.dart';
import 'package:budgify/views/pages/alarm/alarmservices/alarm_display_service.dart';

final alarmServiceProvider = StateNotifierProvider<AlarmService, bool>((ref) {
  final service = AlarmService(ref);
  service.init(); // Call init here
  return service;
});

class AlarmService extends StateNotifier<bool> {
  AlarmService(this.ref) : super(false);

  final Ref ref;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // StreamSubscription<AlarmSettings>? _alarmSubscription; // REMOVED - main.dart listens

  Future<void> init() async {
    if (state) {
      debugPrint('AlarmService (Riverpod): Already initialized.');
      return;
    }
    debugPrint('AlarmService (Riverpod): Initializing...');
    // DO NOT LISTEN TO Alarm.ringStream HERE. main.dart has the single listener.
    state = true;
    debugPrint('AlarmService (Riverpod): Initialized (no longer listening to stream directly).');
  }

  // This method can still be called if you need to programmatically show the alarm screen
  // from within Flutter logic, NOT as a direct response to Alarm.ringStream.
  void showAlarmScreenUrgently(int alarmId, String title) {
    final alarmDisplayNotifier = ref.read(alarmDisplayServiceProvider.notifier);
    if (alarmDisplayNotifier.isScreenActive()) {
        debugPrint('AlarmService (Riverpod): showAlarmScreenUrgently - Screen already active for ID $alarmId.');
        return;
    }
    alarmDisplayNotifier.setAlarmScreenActive(true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context != null && ModalRoute.of(context)?.isCurrent == true) {
        // Basic check if current route is already this specific alarm screen
        final currentRoute = ModalRoute.of(context);
        bool alreadyOnThisAlarmScreen = false;
        if (currentRoute?.settings.name == '/alarm' && currentRoute?.settings.arguments is Map) {
            final args = currentRoute?.settings.arguments as Map;
            if (args['id'] == alarmId) {
                alreadyOnThisAlarmScreen = true;
            }
        }

        if (alreadyOnThisAlarmScreen) {
             debugPrint('AlarmService (Riverpod): Already on AlarmScreen for ID $alarmId. Not pushing new one.');
             return;
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            settings: RouteSettings(name: '/alarm', arguments: {'id': alarmId, 'title': title}),
            builder: (ctx) => AlarmScreen(id: alarmId, title: title),
          ),
        ).then((_) {
          debugPrint('AlarmService (Riverpod): AlarmScreen for ID $alarmId was popped.');
          // AlarmScreen should handle setting AlarmDisplayService to false on its own stop/dispose
        });
        debugPrint('AlarmService (Riverpod): Navigated to AlarmScreen for ID $alarmId, Title "$title"');
      } else {
        debugPrint('AlarmService (Riverpod): navigatorKey.currentContext is null or not current. Cannot navigate.');
        alarmDisplayNotifier.setAlarmScreenActive(false); // Reset if navigation failed
      }
    });
  }

  @override
  void dispose() {
    debugPrint('AlarmService (Riverpod): Disposing...');
    // _alarmSubscription?.cancel(); // REMOVED
    // _alarmSubscription = null;    // REMOVED
    super.dispose();
  }
}