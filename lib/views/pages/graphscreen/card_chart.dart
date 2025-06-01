import 'package:budgify/views/pages/graphscreen/charts/line_chart.dart';
import 'package:budgify/views/pages/graphscreen/charts/pie_chart.dart';
import 'package:budgify/views/pages/graphscreen/charts/pie_chart_merge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'charts/bar_chart.dart';

class ChartCard extends ConsumerWidget {
  final int month; // Add a month parameter
  final int year;
  final int day;
  final bool isYear;
  final bool isMonth;
  final bool isDay;
  final int isIncome;
  final int chartType;
  const ChartCard({
    super.key,
    required this.month,
    required this.year,
    required this.day,
    required this.isYear,
    required this.isMonth,
    required this.isDay,
    required this.isIncome,
    required this.chartType,
  }); // Update constructor

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current month name
    // String monthName = _getMonthName(month); // Use the passed month

    double cardWidth = MediaQuery.of(context).size.width * 0.89;
    double cardHeight = MediaQuery.of(context).size.height * 0.24;
    print("chartz ==== ${chartType}");
    print("chartzxxx ==== ${isIncome}");
    
    return Center(
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          height: cardHeight,
          width: cardWidth,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              isIncome == 2
                  ? Expanded(
                    child:
                        chartType == 0
                            ? IncomeExpensePieChart(
                              month: month,
                              year: year,
                              day: day,
                              isYear: isYear,
                              isMonth: isMonth,
                              isDay: isDay,
                            )
                            : Container(),
                  )
                  : Expanded(
                    child:
                        chartType == 0
                            ? SimplePieChart(
                              month: month,
                              year: year,
                              day: day,
                              isYear: isYear,
                              isMonth: isMonth,
                              isDay: isDay,
                              isIncome: isIncome == 0 ? false : true,
                            )
                            : chartType == 1
                            ? SimpleBarChart(
                              month: month,
                              year: year,
                              day: day,
                              isYear: isYear,
                              isMonth: isMonth,
                              isDay: isDay,
                              isIncome: isIncome == 0 ? false : true,
                            )
                            : chartType == 2
                            ? LineChartPage(
                              month: month,
                              year: year,
                              day: day,
                              isYear: isYear,
                              isMonth: isMonth,
                              isDay: isDay,
                              isIncome: isIncome == 0 ? false : true,
                            )
                            : Container(),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  // String _getMonthName(int month) {
  //   const List<String> monthNames = [
  //     'January', 'February', 'March', 'April',
  //     'May', 'June', 'July', 'August',
  //     'September', 'October', 'November', 'December'
  //   ];
  //   return monthNames[month - 1]; // Adjust for zero-based index
  // }
}
