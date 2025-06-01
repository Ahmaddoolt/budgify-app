// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../data/models/expense.dart';
// import '../data/services/local_database_services.dart/expenses_repository.dart';

// final totalAmountCateProvider = StateNotifierProvider<TotalAmountCateNotifier, double>((ref) {
//   return TotalAmountCateNotifier();
// });

// class TotalAmountCateNotifier extends StateNotifier<double> {
//   TotalAmountCateNotifier() : super(0.0);

//   final ExpensesRepository repo = ExpensesRepository();

//   // Method to add an amount to the total
//   void incrementAmount(double amount) {
//     state += amount;
//   }

//   // Method to subtract an amount from the total
//   void decrementAmount(double amount) {
//     state -= amount;
//   }

//   // Method to set the total amount based on a list of expenses
//   void setTotalAmount(List<double> amounts) {
//     state = amounts.fold(0.0, (sum, amount) => sum + amount);
//   }

//   // Method to update total amount by category name
//   Future<void> updateTotalAmountByCategory(String categoryName) async {
//     await repo.openBox(); // Ensure the box is open
//     List<Expense> expensesByCategory = repo.getExpensesByCategoryName(categoryName);
//     List<double> amounts = expensesByCategory.map((expense) => expense.amount).toList();
//     setTotalAmount(amounts); // Update the total amount for the category
//   }
// }




import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/expense.dart';
import '../../data/repo/expenses_repository.dart';

final totalAmountCateProvider = StateNotifierProvider<TotalAmountCateNotifier, double>((ref) {
  return TotalAmountCateNotifier();
});

class TotalAmountCateNotifier extends StateNotifier<double> {
  TotalAmountCateNotifier() : super(0.0);

  final ExpensesRepository repo = ExpensesRepository();


//   // Method to add an amount to the total
  void incrementAmount(double amount) {
    state += amount;
  }

  // Method to subtract an amount from the total
  void decrementAmount(double amount) {
    state -= amount;
  }
  // Set the total amount for a list of amounts
  void setTotalAmount(List<double> amounts) {
    state = amounts.fold(0.0, (sum, amount) => sum + amount);
  }

  // Update total amount by category, with an optional monthly filter
  Future<void> updateTotalAmountByCategory(String categoryName, {bool isMonthly = false}) async {
    await repo.openBox(); // Ensure the database is open
    List<CashFlow> expenses = repo.getExpensesByCategoryName(categoryName);

    if (isMonthly) {
      DateTime now = DateTime.now();
      expenses = expenses.where((expense) {
        return expense.date.year == now.year && expense.date.month == now.month;
      }).toList();
    }

    // Map expenses to their amounts and update the state
    setTotalAmount(expenses.map((expense) => expense.amount).toList());
  }
}
