import 'package:flutter/material.dart';
import 'app_colors.dart';

class MainTheme {
  static final ThemeData theme = ThemeData(
    cardTheme: const CardTheme(color: AppColors.secondaryDarkColor),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: AppColors.secondaryDarkColor,
    ),
    brightness: Brightness.dark,
    primaryColor: AppColors.mainDarkColor,
    scaffoldBackgroundColor: AppColors.mainDarkColor,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.secondaryDarkColor,
      titleTextStyle: TextStyle(
        color: AppColors.titleColorDarkTheme,
        fontSize: 20,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textColorDarkTheme),
      bodyMedium: TextStyle(color: AppColors.secondaryTextColorDarkTheme),
      headlineLarge: TextStyle(color: AppColors.titleColorDarkTheme),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.mainDarkColor,
      secondary: AppColors.accentColor,
      error: AppColors.errorColor,
    ),
  );
}
