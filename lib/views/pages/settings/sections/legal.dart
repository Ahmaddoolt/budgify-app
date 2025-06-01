import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/views/pages/legal/about_app_page.dart';
import 'package:budgify/views/pages/legal/privacy_policy_page.dart';
import 'package:budgify/views/pages/legal/terms_of_us.dart';
import 'package:budgify/views/pages/settings/settings_helpers/settings_widget.dart';
import 'package:budgify/views/navigation/navigation_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class LegalSection extends StatelessWidget {
  const LegalSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'Legal'.tr,
      children: [
        SettingsNavigationButton(
          label: 'Privacy Policy'.tr,
          onTap: () => navigateTo(context, const PrivacyPolicyPage()),
          iconColor: AppColors.accentColor,
        ),
        SettingsNavigationButton(
          label: 'Terms of Use'.tr,
          onTap: () => navigateTo(context, const TermsOfUseScreen()),
          iconColor: AppColors.accentColor,
        ),
        SettingsNavigationButton(
          label: 'About Us'.tr,
          onTap: () => navigateTo(context, const AboutAppPage()),
          iconColor: AppColors.accentColor,
        ),
      ],
    );
  }
}