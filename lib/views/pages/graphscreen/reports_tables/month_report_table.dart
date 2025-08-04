// lib/views/pages/graphscreen/reports_tables/month_report_table.dart

import 'package:budgify/core/utils/no_data_widget.dart';
import 'package:budgify/core/utils/parrot_animation_waiting.dart';
import 'package:budgify/core/utils/format_amount.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../domain/models/expense.dart';
import '../../../../data/repo/expenses_repository.dart';
import 'day_report_table.dart';

class MonthlyTablePage extends ConsumerWidget {
  final int month;
  final int year;
  // --- THE FIX: Add currency properties ---
  final String currencyCode;
  final String currencySymbol;

  const MonthlyTablePage({
    super.key,
    required this.month,
    required this.year,
    required this.currencyCode,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = context.responsive;
    final repository = ExpensesRepository();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detailed Report Table'.tr,
          style: TextStyle(
            fontSize: responsive.setSp(16),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: StreamBuilder<List<CashFlow>>(
        stream: repository.getExpensesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ParrotAnimation();
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(
                  fontSize: responsive.setSp(16),
                  color: AppColors.textColorDarkTheme,
                ),
              ),
            );
          }

          final allTransactions = snapshot.data ?? [];

          // --- THE FIX: Add currencyCode to the filter ---
          final monthlyTransactions = allTransactions.where((expense) {
            if (expense.currencyCode != currencyCode) return false;
            return expense.date.year == year && expense.date.month == month;
          }).toList();

          if (monthlyTransactions.isEmpty) {
            return const NoDataWidget();
          }

          final int daysInMonth = DateTime(year, month + 1, 0).day;
          final List<double> dailyIncomes = List.filled(daysInMonth, 0);
          final List<double> dailyExpenses = List.filled(daysInMonth, 0);

          for (var expense in monthlyTransactions) {
            final day = expense.date.day - 1;
            if (expense.isIncome) {
              dailyIncomes[day] += expense.amount;
            } else {
              dailyExpenses[day] += expense.amount;
            }
          }

          int lastDayWithData = -1;
          for (int i = daysInMonth - 1; i >= 0; i--) {
            if (dailyIncomes[i] > 0 || dailyExpenses[i] > 0) {
              lastDayWithData = i;
              break;
            }
          }

          if (lastDayWithData == -1) {
            return const NoDataWidget();
          }

          final double totalIncomes = dailyIncomes.fold(
            0,
            (sum, amount) => sum + amount,
          );
          final double totalExpenses = dailyExpenses.fold(
            0,
            (sum, amount) => sum + amount,
          );
          final double totalSavings = totalIncomes - totalExpenses;

          return Column(
            children: [
              SizedBox(height: responsive.setHeight(20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Monthly Summary - '.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: responsive.setSp(15),
                    ),
                  ),
                  Text(
                    getShortMonthName(month).tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: responsive.setSp(15),
                    ),
                  ),
                  // --- THE FIX: Display the currency code in the title ---
                  Text(
                    " ($currencyCode)",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: responsive.setSp(14),
                    ),
                  )
                ],
              ),
              SizedBox(height: responsive.setHeight(15)),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(responsive.setWidth(8.0)),
                      constraints: BoxConstraints(
                        maxWidth: responsive.widthPercent(0.98),
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).appBarTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(
                          responsive.setWidth(10),
                        ),
                      ),
                      child: DataTable(
                        showCheckboxColumn: false,
                        columnSpacing: responsive.setWidth(35),
                        dataRowHeight: responsive.setHeight(40),
                        headingRowHeight: responsive.setHeight(60),
                        decoration: BoxDecoration(
                          color: Theme.of(context).appBarTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(
                            responsive.setWidth(10),
                          ),
                        ),
                        columns: [
                          DataColumn(
                              label: Text('Day'.tr,
                                  style: TextStyle(
                                      fontSize: responsive.setSp(10),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                          DataColumn(
                              label: Text('Incomes'.tr,
                                  style: TextStyle(
                                      fontSize: responsive.setSp(10),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                          DataColumn(
                              label: Text('Expenses'.tr,
                                  style: TextStyle(
                                      fontSize: responsive.setSp(10),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                          DataColumn(
                              label: Text('Savings'.tr,
                                  style: TextStyle(
                                      fontSize: responsive.setSp(10),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                        ],
                        rows: [
                          for (var day = 0; day <= lastDayWithData; day++)
                            DataRow(
                              onSelectChanged: (_) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DayReportPage(
                                      // --- THE FIX: Pass currency info down ---
                                      currencyCode: currencyCode,
                                      currencySymbol: currencySymbol,
                                      day: day + 1,
                                      month: month,
                                      year: year,
                                    ),
                                  ),
                                );
                              },
                              cells: [
                                DataCell(Row(children: [
                                  Icon(Icons.arrow_forward,
                                      color: AppColors.accentColor,
                                      size: responsive.setWidth(10)),
                                  SizedBox(width: responsive.setWidth(6)),
                                  Text('${day + 1}',
                                      style: TextStyle(
                                          fontSize: responsive.setSp(11),
                                          color: Colors.white)),
                                ])),
                                DataCell(Text(
                                    getFormattedAmount(dailyIncomes[day], ref),
                                    style: TextStyle(
                                        fontSize: responsive.setSp(9),
                                        color: Colors.white))),
                                DataCell(Text(
                                    getFormattedAmount(dailyExpenses[day], ref),
                                    style: TextStyle(
                                        fontSize: responsive.setSp(9),
                                        color: Colors.white))),
                                DataCell(Text(
                                    _getSavingsValue(dailyIncomes[day],
                                        dailyExpenses[day], ref),
                                    style: TextStyle(
                                        fontSize: responsive.setSp(9),
                                        color: (dailyIncomes[day] -
                                                    dailyExpenses[day]) >=
                                                0
                                            ? Colors.green
                                            : Colors.red))),
                              ],
                            ),
                          DataRow(
                            color: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.primary,
                            ),
                            cells: [
                              DataCell(Text('Total'.tr,
                                  style: TextStyle(
                                      fontSize: responsive.setSp(9),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                              DataCell(
                                // --- THE FIX: Display symbol with totals ---
                                Text(
                                    '$currencySymbol ${getFormattedAmount(totalIncomes, ref)}',
                                    style: TextStyle(
                                        fontSize: responsive.setSp(9),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green)),
                              ),
                              DataCell(
                                Text(
                                    '$currencySymbol ${getFormattedAmount(totalExpenses, ref)}',
                                    style: TextStyle(
                                        fontSize: responsive.setSp(9),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red)),
                              ),
                              DataCell(
                                Text(
                                    '$currencySymbol ${_getSavingsValue(totalIncomes, totalExpenses, ref)}',
                                    style: TextStyle(
                                        fontSize: responsive.setSp(9),
                                        fontWeight: FontWeight.bold,
                                        color: totalSavings >= 0
                                            ? Colors.green
                                            : Colors.red)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getSavingsValue(double income, double expense, WidgetRef ref) {
    final savings = income - expense;
    return getFormattedAmount(savings, ref);
  }

  String getShortMonthName(int monthNumber) {
    const List<String> monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    if (monthNumber < 1 || monthNumber > 12) {
      throw ArgumentError("Month number must be between 1 and 12");
    }
    return monthNames[monthNumber - 1];
  }
}
