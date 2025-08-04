// lib/views/pages/categories_wallets/wallets_view/transfer_dialog.dart

import 'package:budgify/core/utils/date_picker_widget.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/core/utils/snackbar_helper.dart';
import 'package:budgify/domain/models/transfer%20.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../domain/models/wallet.dart';
import '../../../../data/repo/transfer_repository.dart';
import '../../../../viewmodels/providers/wallet_provider.dart';

void showTransferDialog(
  BuildContext context,
  WidgetRef ref,
  List<Wallet> wallets,
) {
  final repository = ref.read(transferRepositoryProvider);
  final amountController = TextEditingController();
  final exchangeRateController = TextEditingController(text: '1.0');
  final responsive = context.responsive;
  Color cardColor = Theme.of(context).appBarTheme.backgroundColor!;

  final transferWallets =
      wallets.where((w) => w.isEnabled && w.isTransferEnabled).toList();

  showDialog(
    context: context,
    builder: (dialogContext) {
      Wallet? fromWallet;
      Wallet? toWallet;
      DateTime selectedDate = DateTime.now();
      bool isSelectedDate = false;
      bool isProcessing = false;
      final formKey = GlobalKey<FormState>();
      String? _errorMessage;

      Widget _buildErrorMessage() {
        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: _errorMessage == null
              ? const SizedBox.shrink()
              : Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.redAccent[100], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.redAccent[100], fontSize: 13),
                          textAlign: TextAlign.center, maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      }

      return StatefulBuilder(
        builder: (context, setState) {
          void clearError() {
            if (_errorMessage != null) {
              setState(() => _errorMessage = null);
            }
          }

          bool showExchangeRate =
              fromWallet != null &&
              toWallet != null &&
              fromWallet?.currencySymbol != toWallet?.currencySymbol;

          return AlertDialog(
            backgroundColor: cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsive.setWidth(16))),
            title: Text("Transfer Amount".tr, style: TextStyle(color: Colors.white, fontSize: responsive.setSp(12))),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Wallet>(
                      dropdownColor: cardColor,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(labelText: "From Wallet".tr, labelStyle: TextStyle(color: Colors.white70)),
                      items: transferWallets.map((w) => DropdownMenuItem(value: w, child: Text('${w.name} (${w.currencySymbol})'))).toList(),
                      onChanged: (v) => setState(() { fromWallet = v; clearError(); }),
                      validator: (v) => v == null ? 'Please select a wallet'.tr : null,
                    ),
                    SizedBox(height: responsive.setHeight(12)),
                    DropdownButtonFormField<Wallet>(
                      dropdownColor: cardColor,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(labelText: "To Wallet".tr, labelStyle: TextStyle(color: Colors.white70)),
                      items: transferWallets.map((w) => DropdownMenuItem(value: w, child: Text('${w.name} (${w.currencySymbol})'))).toList(),
                      onChanged: (v) => setState(() { toWallet = v; clearError(); }),
                      validator: (v) => v == null ? 'Please select a wallet'.tr : null,
                    ),
                    SizedBox(height: responsive.setHeight(12)),
                    TextFormField(
                      controller: amountController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(labelText: "Amount to Transfer".tr, labelStyle: TextStyle(color: Colors.white70)),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => clearError(),
                      validator: (v) => (v == null || v.isEmpty || double.tryParse(v) == null) ? 'Enter a valid amount'.tr : null,
                    ),
                    if (showExchangeRate)
                      Padding(
                        padding: EdgeInsets.only(top: responsive.setHeight(12)),
                        child: TextFormField(
                          controller: exchangeRateController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(labelText: '1 ${fromWallet?.currencySymbol} = ? ${toWallet?.currencySymbol}'.tr, labelStyle: TextStyle(color: Colors.white70)),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => clearError(),
                          validator: (v) => (v == null || double.tryParse(v) == null || double.parse(v) <= 0) ? 'Enter a valid rate'.tr : null,
                        ),
                      ),
                    SizedBox(height: responsive.setHeight(12)),
                    DatePickerWidget(
                      initialDate: selectedDate,
                      onDateSelected: (d) => setState(() { selectedDate = d; isSelectedDate = true; clearError(); }),
                      isSelected: isSelectedDate,
                      firstDate: DateTime(2000), lastDate: DateTime(2101),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Column(
                children: [
                  _buildErrorMessage(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text("Cancel".tr, style: TextStyle(color: AppColors.accentColor2)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          final amountToDebit = double.tryParse(amountController.text) ?? 0;
                          final exchangeRate = double.tryParse(exchangeRateController.text) ?? 1.0;
                          final amountToCredit = amountToDebit * exchangeRate;

                          if (fromWallet!.id == toWallet!.id) {
                            setState(() => _errorMessage = 'Cannot transfer to the same wallet'.tr);
                            return;
                          }
                          if (fromWallet!.value < amountToDebit) {
                            setState(() => _errorMessage = 'Insufficient funds'.tr);
                            return;
                          }
                          if (fromWallet!.minValue != null && fromWallet!.value >= fromWallet!.minValue! && (fromWallet!.value - amountToDebit) < fromWallet!.minValue!) {
                            setState(() => _errorMessage = 'This transfer would bring ${fromWallet!.name} below its minimum value'.tr);
                            return;
                          }
                          if (toWallet!.maxValue != null && (toWallet!.value + amountToCredit) > toWallet!.maxValue!) {
                            setState(() => _errorMessage = 'This transfer would push ${toWallet!.name} above its maximum value'.tr);
                            return;
                          }

                          setState(() => isProcessing = true);
                          try {
                            final newTransfer = Transfer(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              fromWalletId: fromWallet!.id,
                              toWalletId: toWallet!.id,
                              fromWalletName: fromWallet!.name,
                              toWalletName: toWallet!.name,
                              amountSent: amountToDebit,
                              amountReceived: amountToCredit,
                              fromCurrency: fromWallet!.currencySymbol,
                              toCurrency: toWallet!.currencySymbol,
                              exchangeRate: exchangeRate,
                              date: selectedDate,
                            );

                            await repository.createTransfer(newTransfer);

                            ref.read(walletProvider.notifier).handleTransfer(
                                  fromWallet!,
                                  toWallet!,
                                  amountToDebit,
                                  amountToCredit,
                                );
                                
                            ref.invalidate(transferHistoryProvider);
                            
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                              showFeedbackSnackbar(context, 'Transfer successful'.tr);
                            }
                          } catch (e) {
                            setState(() => _errorMessage = 'Transfer failed'.tr);
                          } finally {
                            if (dialogContext.mounted) {
                              setState(() => isProcessing = false);
                            }
                          }
                        },
                        child: isProcessing 
                            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) 
                            : Text("Transfer".tr, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}