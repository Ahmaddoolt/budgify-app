// lib/views/pages/graphscreen/charts/bar_chart.dart

import 'package:budgify/core/utils/no_data_widget.dart';
import 'package:budgify/core/utils/parrot_animation_waiting.dart';
import 'package:budgify/core/utils/format_amount.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../../../domain/models/expense.dart';
import '../../../../data/repo/expenses_repository.dart';
import 'package:budgify/core/themes/app_colors.dart';

class SimpleBarChart extends ConsumerWidget {
  // --- THE FIX: Receive both code and symbol ---
  final String currencyCode;
  final String currencySymbol;
  final int day;
  final int month;
  final int year;
  final bool isYear;
  final bool isMonth;
  final bool isDay;
  final bool isIncome;

  const SimpleBarChart({
    super.key,
    required this.currencyCode,
    required this.currencySymbol,
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
    final responsive = context.responsive;
    final repository = ExpensesRepository();

    return StreamBuilder<List<CashFlow>>(
      stream: repository.getExpensesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ParrotAnimation();
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

          return yearMatches &&
              monthMatches &&
              dayMatches &&
              expense.isIncome == isIncome;
        }).toList();

        if (filteredExpenses.isEmpty) {
          return const NoDataWidget();
        }

        final Map<String, double> categoryTotals = {};
        final Map<String, CashFlow> categoryDetails = {};

        for (var expense in filteredExpenses) {
          final categoryName = expense.category.name;
          categoryTotals[categoryName] =
              (categoryTotals[categoryName] ?? 0) + expense.amount;
          categoryDetails[categoryName] = expense;
        }

        final double maxAmount = categoryTotals.values.isNotEmpty
            ? categoryTotals.values.reduce((a, b) => a > b ? a : b)
            : 0;

        List<BarChartGroupData> barGroups = categoryTotals.entries.map((entry) {
          final categoryExpense = categoryDetails[entry.key]!;
          return BarChartGroupData(
            x: categoryTotals.keys.toList().indexOf(entry.key),
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: categoryExpense.category.color,
                width: responsive.setWidth(8),
              ),
            ],
            showingTooltipIndicators: [],
          );
        }).toList();

        return Padding(
          padding: EdgeInsets.only(right: responsive.setWidth(5)),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxAmount > 0 ? maxAmount * 1.1 : 10,
              barGroups: barGroups,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: (maxAmount > 0 ? maxAmount * 1.1 : 10) / 5,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        // The currencySymbol is used here for display
                        '$currencySymbol ${getFormattedAmount(value, ref)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: responsive.setSp(8),
                        ),
                      );
                    },
                    reservedSize: responsive.setWidth(50),
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < categoryTotals.keys.length) {
                        final category = categoryTotals.keys.elementAt(index);
                        return Padding(
                          padding: EdgeInsets.only(
                            top: responsive.setHeight(4),
                          ),
                          child: Text(
                            category.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: responsive.setSp(8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: responsive.setHeight(30),
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.3),
                  strokeWidth: responsive.setWidth(0.5),
                ),
                verticalInterval: 1,
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        );
      },
    );
  }
}
