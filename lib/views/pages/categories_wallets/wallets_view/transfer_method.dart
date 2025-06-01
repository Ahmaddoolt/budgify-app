import 'package:budgify/core/utils/date_picker_widget.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/core/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../domain/models/wallet.dart';
import '../../../../data/repo/expenses_repository.dart';

// Providers
final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  return ExpensesRepository();
});

void showTransferDialog(
  BuildContext context,
  WidgetRef ref,
  List<Wallet> wallets,
) {
  final repository = ref.read(expensesRepositoryProvider);
  final amountController = TextEditingController();
  final scaleConfig = context.scaleConfig; // Access ScaleConfig
  Color cardColor = Theme.of(context).appBarTheme.backgroundColor!;

  showDialog(
    context: context,
    builder: (context) {
      Wallet? fromWallet;
      Wallet? toWallet;
      DateTime selectedDate = DateTime.now();
      bool isSelectedDate = false;
      bool isCheckingBalance = false;

      Future<double> getWalletBalance(Wallet wallet) async {
        try {
          final expenses = await repository.getExpensesStream().first;
          final walletExpenses = expenses.where(
            (e) => e.walletType.id == wallet.id,
          );

          final income = walletExpenses
              .where((e) => e.isIncome)
              .fold<double>(0, (sum, e) => sum + e.amount);
          final expense = walletExpenses
              .where((e) => !e.isIncome)
              .fold<double>(0, (sum, e) => sum + e.amount);
          return income - expense;
        } catch (e) {
          return 0.0;
        }
      }

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(scaleConfig.tabletScale(16)),
            ),
            title: Text(
              "Transfer Amount".tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: scaleConfig.tabletScaleText(12),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // From Wallet dropdown
                  DropdownButtonFormField<Wallet>(
                    dropdownColor: cardColor,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: scaleConfig.tabletScaleText(14),
                    ),
                    decoration: InputDecoration(
                      labelText: "From Wallet".tr,
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: scaleConfig.tabletScaleText(14),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white54,
                          width: scaleConfig.tabletScale(1),
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.accentColor,
                          width: scaleConfig.tabletScale(2),
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: scaleConfig.tabletScale(18),
                      ),
                    ),
                    items:
                        wallets.map((wallet) {
                          return DropdownMenuItem(
                            value: wallet,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                  size: scaleConfig.tabletScale(18),
                                ),
                                SizedBox(width: scaleConfig.tabletScale(8)),
                                Text(
                                  wallet.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: scaleConfig.tabletScaleText(12),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (value) => setState(() => fromWallet = value),
                    validator:
                        (value) =>
                            value == null ? 'Please select a wallet'.tr : null,
                  ),
                  SizedBox(height: scaleConfig.tabletScale(12)),

                  // To Wallet dropdown
                  DropdownButtonFormField<Wallet>(
                    dropdownColor: cardColor,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: scaleConfig.tabletScaleText(12),
                    ),
                    decoration: InputDecoration(
                      labelText: "To Wallet".tr,
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: scaleConfig.tabletScaleText(12),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white54,
                          width: scaleConfig.tabletScale(1),
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.accentColor,
                          width: scaleConfig.tabletScale(2),
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: scaleConfig.tabletScale(18),
                      ),
                    ),
                    items:
                        wallets.map((wallet) {
                          return DropdownMenuItem(
                            value: wallet,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                  size: scaleConfig.tabletScale(18),
                                ),
                                SizedBox(width: scaleConfig.tabletScale(8)),
                                Text(
                                  wallet.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: scaleConfig.tabletScaleText(14),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (value) => setState(() => toWallet = value),
                    validator:
                        (value) =>
                            value == null ? 'Please select a wallet'.tr : null,
                  ),
                  SizedBox(height: scaleConfig.tabletScale(12)),

                  // Amount field
                  TextFormField(
                    controller: amountController,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: scaleConfig.tabletScaleText(14),
                    ),
                    decoration: InputDecoration(
                      labelText: "Amount".tr,
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: scaleConfig.tabletScaleText(13),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white54,
                          width: scaleConfig.tabletScale(1),
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.accentColor,
                          width: scaleConfig.tabletScale(2),
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.money,
                        color: Colors.white,
                        size: scaleConfig.tabletScale(18),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount'.tr;
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number'.tr;
                      }
                      if (double.parse(value) <= 0) {
                        return 'Amount must be greater than zero'.tr;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: scaleConfig.tabletScale(12)),

                  // Date Picker Widget
                  DatePickerWidget(
                    initialDate: selectedDate,
                    onDateSelected: (picked) {
                      setState(() {
                        selectedDate = picked;
                        isSelectedDate = true;
                      });
                    },
                    isSelected: isSelectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    labelText: 'Date'.tr,
                    borderRadius: scaleConfig.tabletScale(12),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "Cancel".tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: scaleConfig.tabletScaleText(12),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      8,
                    ), // 👈 Set your desired radius here
                  ),
                  backgroundColor: AppColors.accentColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: scaleConfig.tabletScale(16),
                    vertical: scaleConfig.tabletScale(8),
                  ),
                ),
                onPressed: () async {
                  // Basic validation
                  if (fromWallet == null ||
                      toWallet == null ||
                      amountController.text.isEmpty) {
                    showFeedbackSnackbar(context, 'Please fill all fields'.tr);
                    return;
                  }

                  // Check same wallet
                  if (fromWallet!.id == toWallet!.id) {
                    showFeedbackSnackbar(
                      context,
                      'Cannot transfer to the same wallet'.tr,
                    );
                    return;
                  }

                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount <= 0) {
                    showFeedbackSnackbar(
                      context,
                      'Amount must be greater than zero'.tr,
                    );
                    return;
                  }

                  setState(() => isCheckingBalance = true);
                  final balance = await getWalletBalance(fromWallet!);
                  setState(() => isCheckingBalance = false);

                  // ignore: use_build_context_synchronously
                  if (!context.mounted) return;

                  if (balance <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Text(
                              'Source wallet has no available funds (Balance: '
                                  .tr,
                              style: TextStyle(
                                fontSize: scaleConfig.tabletScaleText(12),
                              ),
                            ),
                            SizedBox(width: scaleConfig.tabletScale(8)),
                            Text(
                              '${balance.toStringAsFixed(1)})',
                              style: TextStyle(
                                fontSize: scaleConfig.tabletScaleText(12),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (balance < amount) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Text(
                              'Insufficient funds. Available: '.tr,
                              style: TextStyle(
                                fontSize: scaleConfig.tabletScaleText(12),
                              ),
                            ),
                            SizedBox(width: scaleConfig.tabletScale(8)),
                            Text(
                              balance.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: scaleConfig.tabletScaleText(12),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    await repository.transferAmount(
                      fromWallet: fromWallet!,
                      toWallet: toWallet!,
                      amount: amount,
                      date: selectedDate,
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      showFeedbackSnackbar(
                        context,
                        'Transfer completed successfully'.tr,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Transfer failed: ${e.toString()}',
                            style: TextStyle(
                              fontSize: scaleConfig.tabletScaleText(12),
                            ),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child:
                    isCheckingBalance
                        ? SizedBox(
                          width: scaleConfig.tabletScale(20),
                          height: scaleConfig.tabletScale(20),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: scaleConfig.tabletScale(2),
                          ),
                        )
                        : Text(
                          "Transfer".tr,
                          style: TextStyle(
                            fontSize: scaleConfig.tabletScaleText(12),
                            color:
                                Theme.of(context).appBarTheme.backgroundColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ],
          );
        },
      );
    },
  );
}
