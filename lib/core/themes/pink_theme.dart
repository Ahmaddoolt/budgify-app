import 'package:budgify/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class PinkTheme {
  static final ThemeData theme = ThemeData(
    cardTheme: const CardTheme(
      color: AppColors.secondaryDarkPinkColor, // Darker Pink
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: AppColors.secondaryDarkPinkColor, // Darker Pink
    ),
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPinkColor, // Deep Pink
    scaffoldBackgroundColor: AppColors.darkPinkColor, // Deep Pink
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.secondaryDarkPinkColor, // Darker Pink
      titleTextStyle: TextStyle(
        color: AppColors.titleColorDarkTheme,
        fontSize: 20,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFFFF3F5)), // Near White Pink
      bodyMedium: TextStyle(color: Color(0xFFFFC1E3)), // Muted Pink
      headlineLarge: TextStyle(color: Color(0xFFF8BBD0)), // Soft Pink
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPinkColor, // Deep Pink
      secondary: AppColors.accentColor, // Darker Pink
      error: AppColors.errorColor,
    ),
  );
}
