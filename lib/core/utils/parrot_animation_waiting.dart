// Make sure you import your new responsive utility file
import 'package:budgify/core/utils/scale_config.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ParrotAnimation extends StatelessWidget {
  const ParrotAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Change `scaleConfig` to `responsive`
    final responsive = context.responsive;

    return Center(
      child: Lottie.asset(
        'assets/parrot.json',
        // 2. Change `scale.scale(75)` to `responsive.setWidth(75)`
        width: responsive.setWidth(75),
      ),
    );
  }
}
