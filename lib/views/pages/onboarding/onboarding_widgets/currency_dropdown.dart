// lib/widgets/currency_dropdown.dart

import 'package:budgify/core/constants/currencies.dart';
import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/domain/models/currency.dart';
import 'package:budgify/viewmodels/providers/currency_symbol.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class CurrencyDropdown extends ConsumerWidget {
  const CurrencyDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = context.responsive;
    // Access the 'displayCurrency' property from the new state object
    final currentSelectedCurrency = ref.watch(currencyProvider).displayCurrency;

    return PopupMenuButton<Currency>(
      color: AppColors.secondaryDarkColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive.setWidth(12)),
      ),
      offset: Offset(0, responsive.setHeight(50)),
      onSelected: (newlySelectedCurrency) {
        // This only changes the temporary display state during onboarding
        ref
            .read(currencyProvider.notifier)
            .changeDisplayCurrency(newlySelectedCurrency.code);
      },
      itemBuilder: (context) {
        return availableCurrencies.map((currency) {
          return PopupMenuItem<Currency>(
            value: currency,
            child: Row(
              children: [
                Text(
                  '${currency.code.tr} (${currency.symbol})',
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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
              '${currentSelectedCurrency.symbol}  ${currentSelectedCurrency.code.tr}',
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
}
