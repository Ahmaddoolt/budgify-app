import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/no_data_widget.dart';
import 'package:budgify/core/utils/parrot_animation_waiting.dart';
import 'package:budgify/core/utils/format_amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../../../core/utils/scale_config.dart'; // Import ScaleConfig
import '../../../../domain/models/expense.dart';
import '../../../../data/repo/expenses_repository.dart';
import 'month_report_table.dart';

class YearlyTablePage extends ConsumerWidget {
  final int year;

  const YearlyTablePage({super.key, required this.year});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaleConfig = ScaleConfig(context); // Initialize ScaleConfig
    final repository = ExpensesRepository();
    final now = DateTime.now();
    final currentMonth = now.month; // Get the current month

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detailed Report Table'.tr,
          style: TextStyle(
            fontSize: scaleConfig.scaleText(15), // Scaled font size
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

          // Initialize monthly totals
          final List<double> monthlyIncomes = List.filled(12, 0);
          final List<double> monthlyExpenses = List.filled(12, 0);

          for (var expense in expenses) {
            if (expense.date.year == year) {
              final month = expense.date.month - 1; // Zero-based index
              if (expense.isIncome) {
                monthlyIncomes[month] += expense.amount;
              } else {
                monthlyExpenses[month] += expense.amount;
              }
            }
          }

          // Calculate yearly totals
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
              SizedBox(height: scaleConfig.scale(20)), // Scaled height

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'Yearly Summary - '.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: scaleConfig.scaleText(15), // Scaled font size
                      ),
                    ),
                  ),
                  Text(
                    "$year",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: scaleConfig.scaleText(15), // Scaled font size
                    ),
                  ),
                ],
              ),

              SizedBox(height: scaleConfig.scale(20)), // Scaled height
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
                              'Month'.tr,
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
                            var month = 0;
                            month < (year == now.year ? currentMonth : 12);
                            month++
                          )
                            DataRow(
                              onSelectChanged: (_) {
                                // Navigate to MonthlyTablePage when the row is tapped
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => MonthlyTablePage(
                                          month:
                                              month +
                                              1, // Month number (1-based index)
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
                                        '${month + 1}', // Display month number (1, 2, 3, ...)
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
                                    getFormattedAmount(
                                      monthlyIncomes[month],
                                      ref,
                                    ),
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
                                    getFormattedAmount(
                                      monthlyExpenses[month],
                                      ref,
                                    ),
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
                                    _getSavingsValue(
                                      monthlyIncomes[month],
                                      monthlyExpenses[month],
                                      ref,
                                    ),
                                    style: TextStyle(
                                      fontSize: scaleConfig.scaleText(
                                        8,
                                      ), // Scaled font size
                                      color:
                                          (monthlyIncomes[month] -
                                                      monthlyExpenses[month]) >=
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
                                  _getSavingsValue(
                                    totalIncomes,
                                    totalExpenses,
                                    ref,
                                  ),
                                  style: TextStyle(
                                    fontSize: scaleConfig.scaleText(
                                      8,
                                    ), // Scaled font size
                                    fontWeight: FontWeight.bold,
                                    color:
                                        totalSavings >= 0
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

  // Helper function to calculate savings value
  String _getSavingsValue(double income, double expense, WidgetRef ref) {
    final savings = income - expense;
    return savings >= 0 ? getFormattedAmount(savings, ref) : '0';
  }
}
