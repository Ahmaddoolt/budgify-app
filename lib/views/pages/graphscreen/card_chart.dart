// lib/views/pages/graphscreen/card_chart.dart

import 'package:budgify/views/pages/graphscreen/charts/bar_chart.dart';
import 'package:budgify/views/pages/graphscreen/charts/line_chart.dart';
import 'package:budgify/views/pages/graphscreen/charts/pie_chart.dart';
import 'package:budgify/views/pages/graphscreen/charts/pie_chart_merge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChartCard extends ConsumerWidget {
  // --- THE FIX: Receive both code for logic and symbol for display ---
  final String currencyCode;
  final String currencySymbol;
  final int month;
  final int year;
  final int day;
  final bool isYear;
  final bool isMonth;
  final bool isDay;
  final int isIncome;
  final int chartType;

  const ChartCard({
    super.key,
    required this.currencyCode,
    required this.currencySymbol,
    required this.month,
    required this.year,
    required this.day,
    required this.isYear,
    required this.isMonth,
    required this.isDay,
    required this.isIncome,
    required this.chartType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double cardWidth = MediaQuery.of(context).size.width * 0.89;
    double cardHeight = MediaQuery.of(context).size.height * 0.24;

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
                      child: chartType == 0
                          ? IncomeExpensePieChart(
                              // --- THE FIX: Pass code and symbol down ---
                              currencyCode: currencyCode,
                              currencySymbol: currencySymbol,
                              month: month,
                              year: year,
                              day: day,
                              isYear: isYear,
                              isMonth: isMonth,
                              isDay: isDay,
                            )
                          : Container(), // Other chart types for merged view can be added here
                    )
                  : Expanded(
                      child: chartType == 0
                          ? SimplePieChart(
                              // --- THE FIX: Pass code and symbol down ---
                              currencyCode: currencyCode,
                              currencySymbol: currencySymbol,
                              month: month,
                              year: year,
                              day: day,
                              isYear: isYear,
                              isMonth: isMonth,
                              isDay: isDay,
                              isIncome: isIncome != 0,
                            )
                          : chartType == 1
                              ? SimpleBarChart(
                                  // --- THE FIX: Pass code and symbol down ---
                                  currencyCode: currencyCode,
                                  currencySymbol: currencySymbol,
                                  month: month,
                                  year: year,
                                  day: day,
                                  isYear: isYear,
                                  isMonth: isMonth,
                                  isDay: isDay,
                                  isIncome: isIncome != 0,
                                )
                              : chartType == 2
                                  ? LineChartPage(
                                      // --- THE FIX: Pass code and symbol down ---
                                      currencyCode: currencyCode,
                                      currencySymbol: currencySymbol,
                                      month: month,
                                      year: year,
                                      day: day,
                                      isYear: isYear,
                                      isMonth: isMonth,
                                      isDay: isDay,
                                      isIncome: isIncome != 0,
                                    )
                                  : Container(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
