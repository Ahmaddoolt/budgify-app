import 'dart:math';
import 'package:flutter/material.dart';

// New, cleaner extension for easy access
extension ResponsiveContext on BuildContext {
  ResponsiveUtil get responsive => ResponsiveUtil.of(this);
}

class ResponsiveUtil {
  // --- STATIC CONFIGURATION ---
  // You can change the reference dimensions here
  static const double _refWidth = 375;
  static const double _refHeight = 812;

  // --- DEVICE PROPERTIES ---
  final double screenWidth;
  final double screenHeight;
  final Orientation orientation;

  // Private constructor
  ResponsiveUtil._({
    required this.screenWidth,
    required this.screenHeight,
    required this.orientation,
  });

  // Static factory method to create an instance
  factory ResponsiveUtil.of(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;
    final orientation = mediaQuery.orientation;
    return ResponsiveUtil._(
      screenWidth: width,
      screenHeight: height,
      orientation: orientation,
    );
  }

  // --- SCALING LOGIC ---

  /// The ratio of the screen's width to the reference width.
  double get scaleWidth => screenWidth / _refWidth;

  /// The ratio of the screen's height to the reference height.
  double get scaleHeight => screenHeight / _refHeight;

  /// A balanced scaling factor, taking the minimum of width and height scaling.
  /// This prevents distortion on screens with unusual aspect ratios.
  double get scaleFactor => min(scaleWidth, scaleHeight);

  /// Scales a value based on the screen's width.
  /// Ideal for widths, horizontal padding, margins, etc.
  double setWidth(num value) => value * scaleWidth;

  /// Scales a value based on the screen's height.
  /// Ideal for heights, vertical padding, margins, etc.
  double setHeight(num value) => value * scaleHeight;

  /// Scales font size. It uses the balanced `scaleFactor` to ensure
  /// text is readable on all screen sizes.
  double setSp(num value) => value * scaleFactor;

  /// Returns a percentage of the screen's width.
  double widthPercent(double percent) => screenWidth * percent;

  /// Returns a percentage of the screen's height.
  double heightPercent(double percent) => screenHeight * percent;

  /// A check for tablet devices based on the shortest side.
  bool get isTablet {
    final shortestSide =
        screenWidth < screenHeight ? screenWidth : screenHeight;
    return shortestSide > 600;
  }
}

/// A widget that clamps the system's text scale factor to prevent UI breaking.
/// Wrap your MaterialApp or individual Scaffolds with this.
class ClampedTextScale extends StatelessWidget {
  final Widget child;
  const ClampedTextScale({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    // Clamp the textScaleFactor between 0.9 (90%) and 1.2 (120%) of the original size.
    final clampedTextScaleFactor = mediaQueryData.textScaleFactor.clamp(
      0.9,
      1.2,
    );

    return MediaQuery(
      data: mediaQueryData.copyWith(textScaleFactor: clampedTextScaleFactor),
      child: child,
    );
  }
}
