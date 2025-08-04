import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/url_luncher_button.dart';
import 'package:budgify/views/pages/legal/about_app_page.dart';
import 'package:budgify/views/pages/legal/privacy_policy_page.dart';
import 'package:budgify/views/pages/legal/terms_of_us.dart';
import 'package:budgify/views/pages/settings/settings_helpers/settings_widget.dart';
import 'package:budgify/core/navigation/navigation_pages.dart';
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
          onTap: () {
            launchExternalUrl(
                'https://doc-hosting.flycricket.io/budgify-privacy-policy/2f72fcc0-a478-479a-8519-09a0e0d7ce34/privacy');
          },
          iconColor: AppColors.accentColor,
        ),
        SettingsNavigationButton(
          label: 'Terms of Use'.tr,
          onTap: () {
            launchExternalUrl(
                'https://doc-hosting.flycricket.io/budgify-terms-of-use/160dfe11-3038-4c3a-ba97-10ce73ae7963/terms');
          },
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
