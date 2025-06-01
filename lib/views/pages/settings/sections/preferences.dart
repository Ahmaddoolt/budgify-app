import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:budgify/core/utils/snackbar_helper.dart';
import 'package:budgify/viewmodels/providers/notification_provider.dart';
import 'package:budgify/viewmodels/providers/sound_switch.dart';
import 'package:budgify/viewmodels/providers/switchOnOffIncome.dart';
import 'package:budgify/viewmodels/providers/thousands_separator_provider.dart';
import 'package:budgify/views/pages/settings/settings_helpers/settings_dialogs.dart';
import 'package:budgify/views/pages/settings/settings_helpers/settings_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class PreferencesSettingsSection extends ConsumerWidget {
  const PreferencesSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncomeTrackingEnabled = ref.watch(switchProvider).isSwitched;
    final isSeparatorEnabled = ref.watch(separatorProvider).isSeparatorEnabled;
    final isNotificationEnabled = ref.watch(notificationProvider).isEnabled;
    final soundState = ref.watch(soundSwitchProvider);

    return SettingsSectionCard(
      title: 'Preferences'.tr,
      children: [
        SettingsSwitchRow(
          label: 'Income Tracking'.tr,
          value: isIncomeTrackingEnabled,
          onChanged:
              (value) => ref.read(switchProvider.notifier).toggleSwitch(value),
        ),
        SettingsSwitchRow(
          label: 'Thousands Separator'.tr,
          value: isSeparatorEnabled,
          onChanged:
              (value) =>
                  ref.read(separatorProvider.notifier).toggleSeparator(value),
        ),
        SettingsSwitchRow(
          label: 'Daily Notifications'.tr,
          value: isNotificationEnabled,
          onChanged: (value) => _toggleNotification(value, ref, context),
        ),
        SettingsSwitchRow(
          label: 'Enable Tap Sound'.tr,
          value: soundState.isSoundEnabled,
          onChanged: (newValue) => _toggleSound(newValue, ref, context),
        ),
      ],
    );
  }

  Future<void> _toggleNotification(
    bool value,
    WidgetRef ref,
    BuildContext context,
  ) async {
    HapticFeedback.lightImpact();
    final notifier = ref.read(notificationProvider.notifier);
    // final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (value) {
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        if (!context.mounted) return;
        bool? shouldRequest = await SettingsDialogs.showConfirmationDialog(
          context: context,
          title: 'Allow Notifications'.tr,
          content:
              'Would you like to receive daily budget reminders to help you stay on track with your expenses?'
                  .tr,
          confirmText: 'Allow'.tr,
          cancelText: 'Deny'.tr,
        );

        if (shouldRequest != true) return;
        isAllowed =
            await AwesomeNotifications().requestPermissionToSendNotifications();
        if (!isAllowed) {
          // ignore: use_build_context_synchronously
          showFeedbackSnackbar(context, 'Notification permissions denied'.tr);

          return;
        }
      }
    }

    await notifier.toggleNotification(value);
    showFeedbackSnackbar(
      // ignore: use_build_context_synchronously
      context,
      value
          ? 'Daily notifications enabled'.tr
          : 'Daily notifications disabled'.tr,
    );
  }

  Future<void> _toggleSound(
    bool newValue,
    WidgetRef ref,
    BuildContext context,
  ) async {
    HapticFeedback.lightImpact();
    try {
      await ref.read(soundSwitchProvider.notifier).toggleSound(newValue);
      debugPrint('✅ Toggled sound to: $newValue');
      showFeedbackSnackbar(
        // ignore: use_build_context_synchronously
        context,
        newValue ? 'Tap sound enabled'.tr : 'Tap sound disabled'.tr,
      );
    } catch (e) {
      debugPrint('❌ Error toggling sound: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving sound setting'.tr)),
        );
      }
    }
  }
}
