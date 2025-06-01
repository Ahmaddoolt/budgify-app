import 'dart:async'; // Add this import for StreamController
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../domain/models/expense.dart';

class MonthlyIncomesAmount extends StateNotifier<double> {
  MonthlyIncomesAmount() : super(0.0) {
    loadMonthlyAmount(); // Load the monthly amount initially
  }

  // Stream controller for monthly incomes
  final StreamController<List<CashFlow>> _monthlyIncomesController =
      StreamController<List<CashFlow>>.broadcast();

  // Getter for the stream
  Stream<List<CashFlow>> get monthlyIncomesStream => _monthlyIncomesController.stream;

  Future<void> loadMonthlyAmount() async {
    final box = Hive.box<CashFlow>('expenses'); // Open the expenses box
    final List<CashFlow> expenses = box.values.toList(); // Get all expenses
    final DateTime now = DateTime.now();

    // Filter incomes by the current month and where isIncome is true
    final List<CashFlow> monthlyIncomes = expenses.where((expense) {
      return expense.date.month == now.month &&
          expense.date.year == now.year &&
          expense.isIncome == true; // Only consider incomes where isIncome is true
    }).toList();

    updateMonthlyAmount(monthlyIncomes); // Update the total amount for current month
  }

  void updateMonthlyAmount(List<CashFlow> monthlyIncomes) {
    state = monthlyIncomes.fold(0.0, (sum, item) => sum + item.amount);
    _monthlyIncomesController.add(
        monthlyIncomes); // Emit the monthly incomes list whenever total amount is updated
  }

  // Function to add a new income
  Future<void> addIncome(CashFlow newIncome) async {
    final box = Hive.box<CashFlow>('expenses'); // Open the expenses box
    await box.add(newIncome); // Add the new income to the box
    await loadMonthlyAmount(); // Recalculate the monthly total amount
  }

  Future<void> deleteIncome(String id) async {
    final box = Hive.box<CashFlow>('expenses'); // Open the expenses box
    await box.delete(id); // Delete the income from the box
    await loadMonthlyAmount(); // Recalculate the monthly total amount after deletion
  }

  // Increment the monthly total income
  void increment(double amountPlus) {
    state += amountPlus;
    loadMonthlyAmount();
  }

  // Decrement the monthly total income
  void decrement(double amountMinus) async {
    state -= amountMinus;
    await loadMonthlyAmount();
  }

  @override
  void dispose() {
    _monthlyIncomesController.close(); // Close the stream controller when disposing
    super.dispose();
  }
}

// StateNotifierProvider to expose the MonthlyIncomesAmount
final monthlyIncomesAmountProvider =
    StateNotifierProvider<MonthlyIncomesAmount, double>((ref) {
  return MonthlyIncomesAmount();
});
