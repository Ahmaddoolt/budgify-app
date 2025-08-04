// lib/views/pages/settings/appearance_settings.dart

import 'package:budgify/core/constants/currencies.dart';
import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/domain/models/currency.dart';
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

    // Get the full Currency object from the provider's state
    final appCurrencyState = ref.watch(currencyProvider);
    final currentCurrency = appCurrencyState.displayCurrency;

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
    Currency currentCurrency,
    BuildContext context,
  ) {
    return Material(
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showCurrencySearchDialog(context, ref);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Currency'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${currentCurrency.code.tr} (${currentCurrency.symbol})',
                    style: const TextStyle(fontSize: 14),
                  ),
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

  void _showCurrencySearchDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _CurrencySearchDialog(ref: ref),
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
      itemBuilder: (themeOption) => Row(
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
    required T selectedValue,
    required List<T> items,
    required Widget Function(T item) itemBuilder,
    required ValueChanged<T> onSelected,
    required BuildContext context,
  }) {
    return Material(
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
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
          ).shift(const Offset(0, 40));

          showMenu<T>(
            context: context,
            position: position,
            color: Theme.of(context).cardColor.withOpacity(0.98),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12 * 0.75),
            ),
            elevation: 4,
            items: items
                .map(
                  (item) => PopupMenuItem<T>(
                    value: item,
                    height: 40,
                    child: itemBuilder(item),
                  ),
                )
                .toList(),
          ).then((selected) {
            if (selected != null) {
              onSelected(selected);
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
                mainAxisSize: MainAxisSize.min,
                children: [
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

class _CurrencySearchDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _CurrencySearchDialog({required this.ref});

  @override
  ConsumerState<_CurrencySearchDialog> createState() =>
      _CurrencySearchDialogState();
}

class _CurrencySearchDialogState extends ConsumerState<_CurrencySearchDialog> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCurrencies = availableCurrencies.where((currency) {
      final query = _searchQuery.toLowerCase();
      final translatedName = currency.code.tr.toLowerCase();
      return translatedName.contains(query) ||
          currency.code.toLowerCase().contains(query);
    }).toList();

    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text('Select Currency'.tr),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0),
      content: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by name or code...'.tr,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredCurrencies.length,
                itemBuilder: (context, index) {
                  final currency = filteredCurrencies[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${currency.code.tr} (${currency.code})'),
                    trailing: Text(currency.symbol),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // Call the correct method to SAVE the default currency
                      widget.ref
                          .read(currencyProvider.notifier)
                          .saveDefaultCurrency(currency.code);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'.tr),
        ),
      ],
    );
  }
}
