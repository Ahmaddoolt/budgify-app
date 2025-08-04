import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import 'sections/appearance.dart';
import 'sections/preferences.dart';
import 'sections/data_management.dart';
import 'sections/legal.dart';
// import '../alarm/add_alarm/alarm_list_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        // actions: [
        //   IconButton(  
        //     onPressed: () => Get.to(() => const AlarmListPage()),
        //     icon: const Icon(Icons.alarm_add, color: AppColors.accentColor),
        //     tooltip: 'Alarm Reminders'.tr,
        //   ),
        // ],
        title: Text(
          'Settings'.tr,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          SizedBox(height: 16),
          AppearanceSettingsSection(),
          PreferencesSettingsSection(),
          DataManagementSection(),
          LegalSection(),
        ],
      ),
    );
  }
}