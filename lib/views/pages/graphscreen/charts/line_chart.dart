import 'package:budgify/core/utils/no_data_widget.dart';
import 'package:budgify/core/utils/parrot_animation_waiting.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/expense.dart';
import '../../../../data/repo/expenses_repository.dart';
import 'package:budgify/core/utils/scale_config.dart'; // Import ScaleConfig

class LineChartPage extends ConsumerWidget {
  final int day;
  final int month;
  final int year;
  final bool isYear;
  final bool isMonth;
  final bool isDay;
  final bool isIncome;

  const LineChartPage({
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
    final scaleConfig = ScaleConfig(context); // Initialize ScaleConfig
    final repository = ExpensesRepository();
    
    return StreamBuilder<List<CashFlow>>(
      stream: repository.getExpensesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ParrotAnimation();
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return NoDataWidget();
        }

        final filteredExpenses = _filterExpenses(snapshot.data!);

        if (filteredExpenses.isEmpty) {
          return NoDataWidget();
        }

        final chartData = _prepareChartData(filteredExpenses);
        final categoryColors = _generateCategoryColors(filteredExpenses);

        return _buildLineChart(chartData, categoryColors, scaleConfig);
      },
    );
  }



  List<CashFlow> _filterExpenses(List<CashFlow> expenses) {
    final now = DateTime.now();
    return expenses.where((expense) {
      final expenseDate = expense.date;
      bool yearMatches = isYear ? expenseDate.year == year : true;
      if (!isYear && (isMonth || isDay)) {
        yearMatches = expenseDate.year == now.year;
      }
      bool monthMatches = isMonth ? expenseDate.month == month : true;
      bool dayMatches = isDay ? expenseDate.day == day : true;

      return yearMatches && monthMatches && dayMatches && expense.isIncome == isIncome;
    }).toList();
  }

  Map<String, List<FlSpot>> _prepareChartData(List<CashFlow> expenses) {
    final categoryMap = <String, Map<int, double>>{};
    final xAxisLabels = <int>{};

    for (var expense in expenses) {
      final expenseDate = expense.date;
      int xKey;

      if (isYear) {
        xKey = expenseDate.month;
      } else if (isMonth) {
        xKey = expenseDate.day;
      } else {
        xKey = expenseDate.year;
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
        ..sort((a, b) => a.x.compareTo(b.x)); // Ensure sorted by x-axis
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
    ScaleConfig scaleConfig,
  ) {
    final lineBarsData = chartData.entries.map((entry) {
      return LineChartBarData(
        spots: entry.value,
        isCurved: true,
        color: categoryColors[entry.key],
        barWidth: scaleConfig.scale(3), // Responsive line width
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: scaleConfig.scale(4), // Responsive dot size
              color: categoryColors[entry.key]!,
              strokeWidth: scaleConfig.scale(1.5),
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(show: false),
      );
    }).toList();

    // Calculate max Y value with some padding
    final maxY = chartData.values.fold(0.0, (max, spots) {
      final spotMax = spots.fold(0.0, (m, spot) => spot.y > m ? spot.y : m);
      return spotMax > max ? spotMax : max;
    }) * 1.1; // 10% padding

    return Padding(
      padding: EdgeInsets.all(scaleConfig.scale(8)), // Responsive padding
      child: LineChart(
        LineChartData(
          minX: chartData.values.first.first.x,
          maxX: chartData.values.first.last.x,
          minY: 0,
          maxY: maxY,
          lineBarsData: lineBarsData,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: maxY / 5,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: scaleConfig.scale(0.5),
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.1),
              strokeWidth: scaleConfig.scale(0.5),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: maxY / 5,
                reservedSize: scaleConfig.scale(40),
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: scaleConfig.scaleText(6),
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: scaleConfig.scale(30),
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: EdgeInsets.only(top: scaleConfig.scale(4)),
                    child: Text(
                      isYear 
                          ? _getMonthName(value.toInt())
                          : value.toInt().toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: scaleConfig.scaleText(6),
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
              // tooltipBgColor: Colors.black.withOpacity(0.8),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${chartData.keys.elementAt(spot.barIndex)}\n${spot.y.toStringAsFixed(2)}',
                    TextStyle(
                      color: Colors.white,
                      fontSize: scaleConfig.scaleText(8),
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
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}