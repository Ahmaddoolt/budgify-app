// lib/views/pages/graphscreen/charts/line_chart.dart

import 'package:budgify/core/utils/no_data_widget.dart';
import 'package:budgify/core/utils/parrot_animation_waiting.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../../../core/utils/format_amount.dart';
import '../../../../domain/models/expense.dart';
import '../../../../data/repo/expenses_repository.dart';

class LineChartPage extends ConsumerWidget {
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

  const LineChartPage({
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

        final filteredExpenses = _filterExpenses(snapshot.data!);

        if (filteredExpenses.isEmpty) {
          return const NoDataWidget();
        }

        final chartData = _prepareChartData(filteredExpenses);

        if (chartData.isEmpty) {
          return const NoDataWidget();
        }

        final categoryColors = _generateCategoryColors(filteredExpenses);

        return _buildLineChart(chartData, categoryColors, responsive, ref);
      },
    );
  }

  List<CashFlow> _filterExpenses(List<CashFlow> expenses) {
    final now = DateTime.now();

    // --- THE FIX: Filter by currencyCode ---
    return expenses.where((expense) {
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
  }

  Map<String, List<FlSpot>> _prepareChartData(List<CashFlow> expenses) {
    final categoryMap = <String, Map<int, double>>{};
    final xAxisLabels = <int>{};

    for (var expense in expenses) {
      final expenseDate = expense.date;
      int xKey;

      if (isYear && isMonth) {
        xKey = expenseDate.day;
      } else if (isYear && !isMonth) {
        xKey = expenseDate.month;
      } else {
        xKey = expenseDate.day;
      }

      xAxisLabels.add(xKey);

      categoryMap.putIfAbsent(expense.category.name, () => {});
      categoryMap[expense.category.name]![xKey] =
          (categoryMap[expense.category.name]![xKey] ?? 0.0) + expense.amount;
    }

    return categoryMap.map((category, data) {
      final spots = xAxisLabels.map((xKey) {
        return FlSpot(xKey.toDouble(), data[xKey] ?? 0.0);
      }).toList()
        ..sort((a, b) => a.x.compareTo(b.x));
      return MapEntry(category, spots);
    });
  }

  Map<String, Color> _generateCategoryColors(List<CashFlow> expenses) {
    final colors = <String, Color>{};
    for (var expense in expenses) {
      colors[expense.category.name] = expense.category.color;
    }
    return colors;
  }

  Widget _buildLineChart(
    Map<String, List<FlSpot>> chartData,
    Map<String, Color> categoryColors,
    ResponsiveUtil responsive,
    WidgetRef ref,
  ) {
    final lineBarsData = chartData.entries.map((entry) {
      return LineChartBarData(
        spots: entry.value,
        isCurved: true,
        color: categoryColors[entry.key],
        barWidth: responsive.setWidth(3),
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: responsive.setWidth(4),
              color: categoryColors[entry.key]!,
              strokeWidth: responsive.setWidth(1.5),
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(show: false),
      );
    }).toList();

    final maxY = chartData.values.fold(0.0, (max, spots) {
          final spotMax = spots.fold(0.0, (m, spot) => spot.y > m ? spot.y : m);
          return spotMax > max ? spotMax : max;
        }) *
        1.1;

    final minX =
        chartData.values.isNotEmpty && chartData.values.first.isNotEmpty
            ? chartData.values.first.first.x
            : 0.0;
    final maxX =
        chartData.values.isNotEmpty && chartData.values.first.isNotEmpty
            ? chartData.values.first.last.x
            : 1.0;

    return Padding(
      padding: EdgeInsets.all(responsive.setWidth(8)),
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: 0,
          maxY: maxY > 0 ? maxY : 10,
          lineBarsData: lineBarsData,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: (maxY > 0 ? maxY : 10) / 5,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: responsive.setWidth(0.5),
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.1),
              strokeWidth: responsive.setWidth(0.5),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (maxY > 0 ? maxY : 10) / 5,
                reservedSize: responsive.setWidth(40),
                getTitlesWidget: (value, meta) {
                  return Text(
                    // The currencySymbol is used here for display
                    '$currencySymbol ${getFormattedAmount(value, ref)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsive.setSp(6),
                    ),
                  );
                },
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
                reservedSize: responsive.setHeight(30),
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: EdgeInsets.only(top: responsive.setHeight(4)),
                    child: Text(
                      (isYear && !isMonth)
                          ? _getMonthName(value.toInt()).tr
                          : value.toInt().toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive.setSp(6),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  final categoryName = chartData.keys.elementAt(spot.barIndex);
                  return LineTooltipItem(
                    '${categoryName.tr}\n$currencySymbol ${spot.y.toStringAsFixed(2)}',
                    TextStyle(
                      color: Colors.white,
                      fontSize: responsive.setSp(8),
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '',
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
      'Dec'
    ];
    return months.length > month ? months[month] : '';
  }
}
