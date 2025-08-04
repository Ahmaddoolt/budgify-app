// lib/views/pages/graphscreen/charts/pie_chart_merge.dart

import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/data/repo/expenses_repository.dart';
import 'package:budgify/domain/models/expense.dart';
import 'package:budgify/viewmodels/providers/lang_provider.dart';
import 'package:budgify/core/utils/format_amount.dart';
import 'package:budgify/core/utils/no_data_widget.dart';
import 'package:budgify/core/utils/parrot_animation_waiting.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class IncomeExpensePieChart extends ConsumerWidget {
  // --- THE FIX: Receive both code and symbol ---
  final String currencyCode;
  final String currencySymbol;
  final int day;
  final int month;
  final int year;
  final bool isYear;
  final bool isMonth;
  final bool isDay;

  const IncomeExpensePieChart({
    super.key,
    required this.currencyCode,
    required this.currencySymbol,
    required this.day,
    required this.month,
    required this.year,
    required this.isYear,
    required this.isMonth,
    required this.isDay,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = context.responsive;
    final repository = ExpensesRepository();
    final isArabic = ref.watch(languageProvider).toString() == 'ar';

    return StreamBuilder<List<CashFlow>>(
      stream: repository.getExpensesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ParrotAnimation();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'.tr));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const NoDataWidget();
        }

        final now = DateTime.now();

        // --- THE FIX: Filter by currencyCode ---
        final filteredExpenses = snapshot.data!.where((expense) {
          if (expense.currencyCode != currencyCode) return false;

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
          return const NoDataWidget();
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
        final double totalSumForPercentage = totalExpenses + totalIncomes;

        List<PieChartSectionData> sections = [
          if (totalExpenses > 0)
            PieChartSectionData(
              showTitle: false,
              value: totalExpenses,
              color: AppColors.accentColor2,
              radius: responsive.setWidth(30),
            ),
          if (totalIncomes > 0)
            PieChartSectionData(
              showTitle: false,
              value: totalIncomes,
              color: AppColors.accentColor,
              radius: responsive.setWidth(30),
            ),
        ];

        final double fontSize = responsive.setSp(9);

        return Padding(
          padding: EdgeInsets.only(right: responsive.setWidth(5)),
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
                        sectionsSpace: responsive.setWidth(2),
                        centerSpaceRadius: responsive.setWidth(30),
                        centerSpaceColor: Colors.transparent,
                      ),
                    ),
                    isArabic
                        ? Text(
                            totalSumForPercentage > 0
                                ? '${getFormattedAmount(totalAmount, ref)}$currencySymbol'
                                : '0 $currencySymbol',
                            style: TextStyle(
                                fontSize: responsive.setSp(9),
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColorDarkTheme),
                          )
                        : Text(
                            totalSumForPercentage > 0
                                ? '$currencySymbol${getFormattedAmount(totalAmount, ref)}'
                                : '$currencySymbol 0',
                            style: TextStyle(
                                fontSize: responsive.setSp(9),
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColorDarkTheme),
                          ),
                  ],
                ),
              ),
              SizedBox(width: responsive.setWidth(20)),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: responsive.setHeight(4)),
                        child: Row(
                          children: [
                            Container(
                                width: responsive.setWidth(12),
                                height: responsive.setHeight(12),
                                color: AppColors.accentColor2),
                            SizedBox(width: responsive.setWidth(7)),
                            Expanded(
                                child: Text('Expenses'.tr,
                                    style: TextStyle(
                                        fontSize: fontSize,
                                        color: AppColors.textColorDarkTheme),
                                    overflow: TextOverflow.ellipsis)),
                            Text(
                                totalSumForPercentage > 0
                                    ? '${((totalExpenses / totalSumForPercentage) * 100).toStringAsFixed(0)}%'
                                    : '0%',
                                style: TextStyle(
                                    fontSize: fontSize,
                                    color: AppColors.textColorDarkTheme)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: responsive.setHeight(4)),
                        child: Row(
                          children: [
                            Container(
                                width: responsive.setWidth(12),
                                height: responsive.setHeight(12),
                                color: AppColors.accentColor),
                            SizedBox(width: responsive.setWidth(7)),
                            Expanded(
                                child: Text('Incomes'.tr,
                                    style: TextStyle(
                                        fontSize: fontSize,
                                        color: AppColors.textColorDarkTheme),
                                    overflow: TextOverflow.ellipsis)),
                            Text(
                                totalSumForPercentage > 0
                                    ? '${((totalIncomes / totalSumForPercentage) * 100).toStringAsFixed(0)}%'
                                    : '0%',
                                style: TextStyle(
                                    fontSize: fontSize,
                                    color: AppColors.textColorDarkTheme)),
                          ],
                        ),
                      ),
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
