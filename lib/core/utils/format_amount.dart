import 'package:budgify/viewmodels/providers/lang_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/providers/thousands_separator_provider.dart';

String getFormattedAmount(double amount, WidgetRef ref) {
  final useSeparator = ref.watch(separatorProvider).isSeparatorEnabled;
  bool isArabic = ref.watch(languageProvider).toString() == 'ar' ? true : false;
  
  String formatNumber(String number) {
    if (!isArabic) return number;
    return number.replaceAllMapped(RegExp(r'[0-9]'), (match) {
      switch (match.group(0)) {
        case '0': return '٠';
        case '1': return '١';
        case '2': return '٢';
        case '3': return '٣';
        case '4': return '٤';
        case '5': return '٥';
        case '6': return '٦';
        case '7': return '٧';
        case '8': return '٨';
        case '9': return '٩';
        default: return match.group(0)!;
      }
    });
  }

  if (!useSeparator) {
    if (amount >= 1000000) {
      final value = amount / 1000000;
      final formattedNumber = value == value.roundToDouble()
          ? '${value.round()}'
          : value.toStringAsFixed(1);
      return isArabic 
          ? '${formatNumber(formattedNumber)} مليون'  // "Million" in Arabic
          : '${formatNumber(formattedNumber)}M';
    } else if (amount >= 1000) {
      final value = amount / 1000;
      final formattedNumber = value == value.roundToDouble()
          ? '${value.round()}'
          : value.toStringAsFixed(1);
      return isArabic 
          ? '${formatNumber(formattedNumber)} ألف'  // "Thousand" in Arabic
          : '${formatNumber(formattedNumber)}K';
    } else {
      return formatNumber(amount.toStringAsFixed(0)); // No decimals for amounts < 1000
    }
  } else {
    return formatNumber(NumberFormat('#,##0').format(amount)); // Thousands separator
  }
}