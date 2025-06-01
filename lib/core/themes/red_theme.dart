import 'package:budgify/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class RedTheme {
  static final ThemeData theme = ThemeData(
    cardTheme: const CardTheme(
      color: AppColors.secondaryDarkRedColor, // Dark Red
    ),
    bottomAppBarTheme: const BottomAppBarTheme(
      color: AppColors.secondaryDarkRedColor, // Dark Red
    ),
    brightness: Brightness.dark,
    primaryColor: AppColors.darkRedColor, // Deep Red
    scaffoldBackgroundColor: AppColors.darkRedColor, // Deep Red
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.secondaryDarkRedColor, // Dark Red
      titleTextStyle: TextStyle(
        color: AppColors.titleColorDarkTheme,
        fontSize: 20,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFFFEBEE)), // Light Red Tint
      bodyMedium: TextStyle(
          color: Color.fromARGB(255, 255, 235, 235)), // Soft Pinkish White
      headlineLarge: TextStyle(color: Color(0xFFFFCDD2)), // Muted Pink
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkRedColor, // Deep Red
      secondary: AppColors.accentColor,
      error: AppColors.errorColor,
    ),
  );
}
