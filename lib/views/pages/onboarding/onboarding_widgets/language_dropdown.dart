import 'package:budgify/core/utils/scale_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

// Your existing imports
import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/viewmodels/providers/lang_provider.dart';
// UPDATED: Import the new responsive utility

class LanguageDropdown extends ConsumerWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // UPDATED: Use the new responsive extension
    final responsive = context.responsive;
    final currentLocale = ref.watch(languageProvider);
    final currentLanguage = _localeToLanguage(currentLocale);

    const languages = [
      'English',
      'Spanish',
      'French',
      'العربية',
      'German',
      'Chinese',
      'Portuguese',
    ];

    // UPDATED: Using PopupMenuButton for consistent UI/UX
    return PopupMenuButton<String>(
      color: AppColors.secondaryDarkColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive.setWidth(12)),
      ),
      offset: Offset(0, responsive.setHeight(50)),
      onSelected: (value) {
        ref.read(languageProvider.notifier).setLanguage(value);
      },
      itemBuilder: (context) {
        return languages.map((lang) {
          return PopupMenuItem<String>(
            value: lang,
            child: Text(lang, style: const TextStyle(color: Colors.white)),
          );
        }).toList();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.setWidth(16),
          vertical: responsive.setHeight(10),
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(responsive.setWidth(12)),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentLanguage,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: responsive.setSp(14),
              ),
            ),
            SizedBox(width: responsive.setWidth(8)),
            Icon(
              Icons.unfold_more_rounded,
              color: AppColors.accentColor,
              size: responsive.setWidth(20),
            ),
          ],
        ),
      ),
    );
  }

  // This helper function remains the same
  String _localeToLanguage(Locale locale) {
    const languageMap = {
      'es': 'Spanish',
      'fr': 'French',
      'ar': 'العربية',
      'de': 'German',
      'zh': 'Chinese',
      'pt': 'Portuguese',
      'en': 'English',
    };
    return languageMap[locale.languageCode] ?? 'English';
  }
}
