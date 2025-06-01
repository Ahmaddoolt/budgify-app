import 'dart:async'; // Add this import for StreamController
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../domain/models/expense.dart';

class MonthlyExpensesAmount extends StateNotifier<double> {
  MonthlyExpensesAmount() : super(0.0) {
    loadMonthlyAmount(); // Load the monthly amount initially
  }

  // Stream controller for monthly expenses
  final StreamController<List<CashFlow>> _monthlyExpensesController =
      StreamController<List<CashFlow>>.broadcast();

  // Getter for the stream
  Stream<List<CashFlow>> get monthlyExpensesStream => _monthlyExpensesController.stream;

  Future<void> loadMonthlyAmount() async {
    final box = Hive.box<CashFlow>('expenses'); // Open the expenses box
    final List<CashFlow> expenses = box.values.toList(); // Get all expenses
    final DateTime now = DateTime.now();

    // Filter expenses by the current month and where isIncome is false
    final List<CashFlow> monthlyExpenses = expenses.where((expense) {
      return expense.date.month == now.month &&
          expense.date.year == now.year &&
          expense.isIncome == false; // Only consider expenses where isIncome is false
    }).toList();

    updateMonthlyAmount(monthlyExpenses); // Update the total amount for current month
  }

  void updateMonthlyAmount(List<CashFlow> monthlyExpenses) {
    state = monthlyExpenses.fold(0.0, (sum, item) => sum + item.amount);
    _monthlyExpensesController.add(
        monthlyExpenses); // Emit the monthly expenses list whenever total amount is updated
  }

  // Function to add a new expense
  Future<void> addExpense(CashFlow newExpense) async {
    final box = Hive.box<CashFlow>('expenses'); // Open the expenses box
    await box.add(newExpense); // Add the new expense to the box
    await loadMonthlyAmount(); // Recalculate the monthly total amount
  }

  Future<void> deleteExpense(String id) async {
    final box = Hive.box<CashFlow>('expenses'); // Open the expenses box
    await box.delete(id); // Delete the expense from the box
    await loadMonthlyAmount(); // Recalculate the monthly total amount after deletion
  }

  // Increment the monthly total amount
  void increment(double amountPlus) {
    state += amountPlus;
    loadMonthlyAmount();
  }

  // Decrement the monthly total amount
  void decrement(double amountMinus) async {
    state -= amountMinus;
    await loadMonthlyAmount();
  }

  @override
  void dispose() {
    _monthlyExpensesController.close(); // Close the stream controller when disposing
    super.dispose();
  }
}

// StateNotifierProvider to expose the MonthlyExpensesAmount
final monthlyAmountProvider =
    StateNotifierProvider<MonthlyExpensesAmount, double>((ref) {
  return MonthlyExpensesAmount();
});
