import 'package:budgify/data/repo/expenses_repository.dart';
import 'package:budgify/domain/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Provider for the ExpensesRepository
final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  // This assumes your ExpensesRepository constructor is parameterless
  // and handles opening the Hive box internally.
  return ExpensesRepository();
});

// 2. The main StateNotifierProvider for CashFlows
final cashFlowProvider =
    StateNotifierProvider<CashFlowNotifier, List<CashFlow>>((ref) {
  final repository = ref.watch(expensesRepositoryProvider);
  return CashFlowNotifier(repository);
});

// 3. The StateNotifier class that manages the list of CashFlows
class CashFlowNotifier extends StateNotifier<List<CashFlow>> {
  final ExpensesRepository _repository;

  CashFlowNotifier(this._repository) : super([]) {
    // Initialize the state by loading all cash flows from the repository
    loadCashFlows();
  }

  // Method to load all transactions from the database
  Future<void> loadCashFlows() async {
    // Ensure the box is open before trying to read from it
    await _repository.openBox();
    state = _repository.box.values.toList();
  }

  // Method to add a new transaction
  Future<void> addCashFlow(CashFlow cashFlow) async {
    await _repository.addExpense(cashFlow);
    // Reload the state to include the new item
    await loadCashFlows();
  }

  // Method to update an existing transaction
  Future<void> updateCashFlow(CashFlow updatedCashFlow) async {
    await _repository.updateExpense(updatedCashFlow);
    state = [
      for (final cashFlow in state)
        if (cashFlow.id == updatedCashFlow.id) updatedCashFlow else cashFlow,
    ];
  }

  // Method to delete a transaction by its ID
  Future<void> deleteCashFlowById(String id) async {
    await _repository.deleteById(id);
    state = state.where((cashFlow) => cashFlow.id != id).toList();
  }

  // --- THIS IS THE NEW METHOD THAT FIXES THE ERROR ---
  /// Deletes all cash flow records associated with a specific wallet ID.
  /// This is called from WalletNotifier.
  Future<void> deleteTransactionsByWalletId(String walletId) async {
    try {
      // Call the repository method we created earlier
      await _repository.deleteCashFlowsByWallet(walletId);

      // Update the UI state to remove the deleted items immediately
      state =
          state.where((cashflow) => cashflow.walletType.id != walletId).toList();
    } catch (e) {
      debugPrint("Failed to delete cashflows for wallet $walletId: $e");
      // Optionally re-throw or handle the error
    }
  }
}