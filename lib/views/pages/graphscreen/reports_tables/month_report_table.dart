import 'package:budgify/core/utils/no_data_widget.dart';
import 'package:budgify/core/utils/parrot_animation_waiting.dart';
import 'package:budgify/core/utils/format_amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/scale_config.dart'; // Import ScaleConfig
import '../../../../domain/models/expense.dart';
import '../../../../data/repo/expenses_repository.dart';
import 'day_report_table.dart'; // Import the DayReportPage

class MonthlyTablePage extends ConsumerWidget {
  final int month;
  final int year;

  const MonthlyTablePage({super.key, required this.month, required this.year});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaleConfig = ScaleConfig(context); // Initialize ScaleConfig
    final repository = ExpensesRepository();
    final now = DateTime.now();
    final currentDay = now.day; // Get the current day
    final isCurrentMonth =
        (month == now.month &&
            year == now.year); // Check if it's the current month

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detailed Report Table'.tr,
          style: TextStyle(
            fontSize: scaleConfig.scaleText(16), // Scaled font size
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
            return ParrotAnimation();
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(
                  fontSize: scaleConfig.scaleText(16), // Scaled font size
                  color: AppColors.textColorDarkTheme,
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return NoDataWidget();
          }

          final expenses = snapshot.data!;

          // Initialize daily totals
          final int daysInMonth = DateTime(year, month + 1, 0).day;
          final List<double> dailyIncomes = List.filled(daysInMonth, 0);
          final List<double> dailyExpenses = List.filled(daysInMonth, 0);

          for (var expense in expenses) {
            if (expense.date.year == year && expense.date.month == month) {
              final day = expense.date.day - 1; // Zero-based index
              if (expense.isIncome) {
                dailyIncomes[day] += expense.amount;
              } else {
                dailyExpenses[day] += expense.amount;
              }
            }
          }

          // Calculate monthly totals
          final double totalIncomes = dailyIncomes.fold(
            0,
            (sum, amount) => sum + amount,
          );
          final double totalExpenses = dailyExpenses.fold(
            0,
            (sum, amount) => sum + amount,
          );
          final double totalSavings =
              totalIncomes - totalExpenses < 0
                  ? 0
                  : totalIncomes - totalExpenses;

          return Column(
            children: [
              SizedBox(height: scaleConfig.scale(20)), // Scaled height

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Monthly Summary - '.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: scaleConfig.scaleText(15), // Scaled font size
                    ),
                  ),
                  Text(
                    getShortMonthName(month).tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: scaleConfig.scaleText(15), // Scaled font size
                    ),
                  ),
                ],
              ),
              SizedBox(height: scaleConfig.scale(15)), // Scaled height
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(
                        scaleConfig.scale(8.0),
                      ), // Scaled padding
                      constraints: BoxConstraints(
                        maxWidth:
                            MediaQuery.of(context).size.width *
                            0.95, // Responsive width
                      ),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(
                              context,
                            ).appBarTheme.backgroundColor, // Dark background
                        borderRadius: BorderRadius.circular(
                          scaleConfig.scale(10),
                        ), // Scaled radius
                      ),
                      child: DataTable(
                        showCheckboxColumn: false,
                        columnSpacing: scaleConfig.scale(20), // Scaled spacing
                        // ignore: deprecated_member_use
                        dataRowHeight: scaleConfig.scale(40), // Scaled height
                        headingRowHeight: scaleConfig.scale(
                          60,
                        ), // Scaled height
                        decoration: BoxDecoration(
                          color:
                              Theme.of(
                                context,
                              ).appBarTheme.backgroundColor, // Dark background
                          borderRadius: BorderRadius.circular(
                            scaleConfig.scale(10),
                          ), // Scaled radius
                        ),
                        columns: [
                          DataColumn(
                            label: Text(
                              'Day'.tr,
                              style: TextStyle(
                                fontSize: scaleConfig.scaleText(
                                  8,
                                ), // Scaled font size
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Incomes'.tr,
                              style: TextStyle(
                                fontSize: scaleConfig.scaleText(
                                  8,
                                ), // Scaled font size
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Expenses'.tr,
                              style: TextStyle(
                                fontSize: scaleConfig.scaleText(
                                  8,
                                ), // Scaled font size
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Savings'.tr,
                              style: TextStyle(
                                fontSize: scaleConfig.scaleText(
                                  8,
                                ), // Scaled font size
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                        rows: [
                          for (
                            var day = 0;
                            day < (isCurrentMonth ? currentDay : daysInMonth);
                            day++
                          )
                            DataRow(
                              onSelectChanged: (_) {
                                // Navigate to DayReportPage when the row is tapped
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => DayReportPage(
                                          day:
                                              day +
                                              1, // Day number (1-based index)
                                          month: month,
                                          year: year,
                                        ),
                                  ),
                                );
                              },
                              cells: [
                                DataCell(
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_forward, // Interactive icon
                                        color: AppColors.accentColor,
                                        size: scaleConfig.scale(
                                          10,
                                        ), // Scaled size
                                      ),
                                      SizedBox(
                                        width: scaleConfig.scale(6),
                                      ), // Scaled width
                                      Text(
                                        '${day + 1}', // Display day number (1, 2, 3, ...)
                                        style: TextStyle(
                                          fontSize: scaleConfig.scaleText(
                                            10,
                                          ), // Scaled font size
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    getFormattedAmount(dailyIncomes[day], ref),
                                    style: TextStyle(
                                      fontSize: scaleConfig.scaleText(
                                        8,
                                      ), // Scaled font size
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    getFormattedAmount(dailyExpenses[day], ref),
                                    style: TextStyle(
                                      fontSize: scaleConfig.scaleText(
                                        8,
                                      ), // Scaled font size
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    (dailyIncomes[day] - dailyExpenses[day] < 0
                                        ? "0"
                                        : getFormattedAmount(
                                          dailyIncomes[day] -
                                              dailyExpenses[day],
                                          ref,
                                        )),
                                    style: TextStyle(
                                      fontSize: scaleConfig.scaleText(
                                        8,
                                      ), // Scaled font size
                                      color:
                                          (dailyIncomes[day] -
                                                      dailyExpenses[day]) >=
                                                  0
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          DataRow(
                            color: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.primary,
                            ), // Darker row for totals
                            cells: [
                              DataCell(
                                Text(
                                  'Total'.tr,
                                  style: TextStyle(
                                    fontSize: scaleConfig.scaleText(
                                      8,
                                    ), // Scaled font size
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  getFormattedAmount(totalIncomes, ref),
                                  style: TextStyle(
                                    fontSize: scaleConfig.scaleText(
                                      8,
                                    ), // Scaled font size
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  getFormattedAmount(totalExpenses, ref),
                                  style: TextStyle(
                                    fontSize: scaleConfig.scaleText(
                                      8,
                                    ), // Scaled font size
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  getFormattedAmount(totalSavings, ref),
                                  style: TextStyle(
                                    fontSize: scaleConfig.scaleText(
                                      8,
                                    ), // Scaled font size
                                    fontWeight: FontWeight.bold,
                                    color:
                                        totalSavings > 0
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
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
      "Dec",
    ];

    if (monthNumber < 1 || monthNumber > 12) {
      throw ArgumentError("Month number must be between 1 and 12");
    }

    return monthNames[monthNumber - 1];
  }
}
