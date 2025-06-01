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
    final scaleConfig = context.scaleConfig; // Access ScaleConfig via extension

    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              "assets/money_s.json",
              width: scaleConfig.tabletScale(100), // Scaled for responsiveness
              fit: BoxFit.fill,
            ),
            Text(
              'No Data found.'.tr,
              style: TextStyle(
                fontSize: scaleConfig.tabletScaleText(11), // Scaled text
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: scaleConfig.tabletScale(20), // Scaled padding
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
                : Wallet(id: 'default', name: 'Default', type: WalletType.cash);
          },
        );
        debugPrint(
          'Expense ID: ${expense.id}, Wallet ID: ${expense.walletType.id}, Wallet Name: ${selectedWallet.name}',
        );

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              scaleConfig.tabletScale(15), // Scaled border radius
            ),
          ),
          margin: EdgeInsets.symmetric(
            vertical: scaleConfig.tabletScale(8), // Scaled margin
          ),
          elevation: 2,
          child: SizedBox(
            width: scaleConfig.tabletScale(355), // Scaled card width
            child: Padding(
              padding: EdgeInsets.all(
                scaleConfig.tabletScale(16), // Scaled padding
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    iconCategory,
                    size: scaleConfig.tabletScale(32), // Scaled icon size
                    color: iconColor,
                  ),
                  SizedBox(
                    width: scaleConfig.tabletScale(12),
                  ), // Scaled spacing
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
                              size: scaleConfig.tabletScale(14),
                            ),
                            SizedBox(width: scaleConfig.tabletScale(2)),
                            Text(
                              expense.title,
                              style: TextStyle(
                                fontSize: scaleConfig.tabletScaleText(
                                  12,
                                ), // Scaled text
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: scaleConfig.tabletScale(2),
                        ), // Scaled spacing
                        Row(
                          children: [
                            Icon(
                              Icons.money,
                              color: Colors.grey,
                              size: scaleConfig.tabletScale(14),
                            ),
                            SizedBox(width: scaleConfig.tabletScale(2)),
                            Consumer(
                              builder:
                                  (context, ref, _) => Text(
                                    getFormattedAmount(expense.amount, ref),
                                    style: TextStyle(
                                      fontSize: scaleConfig.tabletScaleText(
                                        10,
                                      ), // Scaled text
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
                              size: scaleConfig.tabletScale(14),
                            ),
                            SizedBox(width: scaleConfig.tabletScale(2)),
                            Text(
                              DateFormat('yyyy-MM-dd').format(expense.date),
                              style: TextStyle(
                                fontSize: scaleConfig.tabletScaleText(
                                  10,
                                ), // Scaled text
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
                              size: scaleConfig.tabletScale(14),
                            ),
                            SizedBox(width: scaleConfig.tabletScale(2)),
                            Text(
                              selectedWallet.name,
                              style: TextStyle(
                                fontSize: scaleConfig.tabletScaleText(
                                  10,
                                ), // Scaled text
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
                                  fontSize: scaleConfig.tabletScaleText(
                                    10,
                                  ), // Scaled text
                                  color: Colors.grey,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "${expense.notes}",
                                  style: TextStyle(
                                    fontSize: scaleConfig.tabletScaleText(
                                      10,
                                    ), // Scaled text
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
                      size: scaleConfig.tabletScale(24), // Scaled icon size
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
                                  size: scaleConfig.tabletScale(
                                    20,
                                  ), // Scaled icon size
                                ),
                                SizedBox(
                                  width: scaleConfig.tabletScale(8),
                                ), // Scaled spacing
                                Text(
                                  'Update'.tr,
                                  style: TextStyle(
                                    fontSize: scaleConfig.tabletScaleText(
                                      14,
                                    ), // Scaled text
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
                                  size: scaleConfig.tabletScale(
                                    20,
                                  ), // Scaled icon size
                                ),
                                SizedBox(
                                  width: scaleConfig.tabletScale(8),
                                ), // Scaled spacing
                                Text(
                                  'Delete'.tr,
                                  style: TextStyle(
                                    fontSize: scaleConfig.tabletScaleText(
                                      14,
                                    ), // Scaled text
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
