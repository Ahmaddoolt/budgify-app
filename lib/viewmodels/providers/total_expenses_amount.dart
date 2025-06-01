import 'dart:async'; // Add this import for StreamController
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../domain/models/expense.dart';

class TotalExpensesAmount extends StateNotifier<double> {
  TotalExpensesAmount() : super(0.0) {
    loadTotalAmount(); // Load the total amount initially
  }

  // Stream controller for expenses
  final StreamController<List<CashFlow>> _expensesController =
      StreamController<List<CashFlow>>.broadcast();

  // Getter for the stream
  Stream<List<CashFlow>> get expensesStream => _expensesController.stream;

  Future<void> loadTotalAmount() async {
    final box = Hive.box<CashFlow>('expenses'); // Open the expenses box
    final List<CashFlow> expenses = box.values.toList(); // Get all expenses

    // Filter out expenses where isIncome is false
    final List<CashFlow> filteredExpenses =
        expenses.where((expense) => expense.isIncome == false).toList();

    updateTotalAmount(filteredExpenses);
  }

  void updateTotalAmount(List<CashFlow> expenses) {
    state = expenses.fold(0.0, (sum, item) => sum + item.amount);
    _expensesController.add(
        expenses); // Emit the expenses list whenever total amount is updated
  }

  // Function to add a new expense
  Future<void> addExpense(CashFlow newExpense) async {
    final box = Hive.box<CashFlow>('expenses'); // Open the expenses box
    await box.add(newExpense); // Add the new expense to the box
    await loadTotalAmount(); // Recalculate the total amount
  }

  Future<void> deleteExpense(String id) async {
    final box = Hive.box<CashFlow>('expenses'); // Open the expenses box
    await box.delete(id); // Delete the expense from the box
    await loadTotalAmount(); // Recalculate the total amount after deletion
  }

  // Increment the total amount
  void increment(double amountPlus) {
    state += amountPlus;
    loadTotalAmount();
  }

  // Decrement the total amount
  void decrement(double amountMinus) async {
    state -= amountMinus;
    await loadTotalAmount();
  }

  @override
  void dispose() {
    _expensesController.close(); // Close the stream controller when disposing
    super.dispose();
  }
}

// StateNotifierProvider to expose the TotalExpensesAmount
final totalAmountProvider =
    StateNotifierProvider<TotalExpensesAmount, double>((ref) {
  return TotalExpensesAmount();
});
