import 'package:budgify/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class BrownTheme {
  static final ThemeData theme = ThemeData(
    cardTheme: const CardTheme(
      color: AppColors.secondaryDarkBrownColor, // Medium Purple
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: AppColors.secondaryDarkBrownColor, // Medium Purple
    ),
    brightness: Brightness.dark,
    primaryColor: AppColors.darkBrownColor, // Deep Purple
    scaffoldBackgroundColor: AppColors.darkBrownColor, // Deep Purple
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.secondaryDarkBrownColor, // Medium Purple
      titleTextStyle: TextStyle(
        color: AppColors.titleColorDarkTheme,
        fontSize: 20,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFEDE7F6)), // Near White Purple
      bodyMedium: TextStyle(color: Color.fromARGB(255, 254, 254, 254)), // Muted Lavender
      headlineLarge: TextStyle(color: Color(0xFFD1C4E9)), // Soft Lavender
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkBrownColor, // Deep Purple
      secondary: AppColors.accentColor,
      error: AppColors.errorColor,
    ),
  );
}
