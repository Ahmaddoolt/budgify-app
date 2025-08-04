// lib/views/pages/deatil_cashflow_based_on_category/widgets_detail_cashflow/expense_update_dialog.dart

import 'package:budgify/core/constants/currencies.dart';
import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/snackbar_helper.dart';
import 'package:budgify/domain/models/currency.dart';
import 'package:budgify/domain/models/expense.dart';
import 'package:budgify/domain/models/wallet.dart';
import 'package:budgify/core/utils/date_picker_widget.dart';
import 'package:budgify/viewmodels/providers/currency_symbol.dart';
import 'package:budgify/viewmodels/providers/multi_currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class ExpenseUpdateDialog extends ConsumerStatefulWidget {
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
  ConsumerState<ExpenseUpdateDialog> createState() =>
      _ExpenseUpdateDialogState();
}

class _ExpenseUpdateDialogState extends ConsumerState<ExpenseUpdateDialog> {
  late TextEditingController titleController;
  late TextEditingController amountController;
  late TextEditingController notesController;
  late Wallet? selectedWallet;
  late DateTime selectedDate;
  late Currency? _selectedCurrency;
  bool isDateSelected = true;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.expense.title);
    amountController =
        TextEditingController(text: widget.expense.amount.toString());
    notesController = TextEditingController(text: widget.expense.notes ?? '');

    // --- THE FIX: Initialize currency by its unique code ---
    _selectedCurrency = availableCurrencies.firstWhere(
      (c) => c.code == widget.expense.currencyCode,
      // Fallback to the app's current display currency if the code isn't found
      orElse: () => ref.read(currencyProvider).displayCurrency,
    );

    try {
      selectedWallet = widget.wallets.firstWhere(
        (wallet) => wallet.id == widget.expense.walletType.id,
      );
    } catch (e) {
      selectedWallet = null;
    }

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
    final isMultiCurrencyEnabled = ref.watch(multiCurrencyProvider);

    // --- THE FIX: Filter wallets based on the selected currency's CODE ---
    final walletsForSelectedCurrency = widget.wallets
        .where((w) => w.currencyCode == _selectedCurrency?.code)
        .toList();

    return AlertDialog(
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(
        'Update Expense'.tr,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.accentColor,
            fontSize: 16),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title'.tr,
                prefixIcon:
                    const Icon(Icons.title, color: AppColors.accentColor),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount'.tr,
                prefixIcon: const Icon(Icons.attach_money,
                    color: AppColors.accentColor),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            if (isMultiCurrencyEnabled)
              DropdownButtonFormField<Currency>(
                dropdownColor: cardColor,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Currency'.tr,
                  prefixIcon: const Icon(Icons.currency_exchange,
                      color: AppColors.accentColor),
                ),
                value: _selectedCurrency,
                items: availableCurrencies.map((currency) {
                  return DropdownMenuItem<Currency>(
                    value: currency,
                    child: Text(
                      '${currency.code} (${currency.symbol})',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCurrency = newValue;
                    if (selectedWallet != null &&
                        selectedWallet!.currencyCode != newValue?.code) {
                      selectedWallet = null;
                    }
                  });
                },
              ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Wallet>(
              dropdownColor: cardColor,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Method'.tr,
                prefixIcon: const Icon(Icons.account_balance_wallet,
                    color: AppColors.accentColor),
              ),
              value: selectedWallet != null &&
                      walletsForSelectedCurrency.contains(selectedWallet)
                  ? selectedWallet
                  : null,
              items: walletsForSelectedCurrency.map((wallet) {
                return DropdownMenuItem<Wallet>(
                  value: wallet,
                  child: Text(wallet.name,
                      style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedWallet = value);
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Notes'.tr,
                prefixIcon:
                    const Icon(Icons.notes, color: AppColors.accentColor),
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
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'.tr,
              style: const TextStyle(color: AppColors.accentColor2)),
        ),
        TextButton(
          onPressed: () {
            if (titleController.text.isEmpty ||
                amountController.text.isEmpty ||
                selectedWallet == null ||
                _selectedCurrency == null ||
                !isDateSelected) {
              showFeedbackSnackbar(
                  context, 'Please fill all required fields'.tr);
              return;
            }

            // --- THE FIX: Create the updated expense with both code and symbol ---
            final updatedExpense = CashFlow(
              id: widget.expense.id,
              title: titleController.text,
              amount: double.tryParse(amountController.text) ?? 0.0,
              currencyCode: _selectedCurrency!.code,
              currencySymbol: _selectedCurrency!.symbol,
              category: widget.expense.category,
              date: selectedDate,
              notes: notesController.text.isEmpty
                  ? widget.expense.notes
                  : notesController.text,
              isIncome: widget.expense.isIncome,
              walletType: selectedWallet!,
            );
            widget.onUpdate(updatedExpense);
            Navigator.of(context).pop();
          },
          child: Text('Update'.tr,
              style: const TextStyle(color: AppColors.accentColor)),
        ),
      ],
    );
  }
}
