import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/viewmodels/providers/currency_symbol.dart';
import 'package:get/get.dart';

class CurrencyDropdown extends ConsumerWidget {
  const CurrencyDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCurrency = ref.watch(currencyProvider).currencySymbol;

    const currencySymbols = [
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

    return DropdownButton<String>(
      dropdownColor: AppColors.secondaryDarkColor,
      value: currentCurrency.isEmpty ? null : currentCurrency,
      hint: Text(
        'Select Currency'.tr, // Using GetX localization
        style: TextStyle(color: Theme.of(context).hintColor),
      ),
      items:
          currencySymbols
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) {
          ref.read(currencyProvider.notifier).setCurrencySymbol(value);
        }
      },
    );
  }
}
