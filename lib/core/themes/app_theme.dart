import 'package:budgify/core/themes/pink_theme.dart';
import 'package:budgify/core/themes/red_theme.dart';
import 'package:budgify/core/themes/yellow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgify/core/themes/purple_theme.dart';
import 'blue_theme.dart';
import 'brown_theme.dart';
import 'green_theme.dart';
import 'main_theme.dart';
// Ensure you import all theme files
import '../../viewmodels/providers/theme_provider.dart';

class AppTheme {
  // Use `ref.watch()` to react to changes in the theme
  static ThemeData getMainTheme(WidgetRef ref) {
    final themeModeOption =
        ref.watch(themeNotifierProvider); // Watch the theme state using ref

    switch (themeModeOption) {
      case ThemeModeOption.yellow:
        return YellowTheme.theme;
      case ThemeModeOption.dark:
        return MainTheme.theme;
      case ThemeModeOption.purple:
        return PurpleTheme.theme;
      case ThemeModeOption.pink:
        return PinkTheme.theme;
      case ThemeModeOption.green:
        return GreenTheme.theme;
      case ThemeModeOption.blue:
        return BlueTheme.theme;
      case ThemeModeOption.brown:
        return BrownTheme.theme;
      case ThemeModeOption.red:
        return RedTheme.theme;
      }
  }
}
