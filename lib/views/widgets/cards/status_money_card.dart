import 'dart:math';
import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/data/repo/expenses_repository.dart';
import 'package:budgify/domain/models/expense.dart';
import 'package:budgify/viewmodels/providers/currency_symbol.dart';
import 'package:budgify/viewmodels/providers/lang_provider.dart';
import 'package:budgify/views/widgets/cards/progress_row.dart';
import 'package:budgify/core/utils/format_amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SavingsCard extends ConsumerWidget {
  const SavingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaleConfig = ScaleConfig(context);
    List<String> imageNames = [
      "pppigo",
      "save9",
      "money_s",
      "cash_fly",
      "digital_card",
      "bud_splash",
      "cash_money_wallet",
    ];
    String monthName = _getMonthName(DateTime.now().month);
    int randomIndex = Random().nextInt(imageNames.length);
    final currencyState = ref.watch(currencyProvider);
    final langauge = ref.watch(languageProvider).toString();

    return StreamBuilder<List<CashFlow>>(
      stream: ExpensesRepository().getExpensesStream(),
      builder: (context, snapshot) {
        // Responsive sizing - different for tablets vs phones
        double cardWidth =
            scaleConfig.isTablet
                ? scaleConfig.widthPercentage(0.92) // 80% for tablets
                : scaleConfig.widthPercentage(0.92); // 92% for phones
        double cardHeight =
            scaleConfig.isTablet
                ? scaleConfig.scale(180) // Slightly taller for tablets
                : scaleConfig.scale(162);
        double padding = scaleConfig.scale(12);
        double borderRadius = scaleConfig.scale(12);
        Color cardColor = Theme.of(context).cardTheme.color!;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Card(
              elevation: 4,
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Container(
                width: cardWidth,
                height: cardHeight,
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: Center(
                  child: SizedBox(
                    width: scaleConfig.scale(60),
                    height: scaleConfig.scale(60),
                  ),
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}'.tr,
              style: TextStyle(
                fontSize: scaleConfig.scaleText(16),
                color: Colors.red,
              ),
            ),
          );
        }

        var expenses = snapshot.data ?? [];
        double totalExpenses = 0.0;
        double totalIncome = 0.0;

        for (var expense in expenses) {
          if (expense.date.month == DateTime.now().month &&
              expense.date.year == DateTime.now().year) {
            if (expense.isIncome) {
              totalIncome += expense.amount;
            } else {
              totalExpenses += expense.amount;
            }
          }
        }

        var totalSpent = totalExpenses;
        var savings = totalIncome - totalExpenses;
        savings = savings > 999999 ? 999999 : savings;

        return Card(
          elevation: 4,
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Container(
            width: cardWidth,
            height: cardHeight,
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      langauge == 'ar'
                          ? Row(
                            children: [
                              Text(
                                'Savings'.tr,
                                style: TextStyle(
                                  fontSize: scaleConfig.scaleText(15.5),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorDarkTheme,
                                ),
                              ),
                              SizedBox(width: scaleConfig.scale(4)),
                              Text(
                                monthName.tr,
                                style: TextStyle(
                                  fontSize: scaleConfig.scaleText(15.5),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorDarkTheme,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          )
                          : Row(
                            children: [
                              Text(
                                monthName.tr,
                                style: TextStyle(
                                  fontSize: scaleConfig.scaleText(15.5),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorDarkTheme,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(width: scaleConfig.scale(4)),
                              Text(
                                'Savings'.tr,
                                style: TextStyle(
                                  fontSize: scaleConfig.scaleText(15.5),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorDarkTheme,
                                ),
                              ),
                            ],
                          ),
                      SizedBox(height: scaleConfig.scale(0)),

                      langauge == 'ar'
                          ? Text(
                            savings <= 0
                                ? '0'
                                : '${getFormattedAmount(savings, ref)} ${currencyState.currencySymbol} ',
                            style: TextStyle(
                              fontSize: scaleConfig.scaleText(18.5),
                              fontWeight: FontWeight.bold,
                              color:
                                  savings <= 0
                                      ? AppColors.accentColor2
                                      : AppColors.accentColor,
                            ),
                          )
                          : Text(
                            savings <= 0
                                ? '0'
                                : '${currencyState.currencySymbol} ${getFormattedAmount(savings, ref)}',
                            style: TextStyle(
                              fontSize: scaleConfig.scaleText(18.5),
                              fontWeight: FontWeight.bold,
                              color:
                                  savings <= 0
                                      ? AppColors.accentColor2
                                      : AppColors.accentColor,
                            ),
                          ),
                      SizedBox(height: scaleConfig.scale(0)),
                      SizedBox(
                        width:
                            scaleConfig.isTablet
                                ? scaleConfig.scale(200) // Wider on tablets
                                : scaleConfig.scale(
                                  164,
                                ), // Original width on phones
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_downward,
                                    color: AppColors.accentColor2,
                                    size:
                                        scaleConfig.isTablet
                                            ? scaleConfig.scale(
                                              15,
                                            ) // Slightly larger on tablets
                                            : scaleConfig.scale(13.5),
                                  ),
                                  SizedBox(
                                    width: scaleConfig.scale(2),
                                  ), // Increased spacing
                                  Flexible(
                                    child: Text(
                                      getFormattedAmount(totalSpent, ref),
                                      style: TextStyle(
                                        fontSize:
                                            scaleConfig.isTablet
                                                ? scaleConfig.scaleText(
                                                  12.5,
                                                ) // Slightly larger text
                                                : scaleConfig.scaleText(11.5),
                                        color: AppColors.textColorDarkTheme,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_upward,
                                    color: AppColors.accentColor,
                                    size:
                                        scaleConfig.isTablet
                                            ? scaleConfig.scale(
                                              15,
                                            ) // Slightly larger on tablets
                                            : scaleConfig.scale(13.5),
                                  ),
                                  SizedBox(
                                    width: scaleConfig.scale(2),
                                  ), // Increased spacing
                                  Flexible(
                                    child: Text(
                                      getFormattedAmount(totalIncome, ref),
                                      style: TextStyle(
                                        fontSize:
                                            scaleConfig.isTablet
                                                ? scaleConfig.scaleText(
                                                  12.5,
                                                ) // Slightly larger text
                                                : scaleConfig.scaleText(11.5),
                                        color: AppColors.textColorDarkTheme,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ProgressRow(
                        progress:
                            totalSpent > totalIncome
                                ? 1.0
                                : totalSpent / totalIncome,
                        label: 'Savings Card',
                        amount:
                            '${currencyState.currencySymbol} ${getFormattedAmount(totalSpent, ref)}',
                        progressColor: AppColors.accentColor2,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: scaleConfig.isTablet ? 1 : 1,
                  child: Lottie.asset(
                    'assets/${imageNames[randomIndex]}.json',
                    width: scaleConfig.scale(91.5),
                    height: scaleConfig.scale(91.5),
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
    const List<String> monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return monthNames[month - 1];
  }
}
