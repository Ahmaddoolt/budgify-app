import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/viewmodels/providers/lang_provider.dart';
import 'package:get/get.dart';

class LanguageDropdown extends ConsumerWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);
    final currentLanguage = _localeToLanguage(currentLocale);

    const languages = [
      'English',
      'Spanish',
      'French',
      'Arabic',
      'German',
      'Chinese',
      'Portuguese',
    ];

    return DropdownButton<String>(
      dropdownColor: AppColors.secondaryDarkColor,
      value: currentLanguage,
      hint: Text(
        'Select Language'.tr,
        style: TextStyle(color: Theme.of(context).hintColor),
      ),
      items:
          languages
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) {
          ref.read(languageProvider.notifier).setLanguage(value);
        }
      },
    );
  }

  String _localeToLanguage(Locale locale) {
    const languageMap = {
      'es': 'Spanish',
      'fr': 'French',
      'ar': 'Arabic',
      'de': 'German',
      'zh': 'Chinese',
      'pt': 'Portuguese',
      'en': 'English',
    };
    return languageMap[locale.languageCode] ?? 'English';
  }
}
