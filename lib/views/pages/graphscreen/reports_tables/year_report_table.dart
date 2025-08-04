// lib/views/pages/graphscreen/reports_tables/year_report_table.dart

import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/no_data_widget.dart';
import 'package:budgify/core/utils/parrot_animation_waiting.dart';
import 'package:budgify/core/utils/format_amount.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../../../domain/models/expense.dart';
import '../../../../data/repo/expenses_repository.dart';
import 'month_report_table.dart';

class YearlyTablePage extends ConsumerWidget {
  final int year;
  // --- THE FIX: Add currency properties ---
  final String currencyCode;
  final String currencySymbol;

  const YearlyTablePage({
    super.key,
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
            fontSize: responsive.setSp(15),
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

          // --- THE FIX: Filter by currencyCode first ---
          final allTransactionsForYear = (snapshot.data ?? [])
              .where((expense) =>
                  expense.date.year == year &&
                  expense.currencyCode == currencyCode)
              .toList();

          if (allTransactionsForYear.isEmpty) {
            return const NoDataWidget();
          }

          final List<double> monthlyIncomes = List.filled(12, 0);
          final List<double> monthlyExpenses = List.filled(12, 0);

          for (var expense in allTransactionsForYear) {
            final month = expense.date.month - 1;
            if (expense.isIncome) {
              monthlyIncomes[month] += expense.amount;
            } else {
              monthlyExpenses[month] += expense.amount;
            }
          }

          int lastMonthWithData = -1;
          for (int i = 11; i >= 0; i--) {
            if (monthlyIncomes[i] > 0 || monthlyExpenses[i] > 0) {
              lastMonthWithData = i;
              break;
            }
          }

          if (lastMonthWithData == -1) {
            return const NoDataWidget();
          }

          final double totalIncomes = monthlyIncomes.fold(
            0,
            (sum, amount) => sum + amount,
          );
          final double totalExpenses = monthlyExpenses.fold(
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
                  Flexible(
                    child: Text(
                      'Yearly Summary - '.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: responsive.setSp(15),
                      ),
                    ),
                  ),
                  Text(
                    "$year",
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
              SizedBox(height: responsive.setHeight(20)),
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
                        columnSpacing: responsive.setWidth(40),
                        dataRowHeight: responsive.setHeight(40),
                        headingRowHeight: responsive.setHeight(60),
                        columns: [
                          DataColumn(
                              label: Text('Month'.tr,
                                  style: TextStyle(
                                      fontSize: responsive.setSp(9),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                          DataColumn(
                              label: Text('Incomes'.tr,
                                  style: TextStyle(
                                      fontSize: responsive.setSp(9),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                          DataColumn(
                              label: Text('Expenses'.tr,
                                  style: TextStyle(
                                      fontSize: responsive.setSp(9),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                          DataColumn(
                              label: Text('Savings'.tr,
                                  style: TextStyle(
                                      fontSize: responsive.setSp(9),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                        ],
                        rows: [
                          for (var month = 0;
                              month <= lastMonthWithData;
                              month++)
                            DataRow(
                              onSelectChanged: (_) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MonthlyTablePage(
                                      // --- THE FIX: Pass currency info down ---
                                      currencyCode: currencyCode,
                                      currencySymbol: currencySymbol,
                                      month: month + 1,
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
                                  Text(getShortMonthName(month + 1).tr,
                                      style: TextStyle(
                                          fontSize: responsive.setSp(11),
                                          color: Colors.white)),
                                ])),
                                DataCell(Text(
                                    getFormattedAmount(
                                        monthlyIncomes[month], ref),
                                    style: TextStyle(
                                        fontSize: responsive.setSp(9),
                                        color: Colors.white))),
                                DataCell(Text(
                                    getFormattedAmount(
                                        monthlyExpenses[month], ref),
                                    style: TextStyle(
                                        fontSize: responsive.setSp(9),
                                        color: Colors.white))),
                                DataCell(Text(
                                    _getSavingsValue(monthlyIncomes[month],
                                        monthlyExpenses[month], ref),
                                    style: TextStyle(
                                        fontSize: responsive.setSp(9),
                                        color: (monthlyIncomes[month] -
                                                    monthlyExpenses[month]) >=
                                                0
                                            ? Colors.green
                                            : Colors.red))),
                              ],
                            ),
                          DataRow(
                            color: WidgetStateProperty.all(
                                Theme.of(context).colorScheme.primary),
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
                                        fontSize: responsive.setSp(8),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green)),
                              ),
                              DataCell(
                                Text(
                                    '$currencySymbol ${getFormattedAmount(totalExpenses, ref)}',
                                    style: TextStyle(
                                        fontSize: responsive.setSp(8),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red)),
                              ),
                              DataCell(
                                Text(
                                    '$currencySymbol ${_getSavingsValue(totalIncomes, totalExpenses, ref)}',
                                    style: TextStyle(
                                        fontSize: responsive.setSp(8),
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
