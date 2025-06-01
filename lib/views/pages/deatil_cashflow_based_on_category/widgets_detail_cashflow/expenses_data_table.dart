import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/domain/models/expense.dart';
import 'package:budgify/domain/models/wallet.dart';
import 'package:budgify/core/utils/format_amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ExpensesDataTable extends StatelessWidget {
  final List<CashFlow> expenses;
  final List<Wallet> wallets;
  final Function(CashFlow) onRowSelected;
  final double scale; // Approximate scale for responsiveness

  const ExpensesDataTable({
    super.key,
    required this.expenses,
    required this.wallets,
    required this.onRowSelected,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: scale * 22,
        showCheckboxColumn: false,
        decoration: BoxDecoration(
          color: Theme.of(context).appBarTheme.backgroundColor,
          borderRadius: BorderRadius.circular(scale * 12),
        ),
        columns: [
          DataColumn(label: Text('Title'.tr)),
          DataColumn(label: Text('Amount'.tr)),
          DataColumn(label: Text('Date'.tr)),
          DataColumn(label: Text('Method'.tr)),
        ],
        rows: expenses.map((expense) {
          Wallet? selectedWallet = wallets.firstWhere(
            (wallet) => wallet.id == expense.walletType.id,
            orElse: () {
              debugPrint('No wallet found for ID: ${expense.walletType.id}, using first wallet');
              return wallets.isNotEmpty
                  ? wallets.first
                  : Wallet(id: 'default', name: 'Default', type: WalletType.cash);
            },
          );
          debugPrint(
              'Expense ID: ${expense.id}, Wallet ID: ${expense.walletType.id}, Wallet Name: ${selectedWallet.name}');

          return DataRow(
            onSelectChanged: (_) => onRowSelected(expense),
            cells: [
              DataCell(
                SizedBox(
                  width: scale * 40,
                  child: Text(
                    expense.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: scale * 5,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: scale * 50,
                  child: Consumer(
                    builder: (context, ref, _) => Text(
                      getFormattedAmount(expense.amount, ref),
                      style: TextStyle(
                        color: AppColors.accentColor,
                        fontSize: scale * 5,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: scale * 70,
                  child: Text(
                    DateFormat('yyyy-MM-dd').format(expense.date),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: scale * 7,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: scale * 40,
                  child: Text(
                    selectedWallet.name,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: scale * 5,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}