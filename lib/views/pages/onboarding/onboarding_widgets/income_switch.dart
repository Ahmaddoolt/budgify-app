import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/viewmodels/providers/switchOnOffIncome.dart';
import 'package:get/get.dart';

class IncomeSwitch extends ConsumerWidget {
  const IncomeSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSwitched = ref.watch(switchProvider).isSwitched;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Income Tracking'.tr),
        Switch(
          activeColor: AppColors.accentColor,
          activeTrackColor: AppColors.accentColor.withOpacity(0.5),
          value: isSwitched,
          onChanged: (value) {
            ref.read(switchProvider.notifier).toggleSwitch(value);
          },
        ),
      ],
    );
  }
}
