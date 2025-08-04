import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../domain/models/category.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/wallet.dart';

class ExpensesRepository {
  late Box<CashFlow> _box;

  // Constructor to open the box
  ExpensesRepository() {
    openBox();
  }

  // Private method to open the box
  Future<void> openBox() async {
    if (!Hive.isBoxOpen('expenses')) {
      _box = await Hive.openBox<CashFlow>('expenses');
    } else {
      _box = Hive.box<CashFlow>('expenses');
    }
  }

  // Method to get the box directly
  Box<CashFlow> get box => _box;

  // Stream method to get expenses
  Stream<List<CashFlow>> getExpensesStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 1)); // Polling interval
      yield _box.values.toList(); // Yield the current list of expenses
    }
  }

  // Method to add expense
  Future<void> addExpense(CashFlow expense) async {
    await _box.add(expense);
  }

  // Method to delete expense by index
  Future<void> deleteExpense(int index) async {
    await _box.deleteAt(index);
  }

  // Method to delete expense by ID
  Future<void> deleteById(String id) async {
    final key = _box.keys.firstWhere(
      (key) => _box.get(key)?.id == id,
      orElse: () => null,
    );
    if (key != null) {
      await _box.delete(key);
    }
  }

  // Method to update expense
  Future<void> updateExpense(CashFlow updatedExpense) async {
    int indexo = _box.values
        .toList()
        .indexWhere((expense) => expense.id == updatedExpense.id);

    await _box.putAt(indexo, updatedExpense);
  }

  // Method to get expenses by category name
  List<CashFlow> getExpensesByCategoryName(String categoryName) {
    return _box.values
        .where((expense) => expense.category.name == categoryName)
        .toList();
  }

  // New method to delete all expenses by category name
  Future<void> deleteAllByCategoryName(String categoryName) async {
    final keysToDelete = _box.keys.where((key) {
      final expense = _box.get(key);
      return expense?.category.name == categoryName;
    }).toList();

    for (final key in keysToDelete) {
      await _box.delete(key);
    }
  }

  // --- NEW METHOD ---
  /// Finds and deletes all cash flow records associated with a specific wallet ID.
  /// This is called by the CashFlowNotifier when a user chooses to delete a wallet and its transactions.
  Future<void> deleteCashFlowsByWallet(String walletId) async {
    // Find all the Hive keys for cash flows where the wallet ID matches.
    final keysToDelete = _box.keys.where((key) {
      final cashFlow = _box.get(key);
      // Check if cashFlow is not null and if its wallet's ID matches.
      return cashFlow?.walletType.id == walletId;
    }).toList(); // Collect keys into a new list to avoid modification during iteration issues.

    // Delete all the found cash flows using their keys.
    for (final key in keysToDelete) {
      await _box.delete(key);
    }
  }

  Future<void> transferAmount({
    required Wallet fromWallet,
    required Wallet toWallet,
    required double amount,
    required DateTime date,
  }) async {
    if (amount <= 0) {
      throw Exception("Amount must be greater than zero.");
    }
    if (fromWallet.id == toWallet.id) {
      throw Exception("Cannot transfer to the same wallet.");
    }

    // Deduct from source wallet
    final outflow = CashFlow(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: "Transfer to ${toWallet.name}",
      amount: amount,
      currencySymbol: fromWallet.currencySymbol,
      date: date,
      category: Category(
        id: '20',
        name: 'Transfer',
        iconKey: 'sync_alt',
        color: const Color(0xff1E90FF),
        isNew: false,
        type: CategoryType.expense,
      ),
      isIncome: false,
      walletType: fromWallet,
      currencyCode: fromWallet.currencyCode,
    );

    // Add to destination wallet
    final inflow = CashFlow(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      title: "Received from ${fromWallet.name}",
      amount: amount,
      currencySymbol: toWallet.currencySymbol,
      date: date,
      category: Category(
        id: '21',
        name: 'Transfer In',
        iconKey: 'move_to_inbox',
        color: const Color(0xff228B22),
        isNew: false,
        type: CategoryType.income,
      ),
      isIncome: true,
      walletType: toWallet,
      currencyCode: toWallet.currencyCode,
    );

    await _box.add(outflow);
    await _box.add(inflow);
  }
}
