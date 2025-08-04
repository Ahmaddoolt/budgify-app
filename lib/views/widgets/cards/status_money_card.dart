import 'dart:math';
import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/data/repo/expenses_repository.dart';
import 'package:budgify/domain/models/currency.dart';
import 'package:budgify/domain/models/expense.dart';
import 'package:budgify/viewmodels/providers/lang_provider.dart';
import 'package:budgify/views/widgets/cards/progress_row.dart';
import 'package:budgify/core/utils/format_amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

class SavingsCard extends ConsumerWidget {
  // --- THE FIX: Accept the currency object as a parameter ---
  final Currency currency;

  const SavingsCard({
    super.key,
    required this.currency,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = context.responsive;
    List<String> imageNames = [
      "pppigo",
      "save9",
      "money_s",
      "cash_fly",
      "digital_card",
      "bud_splash",
      "cash_money_wallet",
    ];
    String monthName = DateFormat.MMM().format(DateTime.now());
    int randomIndex = Random().nextInt(imageNames.length);
    final language = ref.watch(languageProvider).toString();

    return StreamBuilder<List<CashFlow>>(
      stream: ExpensesRepository().getExpensesStream(),
      builder: (context, snapshot) {
        double cardWidth = responsive.isTablet
            ? responsive.widthPercent(0.92)
            : responsive.widthPercent(0.92);
        double cardHeight = responsive.isTablet
            ? responsive.setHeight(180)
            : responsive.setHeight(162);
        double padding = responsive.setWidth(12);
        double borderRadius = responsive.setWidth(12);
        Color cardColor = Theme.of(context).cardTheme.color!;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: Card(
                  elevation: 4,
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius)),
                  child: Container(
                      width: cardWidth,
                      height: cardHeight,
                      padding: EdgeInsets.all(padding),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(borderRadius)))));
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}'.tr,
                  style: TextStyle(
                      fontSize: responsive.setSp(16), color: Colors.red)));
        }

        var allTransactions = snapshot.data ?? [];
        double totalExpenses = 0.0;
        double totalIncome = 0.0;

        // --- THE FIX: Filter calculations by the passed currencyCode ---
        for (var transaction in allTransactions) {
          if (transaction.date.month == DateTime.now().month &&
              transaction.date.year == DateTime.now().year &&
              transaction.currencyCode == currency.code) {
            // <-- The Fix
            if (transaction.isIncome) {
              totalIncome += transaction.amount;
            } else {
              totalExpenses += transaction.amount;
            }
          }
        }

        var totalSpent = totalExpenses;
        var savings = totalIncome - totalExpenses;

        return Card(
          elevation: 4,
          color: cardColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius)),
          child: Container(
            width: cardWidth,
            height: cardHeight,
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      language == 'ar'
                          ? Row(children: [
                              Text('Savings'.tr,
                                  style: TextStyle(
                                      fontSize: responsive.setSp(15.5),
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColorDarkTheme)),
                              SizedBox(width: responsive.setWidth(4)),
                              Text(monthName.tr,
                                  style: TextStyle(
                                      fontSize: responsive.setSp(15.5),
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColorDarkTheme),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ])
                          : Row(children: [
                              Text(monthName.tr,
                                  style: TextStyle(
                                      fontSize: responsive.setSp(15.5),
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColorDarkTheme),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              SizedBox(width: responsive.setWidth(4)),
                              Text('Savings'.tr,
                                  style: TextStyle(
                                      fontSize: responsive.setSp(15.5),
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textColorDarkTheme)),
                            ]),
                      SizedBox(height: responsive.setHeight(0)),
                      // --- THE FIX: Use the passed currency.symbol for display ---
                      language == 'ar'
                          ? Text(
                              savings <= 0
                                  ? '0 ${currency.symbol}'
                                  : '${getFormattedAmount(savings, ref)} ${currency.symbol}',
                              style: TextStyle(
                                  fontSize: responsive.setSp(18.5),
                                  fontWeight: FontWeight.bold,
                                  color: savings <= 0
                                      ? AppColors.accentColor2
                                      : AppColors.accentColor),
                            )
                          : Text(
                              savings <= 0
                                  ? '${currency.symbol} 0'
                                  : '${currency.symbol} ${getFormattedAmount(savings, ref)}',
                              style: TextStyle(
                                  fontSize: responsive.setSp(18.5),
                                  fontWeight: FontWeight.bold,
                                  color: savings <= 0
                                      ? AppColors.accentColor2
                                      : AppColors.accentColor),
                            ),
                      SizedBox(height: responsive.setHeight(0)),
                      SizedBox(
                        width: responsive.isTablet
                            ? responsive.setWidth(200)
                            : responsive.setWidth(164),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                  Icon(Icons.arrow_downward,
                                      color: AppColors.accentColor2,
                                      size: responsive.isTablet
                                          ? responsive.setWidth(15)
                                          : responsive.setWidth(13.5)),
                                  SizedBox(width: responsive.setWidth(2)),
                                  Flexible(
                                      child: Text(
                                          getFormattedAmount(totalSpent, ref),
                                          style: TextStyle(
                                              fontSize: responsive.isTablet
                                                  ? responsive.setSp(12.5)
                                                  : responsive.setSp(11.5),
                                              color:
                                                  AppColors.textColorDarkTheme),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis)),
                                ])),
                            Flexible(
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                  Icon(Icons.arrow_upward,
                                      color: AppColors.accentColor,
                                      size: responsive.isTablet
                                          ? responsive.setWidth(15)
                                          : responsive.setWidth(13.5)),
                                  SizedBox(width: responsive.setWidth(2)),
                                  Flexible(
                                      child: Text(
                                          getFormattedAmount(totalIncome, ref),
                                          style: TextStyle(
                                              fontSize: responsive.isTablet
                                                  ? responsive.setSp(12.5)
                                                  : responsive.setSp(11.5),
                                              color:
                                                  AppColors.textColorDarkTheme),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis)),
                                ])),
                          ],
                        ),
                      ),
                      ProgressRow(
                        progress: totalSpent > totalIncome
                            ? 1.0
                            : (totalIncome > 0
                                ? totalSpent / totalIncome
                                : 0.0),
                        label: 'Savings Card',
                        amount:
                            '${currency.symbol} ${getFormattedAmount(totalSpent, ref)}', // Use the passed symbol
                        progressColor: AppColors.accentColor2,
                      ),
                    ],
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Lottie.asset(
                        'assets/${imageNames[randomIndex]}.json',
                        width: responsive.setWidth(91.5),
                        height: responsive.setHeight(91.5),
                        fit: BoxFit.contain)),
              ],
            ),
          ),
        );
      },
    );
  }
}
