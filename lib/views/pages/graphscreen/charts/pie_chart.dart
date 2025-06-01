import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/data/repo/expenses_repository.dart';
import 'package:budgify/domain/models/expense.dart';
import 'package:budgify/viewmodels/providers/currency_symbol.dart';
import 'package:budgify/viewmodels/providers/lang_provider.dart';
import 'package:budgify/core/utils/format_amount.dart';
import 'package:budgify/core/utils/no_data_widget.dart';
import 'package:budgify/core/utils/parrot_animation_waiting.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class SimplePieChart extends ConsumerWidget {
  final int day;
  final int month;
  final int year;
  final bool isYear;
  final bool isMonth;
  final bool isDay;
  final bool isIncome;

  const SimplePieChart({
    super.key,
    required this.day,
    required this.month,
    required this.year,
    required this.isYear,
    required this.isMonth,
    required this.isDay,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaleConfig = ScaleConfig(context);
    final repository = ExpensesRepository();
    final currencyState = ref.watch(currencyProvider);
    final isArabic =
        ref.watch(languageProvider).toString() == 'ar' ? true : false;

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
        final filteredExpenses =
            snapshot.data!.where((expense) {
              final expenseDate = expense.date;
              bool yearMatches = isYear ? expenseDate.year == year : true;
              if (!isYear && (isMonth || isDay)) {
                yearMatches = expenseDate.year == now.year;
              }
              bool monthMatches = isMonth ? expenseDate.month == month : true;
              bool dayMatches = isDay ? expenseDate.day == day : true;

              return yearMatches &&
                  monthMatches &&
                  dayMatches &&
                  expense.isIncome == isIncome;
            }).toList();

        if (filteredExpenses.isEmpty) {
          return NoDataWidget();
        }

        final Map<String, double> categoryTotals = {};
        final Map<String, CashFlow> categoryDetails = {};

        for (var expense in filteredExpenses) {
          final categoryName = expense.category.name;
          categoryTotals[categoryName] =
              (categoryTotals[categoryName] ?? 0) + expense.amount;
          categoryDetails[categoryName] = expense;
        }

        final double totalAmount = categoryTotals.values.fold(
          0,
          (sum, amount) => sum + amount,
        );
        final sortedCategories =
            categoryTotals.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

        List<PieChartSectionData> sections = [];
        double maxAmount =
            sortedCategories.isNotEmpty ? sortedCategories.first.value : 0;

        for (var i = 0; i < sortedCategories.length && i < 10; i++) {
          final entry = sortedCategories[i];
          final isLargest = entry.value == maxAmount;
          final categoryExpense = categoryDetails[entry.key]!;
          final double percentage =
              totalAmount > 0 ? (entry.value / totalAmount) * 100 : 0.0;
          sections.add(
            PieChartSectionData(
              showTitle: false,
              value: percentage,
              color: categoryExpense.category.color,
              radius: isLargest ? scaleConfig.scale(30) : scaleConfig.scale(25),
            ),
          );
        }

        final double fontSize = scaleConfig.scaleText(9);

        List<Widget> categoryLegend =
            sortedCategories.map((entry) {
              final categoryExpense = categoryDetails[entry.key]!;
              final double percentage =
                  totalAmount > 0 ? (entry.value / totalAmount) * 100 : 0.0;
              return Padding(
                padding: EdgeInsets.symmetric(vertical: scaleConfig.scale(4)),
                child: Row(
                  children: [
                    Container(
                      width: scaleConfig.scale(12),
                      height: scaleConfig.scale(12),
                      color: categoryExpense.category.color,
                    ),
                    SizedBox(width: scaleConfig.scale(7)),
                    Expanded(
                      child: Text(
                        entry.key.tr,
                        style: TextStyle(
                          fontSize: fontSize,
                          color: AppColors.textColorDarkTheme,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: fontSize,
                        color: AppColors.textColorDarkTheme,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();

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
                    !isArabic
                        ? Text(
                          totalAmount > 0
                              ? "${currencyState.currencySymbol}${getFormattedAmount(totalAmount, ref)}"
                              : '0',
                          style: TextStyle(
                            fontSize: scaleConfig.scaleText(8),
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorDarkTheme,
                          ),
                        )
                        : Text(
                          totalAmount > 0
                              ? "${getFormattedAmount(totalAmount, ref)}${currencyState.currencySymbol}"
                              : '0',
                          style: TextStyle(
                            fontSize: scaleConfig.scaleText(8),
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
                      ...categoryLegend,
                      Padding(
                        padding: EdgeInsets.only(top: scaleConfig.scale(8)),
                        child: Text(
                          'Scroll for more'.tr,
                          style: TextStyle(
                            fontSize: scaleConfig.scaleText(9),
                            color: Colors.grey,
                          ),
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
