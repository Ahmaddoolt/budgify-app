// lib/views/pages/graphscreen/reports_tables/day_report_table.dart

import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/no_data_widget.dart';
import 'package:budgify/core/utils/parrot_animation_waiting.dart';
import 'package:budgify/core/utils/format_amount.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:budgify/data/repo/wallet_repository.dart';
import '../../../../domain/models/expense.dart';
import '../../../../domain/models/wallet.dart';
import '../../../../data/repo/expenses_repository.dart';

class DayReportPage extends ConsumerWidget {
  final int day;
  final int month;
  final int year;
  // --- THE FIX: Add currency properties ---
  final String currencyCode;
  final String currencySymbol;

  const DayReportPage({
    super.key,
    required this.day,
    required this.month,
    required this.year,
    required this.currencyCode,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = context.responsive;
    final repository = ExpensesRepository();
    final walletRepository = WalletRepository(Hive.box<Wallet>('wallets'));
    final wallets = walletRepository.getWallets();
    final cardColor = Theme.of(context).appBarTheme.backgroundColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detailed Report Table'.tr,
          style: TextStyle(
            fontSize: responsive.setSp(18),
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
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const NoDataWidget();
          }

          final expenses = snapshot.data!;

          // --- THE FIX: Add currencyCode to the filter ---
          final dailyTransactions = expenses.where((expense) {
            if (expense.currencyCode != currencyCode) return false;

            final expenseDate = expense.date;
            return expenseDate.day == day &&
                expenseDate.month == month &&
                expenseDate.year == year;
          }).toList();

          if (dailyTransactions.isEmpty) {
            return const NoDataWidget();
          }

          double totalIncomes = 0;
          double totalExpenses = 0;

          for (var transaction in dailyTransactions) {
            if (transaction.isIncome) {
              totalIncomes += transaction.amount;
            } else {
              totalExpenses += transaction.amount;
            }
          }

          final double totalSavings = (totalIncomes - totalExpenses);

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: responsive.setHeight(20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Day Report - '.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: responsive.setSp(15),
                      ),
                    ),
                    Text(
                      "$day/${month.toString().padLeft(2, '0')}/$year",
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
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.setWidth(16.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryCard(
                        'Incomes',
                        totalIncomes,
                        AppColors.accentColor,
                        cardColor,
                        responsive,
                        ref,
                      ),
                      _buildSummaryCard(
                        'Expenses'.tr,
                        totalExpenses,
                        AppColors.accentColor2,
                        cardColor,
                        responsive,
                        ref,
                      ),
                      _buildSummaryCard(
                        'Savings',
                        totalSavings,
                        totalSavings >= 0 ? Colors.green : Colors.red,
                        cardColor,
                        responsive,
                        ref,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: responsive.setHeight(20)),
                Container(
                  width: responsive.widthPercent(0.9),
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.setWidth(12.0),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: DataTable(
                      columnSpacing: responsive.setWidth(20),
                      dataRowHeight: responsive.setHeight(50),
                      headingRowHeight: responsive.setHeight(60),
                      decoration: BoxDecoration(
                        color: Theme.of(context).appBarTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(
                          responsive.setWidth(10),
                        ),
                      ),
                      columns: [
                        DataColumn(
                          label: Text('Title'.tr,
                              style: TextStyle(
                                  fontSize: responsive.setSp(11.5),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        DataColumn(
                          label: Text('Category'.tr,
                              style: TextStyle(
                                  fontSize: responsive.setSp(11.5),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        DataColumn(
                          label: Text('Type'.tr,
                              style: TextStyle(
                                  fontSize: responsive.setSp(11.5),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        DataColumn(
                          label: Text('Amount'.tr,
                              style: TextStyle(
                                  fontSize: responsive.setSp(11.5),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        DataColumn(
                          label: Text('Wallet'.tr,
                              style: TextStyle(
                                  fontSize: responsive.setSp(11.5),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ],
                      rows: dailyTransactions.map((transaction) {
                        final wallet = wallets.firstWhere(
                          (wallet) => wallet.id == transaction.walletType.id,
                          orElse: () => Wallet(
                            id: 'default',
                            name: 'Unknown Wallet',
                            type: WalletType.cash,
                            currencyCode: '???',
                            currencySymbol: '?',
                            isDefault: false,
                            isEnabled: false,
                            allowedTransactionType: WalletFunctionality.both,
                            value: 0.0,
                          ),
                        );

                        return DataRow(
                          cells: [
                            DataCell(Text(transaction.title,
                                style: TextStyle(
                                    fontSize: responsive.setSp(11),
                                    color: Colors.white))),
                            DataCell(Text(transaction.category.name.tr,
                                style: TextStyle(
                                    fontSize: responsive.setSp(11),
                                    color: Colors.white))),
                            DataCell(Text(
                                transaction.isIncome
                                    ? 'Income'.tr
                                    : 'Expense'.tr,
                                style: TextStyle(
                                    fontSize: responsive.setSp(11),
                                    color: transaction.isIncome
                                        ? Colors.green
                                        : Colors.red))),
                            DataCell(
                              // --- THE FIX: Display symbol with amount ---
                              Text(
                                '${transaction.currencySymbol} ${getFormattedAmount(transaction.amount, ref)}',
                                style: TextStyle(
                                    fontSize: responsive.setSp(11),
                                    color: transaction.isIncome
                                        ? Colors.green
                                        : Colors.red),
                              ),
                            ),
                            DataCell(Text(wallet.name.tr,
                                style: TextStyle(
                                    fontSize: responsive.setSp(11),
                                    color: Colors.white))),
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
    ResponsiveUtil responsive,
    WidgetRef ref,
  ) {
    return Card(
      color: cardColor,
      child: Padding(
        padding: EdgeInsets.all(responsive.setWidth(14.0)),
        child: Column(
          children: [
            Text(
              title.tr,
              style: TextStyle(
                  fontSize: responsive.setSp(12),
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: responsive.setHeight(8)),
            // --- THE FIX: Display symbol with amount ---
            Text(
              '$currencySymbol ${getFormattedAmount(amount, ref)}',
              style: TextStyle(
                  fontSize: responsive.setSp(11),
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
          ],
        ),
      ),
    );
  }
}
