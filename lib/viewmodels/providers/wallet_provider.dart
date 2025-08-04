import 'package:budgify/viewmodels/providers/cashflow_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgify/domain/models/wallet.dart';
import 'package:hive/hive.dart';
import '../../data/repo/wallet_repository.dart';
import 'currency_symbol.dart'; // Import the currency provider to get the default

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final walletBox = Hive.box<Wallet>('wallets');
  return WalletRepository(walletBox);
});

final walletProvider = StateNotifierProvider<WalletNotifier, List<Wallet>>((
  ref,
) {
  final repository = ref.watch(walletRepositoryProvider);
  return WalletNotifier(repository, ref);
});

class WalletNotifier extends StateNotifier<List<Wallet>> {
  final WalletRepository _repository;
  final Ref _ref;

  WalletNotifier(this._repository, this._ref)
      : super(_repository.getWallets()) {
    initializeWallets();
  }

  Future<void> initializeWallets() async {
    // This method should ONLY create default wallets if the database is empty.
    if (state.isEmpty) {
      final defaultCurrency = _ref.read(currencyProvider).displayCurrency;

      final defaultCash = Wallet(
        id: 'default_cash',
        name: 'Cash',
        type: WalletType.cash,
        isDefault: true,
        currencyCode: defaultCurrency.code,
        currencySymbol: defaultCurrency.symbol,
      );
      final defaultBank = Wallet(
        id: 'default_bank',
        name: 'Bank',
        type: WalletType.bank,
        isDefault: false,
        currencyCode: defaultCurrency.code,
        currencySymbol: defaultCurrency.symbol,
      );

      await addWallet(defaultCash);
      await addWallet(defaultBank);
    }
  }

  Future<void> addWallet(Wallet wallet) async {
    try {
      await _repository.addWallet(wallet);
      state = [...state, wallet];
    } catch (e) {
      throw Exception('Failed to add wallet: $e');
    }
  }

  Future<void> updateWallet(Wallet updatedWallet) async {
    try {
      await _repository.updateWallet(updatedWallet);
      state = [
        for (final wallet in state)
          if (wallet.id == updatedWallet.id) updatedWallet else wallet,
      ];
    } catch (e) {
      throw Exception('Failed to update wallet: $e');
    }
  }

  // --- NEW METHOD 1: Deletes the wallet and all associated transactions ---
  /// Deletes all transactions associated with the wallet ID, then deletes the wallet itself.
  Future<void> deleteWalletAndTransactions(String walletId) async {
    try {
      // Step 1: Delete all CashFlow items linked to this wallet.
      // IMPORTANT: You must implement `deleteTransactionsByWalletId` in your CashFlowNotifier.
      // Example implementation in CashFlowNotifier:
      //
      // Future<void> deleteTransactionsByWalletId(String walletId) async {
      //   await _repository.deleteCashFlowsByWallet(walletId);
      //   state = state.where((cf) => cf.walletType.id != walletId).toList();
      // }
      await _ref
          .read(cashFlowProvider.notifier)
          .deleteTransactionsByWalletId(walletId);

      // Step 2: After transactions are gone, delete the wallet itself.
      await deleteWalletOnly(walletId);

    } catch (e) {
      debugPrint("Failed to delete wallet and its transactions: $e");
      throw Exception('Failed to delete wallet and its transactions: $e');
    }
  }

  // --- NEW METHOD 2 (replaces old `deleteWallet`): Deletes only the wallet ---
  /// Deletes a single wallet by its ID, leaving any associated transactions intact.
  Future<void> deleteWalletOnly(String walletId) async {
    try {
      // The repository needs a method to delete by ID (which is the Hive key).
      await _repository.deleteWalletById(walletId);
      state = state.where((w) => w.id != walletId).toList();
    } catch (e) {
      debugPrint("Failed to delete wallet: $e");
      throw Exception('Failed to delete wallet: $e');
    }
  }

  void updateWalletValue(
    String walletId,
    double amount, {
    required bool isIncome,
  }) {
    try {
      final walletToUpdate = state.firstWhere((w) => w.id == walletId);
      final updatedCopy = walletToUpdate.copyWith(
        value: isIncome
            ? walletToUpdate.value + amount
            : walletToUpdate.value - amount,
      );
      updateWallet(updatedCopy);
    } catch (e) {
      debugPrint("Could not find wallet with ID $walletId to update value.");
    }
  }

  void handleTransfer(
    Wallet fromWallet,
    Wallet toWallet,
    double amountToDebit,
    double amountToCredit,
  ) {
    final updatedFromWallet = fromWallet.copyWith(
      value: fromWallet.value - amountToDebit,
    );
    final updatedToWallet = toWallet.copyWith(
      value: toWallet.value + amountToCredit,
    );
    updateWallet(updatedFromWallet);
    updateWallet(updatedToWallet);
  }

  void reverseTransfer({
    required String fromWalletId,
    required String toWalletId,
    required double amountSent,
    required double amountReceived,
  }) {
    try {
      final fromWallet = state.firstWhere((w) => w.id == fromWalletId);
      final toWallet = state.firstWhere((w) => w.id == toWalletId);

      final updatedFromWallet = fromWallet.copyWith(
        value: fromWallet.value + amountSent,
      );
      final updatedToWallet = toWallet.copyWith(
        value: toWallet.value - amountReceived,
      );

      updateWallet(updatedFromWallet);
      updateWallet(updatedToWallet);
    } catch (e) {
      debugPrint("Error reversing transfer: $e");
      // Handle the case where a wallet might have been deleted.
    }
  }
}