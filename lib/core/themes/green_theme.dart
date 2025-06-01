import 'package:budgify/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class GreenTheme {
  static final ThemeData theme = ThemeData(
    cardTheme: const CardTheme(
      color: AppColors.secondaryDarkGreenColor, // Medium Purple
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: AppColors.secondaryDarkGreenColor, // Medium Purple
    ),
    brightness: Brightness.dark,
    primaryColor: AppColors.darkGreenColor, // Deep Purple
    scaffoldBackgroundColor: AppColors.darkGreenColor, // Deep Purple
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.secondaryDarkGreenColor, // Medium Purple
      titleTextStyle: TextStyle(
        color: AppColors.titleColorDarkTheme,
        fontSize: 20,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFEDE7F6)), // Near White Purple
      bodyMedium: TextStyle(
          color: Color.fromARGB(255, 254, 254, 254)), // Muted Lavender
      headlineLarge: TextStyle(color: Color(0xFFD1C4E9)), // Soft Lavender
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkGreenColor, // Deep Purple
      secondary: AppColors.accentColor,
      error: AppColors.errorColor,
    ),
  );
}
