import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/no_data_widget.dart';
import 'package:budgify/core/utils/parrot_animation_waiting.dart';
import 'package:budgify/core/utils/format_amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:budgify/data/repo/wallet_repository.dart';
import '../../../../domain/models/expense.dart';
import '../../../../domain/models/wallet.dart';
import '../../../../data/repo/expenses_repository.dart';
import '../../../../core/utils/scale_config.dart'; // Import ScaleConfig

class DayReportPage extends ConsumerWidget {
  final int day;
  final int month;
  final int year;

  const DayReportPage({
    super.key,
    required this.day,
    required this.month,
    required this.year,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaleConfig = ScaleConfig(context); // Initialize ScaleConfig
    final repository = ExpensesRepository();
    final walletRepository = WalletRepository(
      Hive.box<Wallet>('wallets'),
    ); // Initialize WalletRepository
    final wallets = walletRepository.getWallets(); // Fetch wallets
    final cardColor = Theme.of(context).appBarTheme.backgroundColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detailed Report Table'.tr,
          style: TextStyle(
            fontSize: scaleConfig.scaleText(18), // Scaled font size
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

          // Filter transactions for the selected day
          final dailyTransactions =
              expenses.where((expense) {
                final expenseDate = expense.date;
                return expenseDate.day == day &&
                    expenseDate.month == month &&
                    expenseDate.year == year;
              }).toList();

          if (dailyTransactions.isEmpty) {
            return NoDataWidget();
          }

          // Calculate totals
          double totalIncomes = 0;
          double totalExpenses = 0;

          for (var transaction in dailyTransactions) {
            if (transaction.isIncome) {
              totalIncomes += transaction.amount;
            } else {
              totalExpenses += transaction.amount;
            }
          }

          // Ensure savings is not less than 0
          final double totalSavings = (totalIncomes - totalExpenses).clamp(
            0,
            double.infinity,
          );

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: scaleConfig.scale(20)), // Scaled height
                // Day Report Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Day Report - '.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: scaleConfig.scaleText(15), // Scaled font size
                      ),
                    ),
                    Text(
                      "$day/${month.toString().padLeft(2, '0')}/$year",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: scaleConfig.scaleText(15), // Scaled font size
                      ),
                    ),
                  ],
                ),
                SizedBox(height: scaleConfig.scale(20)), // Scaled height
                // Summary Section (Three Boxes)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: scaleConfig.scale(16.0), // Scaled padding
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryCard(
                        'Incomes',
                        totalIncomes,
                        AppColors.accentColor,
                        cardColor,
                        scaleConfig, // Pass ScaleConfig
                        ref,
                      ),
                      _buildSummaryCard(
                        'Expenses'.tr,
                        totalExpenses,
                        AppColors.accentColor2,
                        cardColor,
                        scaleConfig, // Pass ScaleConfig
                        ref,
                      ),
                      _buildSummaryCard(
                        'Savings',
                        totalSavings,
                        Colors.green,
                        cardColor,
                        scaleConfig, // Pass ScaleConfig
                        ref,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: scaleConfig.scale(20)), // Scaled height
                // Transactions Table
                Container(
                  width:
                      MediaQuery.of(context).size.width *
                      0.9, // Keep responsive width
                  padding: EdgeInsets.symmetric(
                    horizontal: scaleConfig.scale(12.0), // Scaled padding
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown, // Scale down content if it overflows
                    child: DataTable(
                      columnSpacing: scaleConfig.scale(20), // Scaled spacing
                      dataRowHeight: scaleConfig.scale(50), // Scaled height
                      headingRowHeight: scaleConfig.scale(60), // Scaled height
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
                            'Title'.tr,
                            style: TextStyle(
                              fontSize: scaleConfig.scaleText(
                                11.5,
                              ), // Scaled font size
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Category'.tr,
                            style: TextStyle(
                              fontSize: scaleConfig.scaleText(
                                11.5,
                              ), // Scaled font size
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Type'.tr,
                            style: TextStyle(
                              fontSize: scaleConfig.scaleText(
                                11.5,
                              ), // Scaled font size
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Amount'.tr,
                            style: TextStyle(
                              fontSize: scaleConfig.scaleText(
                                11.5,
                              ), // Scaled font size
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Wallet'.tr,
                            style: TextStyle(
                              fontSize: scaleConfig.scaleText(
                                11.5,
                              ), // Scaled font size
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                      rows:
                          dailyTransactions.map((transaction) {
                            // Find the wallet corresponding to the transaction's walletType.id
                            final wallet = wallets.firstWhere(
                              (wallet) =>
                                  wallet.id == transaction.walletType.id,
                              orElse:
                                  () => Wallet(
                                    id: 'default',
                                    name: 'Unknown',
                                    type: WalletType.cash,
                                  ),
                            );

                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    transaction.title,
                                    style: TextStyle(
                                      fontSize: scaleConfig.scaleText(
                                        11,
                                      ), // Scaled font size
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    transaction.category.name.tr,
                                    style: TextStyle(
                                      fontSize: scaleConfig.scaleText(
                                        11,
                                      ), // Scaled font size
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    transaction.isIncome
                                        ? 'Income'.tr
                                        : 'Expense'.tr,
                                    style: TextStyle(
                                      fontSize: scaleConfig.scaleText(
                                        11,
                                      ), // Scaled font size
                                      color:
                                          transaction.isIncome
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    getFormattedAmount(transaction.amount, ref),
                                    style: TextStyle(
                                      fontSize: scaleConfig.scaleText(
                                        11,
                                      ), // Scaled font size
                                      color:
                                          transaction.isIncome
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    wallet
                                        .name.tr, // Use wallet name from wallets list
                                    style: TextStyle(
                                      fontSize: scaleConfig.scaleText(
                                        11,
                                      ), // Scaled font size
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    Color? cardColor,
    ScaleConfig scaleConfig, // Accept ScaleConfig
    WidgetRef ref,
  ) {
    return Card(
      color: cardColor,
      child: Padding(
        padding: EdgeInsets.all(scaleConfig.scale(14.0)), // Scaled padding
        child: Column(
          children: [
            Text(
              title.tr,
              style: TextStyle(
                fontSize: scaleConfig.scaleText(12), // Scaled font size
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: scaleConfig.scale(8)), // Scaled height
            Text(
              getFormattedAmount(amount, ref),
              style: TextStyle(
                fontSize: scaleConfig.scaleText(11), // Scaled font size
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
