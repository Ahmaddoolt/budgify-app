import 'package:flutter/material.dart';

class AppColors {
  // Dark Theme Base Colors
  static const Color mainDarkColor = Color(0xff1c1c28);
  static const Color secondaryDarkColor = Color(0xff16161D);
  
  // Accent Colors
  static const Color accentColor = Color(0xff00BCD4);  // Cyan
  static const Color accentColor2 = Color(0xffFF5722); // Deep Orange
  
  // Text Colors
  static const Color titleColorDarkTheme = Colors.white;
  static const Color textColorDarkTheme = Color(0xffE0E0E0);
  static const Color secondaryTextColorDarkTheme = Color(0xffB0B0B0);
  
  static const Color titleColorWhiteTheme = Colors.black;
  static const Color textColorWhiteTheme = Color(0xff333333);
  static const Color secondaryTextColorWhiteTheme = Color(0xff757575);
  
  // Status Colors
  static const Color errorColor = Color(0xffF44336);
  static const Color successColor = Color(0xff4CAF50);
  static const Color warningColor = Color(0xffFFC107);
  
  // Color Palette - Dark Variants
  static const Color darkRedColor = Color.fromARGB(255, 120, 30, 30);       // Increased contrast
  static const Color secondaryDarkRedColor = Color.fromARGB(255, 80, 20, 20);
  
  static const Color darkPurpleColor = Color(0xff5E35B1);                   // More vibrant
  static const Color secondaryDarkPurpleColor = Color.fromARGB(255, 62, 35, 141);
  
  static const Color darkBrownColor = Color(0xff5D4037);                    // Less muddy
  static const Color secondaryDarkBrownColor = Color.fromARGB(255, 52, 33, 29);
  
  static const Color darkBlueColor = Color(0xff1976D2);                     // More standard blue
  static const Color secondaryDarkBlueColor = Color.fromARGB(255, 11, 59, 132);
  
  static const Color darkGreenColor = Color(0xff2E7D32);                    // Brighter green
  static const Color secondaryDarkGreenColor = Color.fromARGB(255, 20, 70, 24);
  
  static const Color darkPinkColor = Color(0xffAD1457);                     // More vibrant
  static const Color secondaryDarkPinkColor = Color.fromARGB(255, 97, 10, 57);
  
  static const Color darkYellowColor = Color.fromARGB(255, 178, 150, 0);    // More visible
  static const Color secondaryYellowColor = Color.fromARGB(255, 101, 84, 1);
  
  // Light Theme Base Colors
  static const Color mainBrightColor = Colors.white;
  static const Color secondaryBrightColor = Color(0xffF5F5F5);
  
  // Additional Utility Colors
  static const Color disabledColor = Color(0xff9E9E9E);
  static const Color dividerColor = Color(0xffE0E0E0);
}

Color applyOpacity(Color color, double opacity) {
  final alpha = (opacity * 255).round().clamp(0, 255);
  return color.withAlpha(alpha);
}