import 'package:budgify/core/lang.dart';
// import 'package:budgify/core/utils/scale_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:budgify/core/navigation/app_routes.dart';
import 'package:budgify/viewmodels/providers/theme_provider.dart';
import 'package:budgify/core/themes/app_theme.dart';
import 'package:budgify/viewmodels/providers/lang_provider.dart';
// import 'package:budgify/views/pages/alarm/alarmservices/alarm_service.dart';

class MyApp extends ConsumerStatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final currentTheme = AppTheme.getMainTheme(ref);
    final locale = ref.watch(languageProvider);
    // final alarmServiceNotifier = ref.watch(alarmServiceProvider.notifier);

    // <-- REMOVED: The ClampedTextScale widget is replaced by the builder property below.
    // return ClampedTextScale(
    //   child: GetMaterialApp(...),
    // );

    return GetMaterialApp(
      // navigatorKey: alarmServiceNotifier.navigatorKey,

      // ==========================================================
      //  SOLUTION: THIS FIXES THE FONT SCALING ISSUE GLOBALLY
      // ==========================================================
      builder: (context, child) {
        return MediaQuery(
          // This forces the text scale factor to 1.0, ignoring device settings.
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.12),
          ),
          // The 'child' is the navigator and the rest of your app.
          // It's important to return it here.
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      translations: Lang(),
      title: 'Budgify',
      theme: currentTheme,
      themeMode:
          themeMode == ThemeModeOption.dark ? ThemeMode.dark : ThemeMode.light,
      locale: locale,
      textDirection:
          locale.toString() == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      initialRoute: widget.initialRoute,
      getPages: YourAppRoutes.routes,
    );
  }
}
