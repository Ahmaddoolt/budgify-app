import 'package:flutter/material.dart';

extension ThemeContext on BuildContext {
  ThemeData get appTheme => Theme.of(this);
  TextTheme get appTextTheme => Theme.of(this).textTheme;
  ScaleConfig get scaleConfig => ScaleConfig(this);
}

class ScaleConfig {
  final double referenceWidth;
  final double referenceHeight;
  final double referenceDPI;
  final double screenWidth;
  final double screenHeight;
  final double scaleWidth;
  final double scaleHeight;
  final double textScaleFactor;
  final Orientation orientation;
  final double devicePixelRatio;

  ScaleConfig._({
    required this.referenceWidth,
    required this.referenceHeight,
    required this.referenceDPI,
    required this.screenWidth,
    required this.screenHeight,
    required this.scaleWidth,
    required this.scaleHeight,
    required this.textScaleFactor,
    required this.orientation,
    required this.devicePixelRatio,
  });

  factory ScaleConfig(
    BuildContext context, {
    double refWidth = 375,
    double refHeight = 812,
    double refDPI = 326,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;
    final orientation = mediaQuery.orientation;
    // ignore: deprecated_member_use
    final textScale = mediaQuery.textScaleFactor;
    final devicePixelRatio = mediaQuery.devicePixelRatio;

    return ScaleConfig._(
      referenceWidth: refWidth,
      referenceHeight: refHeight,
      referenceDPI: refDPI,
      screenWidth: width,
      screenHeight: height,
      scaleWidth: width / refWidth,
      scaleHeight: height / refHeight,
      textScaleFactor: textScale,
      orientation: orientation,
      devicePixelRatio: devicePixelRatio,
    );
  }

  double get scaleFactor {
    final baseScale = scaleWidth < scaleHeight ? scaleWidth : scaleHeight;
    final dpiRatio = devicePixelRatio / (referenceDPI / 160);
    // Reduce DPI scaling impact for high-DPI devices
    final dpiScale = 1.0 + (dpiRatio - 1.0) * 0.05; // More conservative
    final landscapeMultiplier =
        orientation == Orientation.landscape ? 1.05 : 1.0;
    return baseScale * dpiScale * landscapeMultiplier;
  }

  double scale(double size) {
    return (size * scaleFactor).clamp(size * 0.8, size * 2.0); // Looser clamp
  }

  double scaleText(double fontSize) {
    // Respect system textScaleFactor more, but cap it to prevent extreme scaling
    double adjustedTextScaleFactor = textScaleFactor.clamp(0.7, 1.5);
    double scaledSize = fontSize * scaleFactor * adjustedTextScaleFactor;

    // Apply stronger reduction for very high-DPI devices
    if (devicePixelRatio > 3.0) {
      scaledSize *= 0.85; // Stronger reduction for Redmi 12 Pro
    } else if (devicePixelRatio > 2.5) {
      scaledSize *= 0.9;
    }

    // Tighter clamp to prevent oversized text
    return scaledSize.clamp(fontSize * 0.7, fontSize * 1.3);
  }

  bool get isTablet {
    final shortestSide =
        screenWidth < screenHeight ? screenWidth : screenHeight;
    final longestSide = screenWidth > screenHeight ? screenWidth : screenHeight;
    return shortestSide > 600 && longestSide > 900;
  }

  double tabletScale(double size) {
    final baseScaledSize = scale(size);
    if (isTablet) {
      return baseScaledSize * 1.1;
    }
    return baseScaledSize;
  }

  double widthPercentage(double percentage) {
    return screenWidth * percentage;
  }

  double tabletScaleText(double fontSize) {
    final baseScaledSize = scaleText(fontSize);
    if (isTablet) {
      return baseScaledSize * 1.1;
    }
    return baseScaledSize;
  }
}
