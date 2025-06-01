import 'package:budgify/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class YellowTheme {
  static final ThemeData theme = ThemeData(
    cardTheme: const CardTheme(
      color: AppColors.secondaryYellowColor, // Medium Yellow
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: AppColors.secondaryYellowColor, // Medium Yellow
    ),
    brightness: Brightness.dark,
    primaryColor: AppColors.darkYellowColor, // Deep Yellow
    scaffoldBackgroundColor: AppColors.darkYellowColor, // Deep Yellow
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.secondaryYellowColor, // Medium Yellow
      titleTextStyle: TextStyle(
        color: AppColors.titleColorDarkTheme,
        fontSize: 20,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color.fromARGB(255, 255, 255, 255)), // Near White Yellow
      bodyMedium: TextStyle(color: Color.fromARGB(255, 250, 250, 250)), // Muted Yellow
      headlineLarge: TextStyle(color: Color.fromARGB(255, 255, 250, 201)), // Soft Yellow
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkYellowColor, // Deep Yellow
      secondary: AppColors.accentColor, // Cyan
      error: AppColors.errorColor,
    ),
  );
}
