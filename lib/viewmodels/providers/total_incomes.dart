import 'dart:async'; // Add this import for StreamController
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../domain/models/expense.dart';

class TotalIncomesAmount extends StateNotifier<double> {
  TotalIncomesAmount() : super(0.0) {
    loadTotalAmount(); // Load the total amount initially
  }

  // Stream controller for incomes
  final StreamController<List<CashFlow>> _incomesController =
      StreamController<List<CashFlow>>.broadcast();

  // Getter for the stream
  Stream<List<CashFlow>> get incomesStream => _incomesController.stream;

  Future<void> loadTotalAmount() async {
    final box = Hive.box<CashFlow>('expenses'); // Open the expenses box
    final List<CashFlow> expenses = box.values.toList(); // Get all expenses

    // Filter out expenses where isIncome is true (only consider incomes)
    final List<CashFlow> filteredIncomes =
        expenses.where((expense) => expense.isIncome == true).toList();

    updateTotalAmount(filteredIncomes);
  }

  void updateTotalAmount(List<CashFlow> expenses) {
    state = expenses.fold(0.0, (sum, item) => sum + item.amount);
    _incomesController.add(expenses); // Emit the incomes list whenever total amount is updated
  }

  // Function to add a new income
  Future<void> addIncome(CashFlow newIncome) async {
    final box = Hive.box<CashFlow>('expenses'); // Open the expenses box
    await box.add(newIncome); // Add the new income to the box
    await loadTotalAmount(); // Recalculate the total amount
  }

  Future<void> deleteIncome(String id) async {
    final box = Hive.box<CashFlow>('expenses'); // Open the expenses box
    await box.delete(id); // Delete the income from the box
    await loadTotalAmount(); // Recalculate the total amount after deletion
  }

  // Increment the total income amount
  void increment(double amountPlus) {
    state += amountPlus;
    loadTotalAmount();
  }

  // Decrement the total income amount
  void decrement(double amountMinus) async {
    state -= amountMinus;
    await loadTotalAmount();
  }

  @override
  void dispose() {
    _incomesController.close(); // Close the stream controller when disposing
    super.dispose();
  }
}

// StateNotifierProvider to expose the TotalIncomesAmount
final totalIncomesAmountProvider =
    StateNotifierProvider<TotalIncomesAmount, double>((ref) {
  return TotalIncomesAmount();
});
