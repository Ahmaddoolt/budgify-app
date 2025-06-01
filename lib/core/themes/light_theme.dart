import 'package:flutter/material.dart';
import 'app_colors.dart';

class LightTheme {
  static final ThemeData theme = ThemeData(
    cardTheme: const CardTheme(
      color: AppColors.secondaryBrightColor,
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: AppColors.secondaryBrightColor,
    ),
    brightness: Brightness.light,
    primaryColor: AppColors.mainBrightColor,
    scaffoldBackgroundColor: AppColors.mainBrightColor,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.secondaryBrightColor,
      titleTextStyle: TextStyle(
        color: AppColors.titleColorWhiteTheme,
        fontSize: 20,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textColorWhiteTheme),
      bodyMedium: TextStyle(color: AppColors.secondaryTextColorWhiteTheme),
      headlineLarge: TextStyle(color: AppColors.titleColorWhiteTheme),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.mainBrightColor,
      secondary: AppColors.accentColor,
      error: AppColors.errorColor,
    ),
  );
}
