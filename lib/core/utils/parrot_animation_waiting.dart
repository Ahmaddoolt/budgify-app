import 'package:budgify/core/utils/scale_config.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ParrotAnimation extends StatelessWidget {
  const ParrotAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = context.scaleConfig;

    return Center(
      child: Lottie.asset(
        'assets/parrot.json',
        width: scale.scale(75),
      ),
    );
  }
}
