import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/data/repo/expenses_repository.dart';
import 'package:budgify/domain/models/expense.dart';
import 'package:budgify/viewmodels/providers/currency_symbol.dart';
import 'package:budgify/core/utils/format_amount.dart';
import 'package:budgify/core/utils/no_data_widget.dart';
import 'package:budgify/core/utils/parrot_animation_waiting.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class IncomeExpensePieChart extends ConsumerWidget {
  final int day;
  final int month;
  final int year;
  final bool isYear;
  final bool isMonth;
  final bool isDay;

  const IncomeExpensePieChart({
    super.key,
    required this.day,
    required this.month,
    required this.year,
    required this.isYear,
    required this.isMonth,
    required this.isDay,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaleConfig = ScaleConfig(context);
    final repository = ExpensesRepository();
    final currencyState = ref.watch(currencyProvider);

    return StreamBuilder<List<CashFlow>>(
      stream: repository.getExpensesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ParrotAnimation();
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
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return NoDataWidget();
        }

        final now = DateTime.now();
        final filteredExpenses = snapshot.data!.where((expense) {
          final expenseDate = expense.date;
          bool yearMatches = isYear ? expenseDate.year == year : true;
          if (!isYear && (isMonth || isDay)) {
            yearMatches = expenseDate.year == now.year;
          }
          bool monthMatches = isMonth ? expenseDate.month == month : true;
          bool dayMatches = isDay ? expenseDate.day == day : true;

          return yearMatches && monthMatches && dayMatches;
        }).toList();

        if (filteredExpenses.isEmpty) {
          return NoDataWidget();
        }

        double totalExpenses = 0.0;
        double totalIncomes = 0.0;

        for (var expense in filteredExpenses) {
          if (expense.isIncome) {
            totalIncomes += expense.amount;
          } else {
            totalExpenses += expense.amount;
          }
        }

        final double totalAmount = totalIncomes - totalExpenses;
        final double totalAmount2 = totalExpenses + totalIncomes;

        List<PieChartSectionData> sections = [
          PieChartSectionData(
            showTitle: false,
            value: totalExpenses,
            color: AppColors.accentColor2,
            radius: scaleConfig.scale(30),
          ),
          PieChartSectionData(
            showTitle: false,
            value: totalIncomes,
            color: AppColors.accentColor,
            radius: scaleConfig.scale(30),
          ),
        ];

        final double fontSize = scaleConfig.scaleText(9);

        return Padding(
          padding: EdgeInsets.only(right: scaleConfig.scale(5)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sections: sections,
                        sectionsSpace: scaleConfig.scale(2),
                        centerSpaceRadius: scaleConfig.scale(30),
                        centerSpaceColor: Colors.transparent,
                      ),
                    ),
                    Text(
                      totalAmount2 > 0
                          ? '${currencyState.currencySymbol}${getFormattedAmount(totalAmount, ref)}'
                          : '0',
                      style: TextStyle(
                        fontSize: scaleConfig.scaleText(9),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorDarkTheme,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: scaleConfig.scale(20)),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: scaleConfig.scale(4)),
                        child: Row(
                          children: [
                            Container(
                              width: scaleConfig.scale(12),
                              height: scaleConfig.scale(12),
                              color: AppColors.accentColor2,
                            ),
                            SizedBox(width: scaleConfig.scale(7)),
                            Expanded(
                              child: Text(
                                'Expenses'.tr,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  color: AppColors.textColorDarkTheme,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              totalAmount2 > 0
                                  ? '${((totalExpenses / totalAmount2) * 100).toStringAsFixed(0)}%'
                                  : '0%',
                              style: TextStyle(
                                fontSize: fontSize,
                                color: AppColors.textColorDarkTheme,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: scaleConfig.scale(4)),
                        child: Row(
                          children: [
                            Container(
                              width: scaleConfig.scale(12),
                              height: scaleConfig.scale(12),
                              color: AppColors.accentColor,
                            ),
                            SizedBox(width: scaleConfig.scale(7)),
                            Expanded(
                              child: Text(
                                'Incomes'.tr,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  color: AppColors.textColorDarkTheme,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              totalAmount2 > 0
                                  ? '${((totalIncomes / totalAmount2) * 100).toStringAsFixed(0)}%'
                                  : '0%',
                              style: TextStyle(
                                fontSize: fontSize,
                                color: AppColors.textColorDarkTheme,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Padding(
                      //   padding: EdgeInsets.only(top: scaleConfig.scale(8)),
                      //   child: Text(
                      //     'Scroll for more'.tr,
                      //     style: TextStyle(
                      //       fontSize: scaleConfig.scaleText(12),
                      //       color: Colors.grey,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}