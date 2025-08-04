import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/views/pages/settings/settings_helpers/settings_utils.dart';
import 'package:budgify/views/pages/settings/settings_helpers/settings_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class DataManagementSection extends ConsumerWidget {
  const DataManagementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsSectionCard(
      title: 'Data'.tr,
      children: [
        SettingsNavigationButton(
          label: 'Clear Cache'.tr,
          onTap: () => SettingsUtils.deleteCache(context, ref),
          iconColor: AppColors.accentColor2,
        ),
        SettingsNavigationButton(
          label: 'Clear Data'.tr,
          onTap: () => SettingsUtils.deleteExpenses(context, ref),
          iconColor: AppColors.accentColor2,
        ),
      ],
    );
  }
}
