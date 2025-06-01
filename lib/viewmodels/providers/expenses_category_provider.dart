import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/expense.dart';
import '../../data/repo/expenses_repository.dart';

class ExpensesNotifier extends StateNotifier<List<CashFlow>> {
  final ExpensesRepository repository;
  final StreamController<List<CashFlow>> _expensesStreamController =
      StreamController<List<CashFlow>>.broadcast();

  ExpensesNotifier(this.repository) : super([]) {
    loadExpenses();
  }

  Stream<List<CashFlow>> get expensesStream => _expensesStreamController.stream;

  Future<void> loadExpenses() async {
    state = repository.box.values.toList();
    _expensesStreamController.add(state); // Emit updated state to the stream
  }

  Future<void> addExpense(CashFlow expense) async {
    await repository.addExpense(expense);
    await loadExpenses();
  }

  Future<void> updateExpense(CashFlow expense) async {
    await repository.updateExpense(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(int index) async {
    await repository.deleteExpense(index);
    await loadExpenses();
  }

  List<CashFlow> getExpensesByCategory(String category) {
    return state.where((expense) => expense.category.name == category).toList();
  }

  @override
  void dispose() {
    _expensesStreamController.close(); // Close the stream controller when done
    super.dispose();
  }
}

// Provider for ExpensesNotifier
final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, List<CashFlow>>((ref) {
  final repository = ExpensesRepository(); // Initialize your repository here
  return ExpensesNotifier(repository); // Load initial expenses
});
