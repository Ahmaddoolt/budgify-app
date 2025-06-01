import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/snackbar_helper.dart';
import 'package:budgify/domain/models/expense.dart';
import 'package:budgify/domain/models/wallet.dart';
import 'package:budgify/core/utils/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpenseUpdateDialog extends StatefulWidget {
  final CashFlow expense;
  final List<Wallet> wallets;
  final double scale;
  final Function(CashFlow) onUpdate;

  const ExpenseUpdateDialog({
    super.key,
    required this.expense,
    required this.wallets,
    required this.scale,
    required this.onUpdate,
  });

  @override
  State<ExpenseUpdateDialog> createState() => _ExpenseUpdateDialogState();
}

class _ExpenseUpdateDialogState extends State<ExpenseUpdateDialog> {
  late TextEditingController titleController;
  late TextEditingController amountController;
  late TextEditingController notesController;
  late Wallet? selectedWallet;
  late DateTime selectedDate;
  bool isDateSelected = true; // Track date selection state

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.expense.title);
    amountController = TextEditingController(
      text: widget.expense.amount.toString(),
    );
    notesController = TextEditingController(text: widget.expense.notes ?? '');
    selectedWallet = widget.wallets.firstWhere(
      (wallet) => wallet.id == widget.expense.walletType.id,
      orElse: () {
        debugPrint(
          'No wallet found for ID: ${widget.expense.walletType.id}, using first wallet',
        );
        return widget.wallets.isNotEmpty
            ? widget.wallets.first
            : Wallet(id: 'default', name: 'Default', type: WalletType.cash);
      },
    );
    debugPrint(
      'Update dialog: Expense Wallet ID: ${widget.expense.walletType.id}, Selected Wallet ID: ${selectedWallet!.id}, Name: ${selectedWallet!.name}',
    );
    selectedDate = widget.expense.date;
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color cardColor = Theme.of(context).appBarTheme.backgroundColor!;

    return AlertDialog(
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(
        'Update Expense'.tr,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.accentColor,
          fontSize: 16
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title'.tr,
                prefixIcon: const Icon(
                  Icons.title,
                  color: AppColors.accentColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount'.tr,
                prefixIcon: const Icon(
                  Icons.attach_money,
                  color: AppColors.accentColor,
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Wallet>(
              dropdownColor: cardColor,
              style: const TextStyle(color: Colors.grey),
              decoration: InputDecoration(
                labelText: 'Method'.tr,
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.accentColor),
                ),
                prefixIcon: const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.accentColor,
                ),
              ),
              value: selectedWallet,
              items:
                  widget.wallets.map((wallet) {
                    return DropdownMenuItem<Wallet>(
                      value: wallet,
                      child: Text(
                        wallet.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedWallet = value;
                  debugPrint(
                    'Updated selected wallet: ID: ${value?.id}, Name: ${value?.name}',
                  );
                });
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Notes'.tr,
                prefixIcon: const Icon(
                  Icons.notes,
                  color: AppColors.accentColor,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            DatePickerWidget(
              initialDate: selectedDate,
              isSelected: isDateSelected,
              onDateSelected: (pickedDate) {
                setState(() {
                  selectedDate = pickedDate;
                  isDateSelected = true;
                });
              },
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Cancel'.tr,
            style: const TextStyle(color: AppColors.accentColor2),
          ),
        ),
        TextButton(
          onPressed: () {
            if (titleController.text.isEmpty ||
                amountController.text.isEmpty ||
                selectedWallet == null ||
                !isDateSelected) {
              showFeedbackSnackbar(
                context,
                'Please fill all required fields'.tr,
              );

              return;
            }
            debugPrint(
              'Updating expense ID: ${widget.expense.id} with Wallet ID: ${selectedWallet!.id}, Name: ${selectedWallet!.name}',
            );
            final updatedExpense = CashFlow(
              id: widget.expense.id,
              title: titleController.text,
              amount: double.tryParse(amountController.text) ?? 0.0,
              category: widget.expense.category,
              date: selectedDate,
              notes:
                  notesController.text.isEmpty
                      ? widget.expense.notes
                      : notesController.text,
              isIncome: widget.expense.isIncome,
              walletType: selectedWallet!,
            );
            widget.onUpdate(updatedExpense);
            Navigator.of(context).pop();
          },
          child: Text(
            'Update'.tr,
            style: const TextStyle(color: AppColors.accentColor),
          ),
        ),
      ],
    );
  }
}
