// UPDATED: Import the new responsive utility
import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/domain/models/expense.dart';
import 'package:budgify/domain/models/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/utils/format_amount.dart';

class ExpensesListView extends StatelessWidget {
  final List<CashFlow> expenses;
  final List<Wallet> wallets;
  final String categoryName;
  final IconData iconCategory;
  final Color iconColor;
  final Function(CashFlow) onUpdate;
  final Function(CashFlow) onDelete;

  const ExpensesListView({
    super.key,
    required this.expenses,
    required this.wallets,
    required this.categoryName,
    required this.iconCategory,
    required this.iconColor,
    required this.onUpdate,
    required this.onDelete,
  });




  @override
  Widget build(BuildContext context) {
    // UPDATED: Use the new responsive extension
    final responsive = context.responsive;

    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              "assets/money_s.json",
              // UPDATED: Use setWidth for general scaling
              width: responsive.setWidth(100),
              fit: BoxFit.fill,
            ),
            Text(
              'No Data found.'.tr,
              style: TextStyle(
                // UPDATED: Use setSp for font sizes
                fontSize: responsive.setSp(11),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        // UPDATED: setWidth for horizontal padding
        horizontal: responsive.setWidth(20),
      ),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        Wallet? selectedWallet = wallets.firstWhere(
          (wallet) => wallet.id == expense.walletType.id,
          orElse: () {
            debugPrint(
              'No wallet found for ID: ${expense.walletType.id}, using first wallet',
            );
            return wallets.isNotEmpty
                ? wallets.first
                : Wallet(
                  id: 'default',
                  name: 'Unknown Wallet',
                  type: WalletType.cash,
                  currencySymbol: '???', // Provide a default currency symbol
                  isDefault: false,
                  isEnabled:
                      false, // Make it disabled by default so user knows something is wrong
                  allowedTransactionType: WalletFunctionality.both,
                  value: 0.0, currencyCode: '',
                );
          },
        );
        debugPrint(
          'Expense ID: ${expense.id}, Wallet ID: ${expense.walletType.id}, Wallet Name: ${selectedWallet.name}',
        );

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              // UPDATED: setWidth for border radius
              responsive.setWidth(15),
            ),
          ),
          margin: EdgeInsets.symmetric(
            // UPDATED: setHeight for vertical margin
            vertical: responsive.setHeight(8),
          ),
          elevation: 2,
          child: SizedBox(
            // UPDATED: setWidth for card width
            width: responsive.setWidth(355),
            child: Padding(
              // UPDATED: setWidth for all-around padding
              padding: EdgeInsets.all(responsive.setWidth(16)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    iconCategory,
                    size: responsive.setWidth(32),
                    color: iconColor,
                  ),
                  SizedBox(width: responsive.setWidth(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.title,
                              color: Colors.grey,
                              size: responsive.setWidth(14),
                            ),
                            SizedBox(width: responsive.setWidth(2)),
                            Text(
                              expense.title,
                              style: TextStyle(
                                fontSize: responsive.setSp(13),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: responsive.setHeight(2)),
                        Row(
                          children: [
                            Icon(
                              Icons.money,
                              color: Colors.grey,
                              size: responsive.setWidth(14),
                            ),
                            SizedBox(width: responsive.setWidth(2)),
                            Consumer(
                              builder:
                                  (context, ref, _) => Text(
                                    getFormattedAmount(expense.amount, ref),
                                    style: TextStyle(
                                      fontSize: responsive.setSp(12),
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.date_range,
                              color: Colors.grey,
                              size: responsive.setWidth(14),
                            ),
                            SizedBox(width: responsive.setWidth(2)),
                            Text(
                              DateFormat('yyyy-MM-dd').format(expense.date),
                              style: TextStyle(
                                fontSize: responsive.setSp(12),
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.wallet,
                              color: Colors.grey,
                              size: responsive.setWidth(14),
                            ),
                            SizedBox(width: responsive.setWidth(2)),
                            Text(
                              selectedWallet.name,
                              style: TextStyle(
                                fontSize: responsive.setSp(12),
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        if (expense.notes != null && expense.notes!.isNotEmpty)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Note: '.tr,
                                style: TextStyle(
                                  fontSize: responsive.setSp(11),
                                  color: Colors.grey,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "${expense.notes}",
                                  style: TextStyle(
                                    fontSize: responsive.setSp(11),
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.grey,
                      size: responsive.setWidth(24),
                    ),
                    onSelected: (value) {
                      if (value == 'Update') {
                        onUpdate(expense);
                      } else if (value == 'Delete') {
                        onDelete(expense);
                      }
                    },
                    itemBuilder:
                        (BuildContext context) => [
                          PopupMenuItem<String>(
                            value: 'Update',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: AppColors.accentColor,
                                  size: responsive.setWidth(20),
                                ),
                                SizedBox(width: responsive.setWidth(8)),
                                Text(
                                  'Update'.tr,
                                  style: TextStyle(
                                    fontSize: responsive.setSp(14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'Delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: responsive.setWidth(20),
                                ),
                                SizedBox(width: responsive.setWidth(8)),
                                Text(
                                  'Delete'.tr,
                                  style: TextStyle(
                                    fontSize: responsive.setSp(14),
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
