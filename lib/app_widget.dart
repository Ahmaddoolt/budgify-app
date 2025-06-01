import 'package:budgify/core/lang.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:budgify/views/navigation/app_routes.dart';
import 'package:budgify/viewmodels/providers/theme_provider.dart';
import 'package:budgify/core/themes/app_theme.dart';
import 'package:budgify/viewmodels/providers/lang_provider.dart';
import 'package:budgify/views/pages/alarm/alarmservices/alarm_service.dart';

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
    final alarmServiceNotifier = ref.watch(alarmServiceProvider.notifier);

    return GetMaterialApp(
      navigatorKey: alarmServiceNotifier.navigatorKey,
      debugShowCheckedModeBanner: false,
      translations: Lang(),
      title: 'Budgify',
      theme: currentTheme,
      themeMode:
          themeMode == ThemeModeOption.dark ? ThemeMode.dark : ThemeMode.light,
      locale: locale,
      textDirection: locale.toString() == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      initialRoute: widget.initialRoute,
      getPages: YourAppRoutes.routes,
    );
  }
}
