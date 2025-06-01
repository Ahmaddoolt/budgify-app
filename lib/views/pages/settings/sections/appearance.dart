import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/viewmodels/providers/currency_symbol.dart';
import 'package:budgify/viewmodels/providers/lang_provider.dart';
import 'package:budgify/viewmodels/providers/theme_provider.dart';
import 'package:budgify/views/pages/settings/settings_helpers/settings_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class AppearanceSettingsSection extends ConsumerWidget {
  const AppearanceSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);
    final currentLanguageName = _localeToLanguage(currentLocale);
    final currentThemeOption = ref.watch(themeNotifierProvider);
    final currentCurrency = ref.watch(currencyProvider).currencySymbol;

    return SettingsSectionCard(
      title: 'Appearance'.tr,
      children: [
        buildCurrencyPopup(ref, currentCurrency, context),
        buildLanguagePopup(ref, currentLanguageName, context),
        buildThemePopup(ref, currentThemeOption, context),
      ],
    );
  }

  Widget buildCurrencyPopup(
    WidgetRef ref,
    String currentCurrency,
    BuildContext context,
  ) {
    const availableCurrencies = [
      '\$',
      '€',
      '£',
      '¥',
      'A\$',
      'C\$',
      'Fr',
      '₹',
      '₩',
      '₺',
      '₽',
      '﷼',
      'د.إ',
      'E£',
      'ج.م',
    ];

    return buildPopupMenu<String>(
      label: 'Currency'.tr,
      selectedValue: currentCurrency.isEmpty ? '\$' : currentCurrency,
      items: availableCurrencies,
      itemBuilder: (currency) => Text(currency),
      onSelected: (value) {
        HapticFeedback.lightImpact();
        ref.read(currencyProvider.notifier).setCurrencySymbol(value);
      },
      context: context,
    );
  }

  Widget buildLanguagePopup(
    WidgetRef ref,
    String currentLanguageName,
    BuildContext context,
  ) {
    const availableLanguages = [
      'English',
      'Spanish',
      'French',
      'العربية',
      'German',
      'Chinese',
      'Portuguese',
    ];

    return buildPopupMenu<String>(
      label: 'Language'.tr,
      selectedValue: currentLanguageName,
      items: availableLanguages,
      itemBuilder: (langName) => Text(langName),
      onSelected: (value) {
        HapticFeedback.lightImpact();
        ref.read(languageProvider.notifier).setLanguage(value);
      },
      context: context,
    );
  }

  Widget buildThemePopup(
    WidgetRef ref,
    ThemeModeOption currentThemeOption,
    BuildContext context,
  ) {
    return buildPopupMenu<ThemeModeOption>(
      label: 'Theme'.tr,
      selectedValue: currentThemeOption,
      items: ThemeModeOption.values.toList(),
      itemBuilder:
          (themeOption) => Row(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(right: 8, left: 8),
                decoration: BoxDecoration(
                  color: _getThemeColor(themeOption),
                  shape: BoxShape.rectangle,
                ),
              ),
              Text(
                _themeToTranslationKey(themeOption).tr,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
      onSelected: (selectedOption) {
        HapticFeedback.lightImpact();
        ref.read(themeNotifierProvider.notifier).setTheme(selectedOption);
      },
      context: context,
    );
  }

  Widget buildPopupMenu<T>({
    required String label,
    required T
    selectedValue, // The actual selected data value (String, Enum, etc.)
    required List<T> items, // List of all possible data values
    required Widget Function(T item)
    itemBuilder, // Function to build the display widget for an item
    required ValueChanged<T>
    onSelected, // Callback with the selected data value
    required context,
  }) {
    return Material(
      // ignore: deprecated_member_use
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          // --- Position calculation (keep as before or adjust) ---
          final RenderBox button = context.findRenderObject() as RenderBox;
          final RenderBox overlay =
              Overlay.of(context).context.findRenderObject() as RenderBox;
          final RelativeRect position = RelativeRect.fromRect(
            Rect.fromPoints(
              button.localToGlobal(Offset.zero, ancestor: overlay),
              button.localToGlobal(
                button.size.bottomRight(Offset.zero),
                ancestor: overlay,
              ),
            ),
            Offset.zero & overlay.size,
          ).shift(const Offset(0, 40)); // Shift dropdown below the button row

          showMenu<T>(
            // Use the generic type T
            context: context,
            position: position,
            // ignore: deprecated_member_use
            color: Theme.of(context).cardColor.withOpacity(0.98),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12 * 0.75),
            ),
            elevation: 4,
            items:
                items
                    .map(
                      (item) => PopupMenuItem<T>(
                        // Use T here too
                        value: item, // The actual data value T
                        height: 40,
                        // Use the provided builder to create the widget for the list item
                        child: itemBuilder(item),
                      ),
                    )
                    .toList(),
          ).then((selected) {
            if (selected != null) {
              onSelected(selected); // Pass back the selected data value T
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                mainAxisSize:
                    MainAxisSize.min, // Prevent row from taking too much space
                children: [
                  // Use the item builder to display the currently selected value
                  itemBuilder(selectedValue),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).hintColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
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

  String _themeToTranslationKey(ThemeModeOption theme) {
    return theme.toString().split('.').last;
  }

  Color _getThemeColor(ThemeModeOption theme) {
    switch (theme) {
      case ThemeModeOption.dark:
        return AppColors.mainDarkColor;
      case ThemeModeOption.purple:
        return AppColors.darkPurpleColor;
      case ThemeModeOption.yellow:
        return AppColors.darkYellowColor;
      case ThemeModeOption.pink:
        return AppColors.darkPinkColor;
      case ThemeModeOption.green:
        return AppColors.darkGreenColor;
      case ThemeModeOption.blue:
        return AppColors.darkBlueColor;
      case ThemeModeOption.brown:
        return AppColors.darkBrownColor;
      case ThemeModeOption.red:
        return AppColors.darkRedColor;
    }
  }

}
