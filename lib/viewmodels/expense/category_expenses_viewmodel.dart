import 'package:budgify/data/repo/expenses_repository.dart';
import 'package:budgify/domain/models/expense.dart';
import 'package:budgify/viewmodels/providers/total_amount_exp_category.dart';
import 'package:budgify/viewmodels/providers/total_expenses_amount.dart';
import 'package:budgify/viewmodels/providers/total_expenses_monthly.dart';
import 'package:budgify/viewmodels/providers/total_incomes.dart';
import 'package:budgify/viewmodels/providers/total_incomes_monthly.dart';
import 'package:budgify/viewmodels/providers/wallet_provider.dart'; // <-- IMPORT WALLET PROVIDER
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryExpensesViewModel {
  final ExpensesRepository repository;
  final Ref ref;

  CategoryExpensesViewModel(this.repository, this.ref);

  Stream<List<CashFlow>> getExpensesStream() {
    return repository.getExpensesStream();
  }

  List<CashFlow> filterExpenses(
    List<CashFlow> expenses, {
    required String categoryName,
    required bool isYear,
    required bool isMonth,
    required bool isDay,
    required int year,
    required int month,
    required int day,
  }) {
    return expenses.where((expense) {
      final date = expense.date;
      return expense.category.name == categoryName &&
          (!isYear || date.year == year) &&
          (!isMonth || date.month == month) &&
          (!isDay || date.day == day);
    }).toList();
  }

  Future<void> deleteExpense(CashFlow expense,
      {required bool isIncome, required bool isMonth}) async {
    // Delete from the database first
    await repository.deleteById(expense.id);

    // --- THE FIX: Update wallet value ---
    // Reverse the transaction's effect on the wallet.
    // If we delete an income, we subtract from the wallet (isIncome: false).
    // If we delete an expense, we add to the wallet (isIncome: true).
    ref.read(walletProvider.notifier).updateWalletValue(
          expense.walletType.id,
          expense.amount,
          isIncome: !expense.isIncome, // Notice the "!" to invert the logic
        );

    // Update other total-tracking providers
    ref.read(totalAmountCateProvider.notifier).decrementAmount(expense.amount);

    if (isIncome && isMonth) {
      ref.read(monthlyIncomesAmountProvider.notifier).decrement(expense.amount);
    } else if (isIncome && !isMonth) {
      ref.read(totalIncomesAmountProvider.notifier).decrement(expense.amount);
    } else if (!isIncome && isMonth) {
      ref.read(monthlyAmountProvider.notifier).decrement(expense.amount);
    } else if (!isIncome && !isMonth) {
      ref.read(totalAmountProvider.notifier).decrement(expense.amount);
    }
  }

  Future<void> updateExpense(
    CashFlow oldExpense,
    CashFlow updatedExpense, {
    required bool isIncome,
    required bool isMonth,
  }) async {
    // Update in the database
    await repository.updateExpense(updatedExpense);

    // --- THE FIX: Update wallet value correctly ---
    // Step 1: Reverse the old transaction from its wallet
    ref.read(walletProvider.notifier).updateWalletValue(
          oldExpense.walletType.id,
          oldExpense.amount,
          isIncome: !oldExpense.isIncome, // Reverse the old transaction
        );
    // Step 2: Apply the new transaction to its wallet (which might be a different wallet)
    ref.read(walletProvider.notifier).updateWalletValue(
          updatedExpense.walletType.id,
          updatedExpense.amount,
          isIncome: updatedExpense.isIncome, // Apply the new transaction
        );

    // Update other total-tracking providers
    final oldAmount = oldExpense.amount;
    final newAmount = updatedExpense.amount;

    ref.read(totalAmountCateProvider.notifier).decrementAmount(oldAmount);
    ref.read(totalAmountCateProvider.notifier).incrementAmount(newAmount);

    if (isIncome && isMonth) {
      ref.read(monthlyIncomesAmountProvider.notifier).decrement(oldAmount);
      ref.read(monthlyIncomesAmountProvider.notifier).increment(newAmount);
    } else if (isIncome && !isMonth) {
      ref.read(totalIncomesAmountProvider.notifier).decrement(oldAmount);
      ref.read(totalIncomesAmountProvider.notifier).increment(newAmount);
    } else if (!isIncome && isMonth) {
      ref.read(monthlyAmountProvider.notifier).decrement(oldAmount);
      ref.read(monthlyAmountProvider.notifier).increment(newAmount);
    } else if (!isIncome && !isMonth) {
      ref.read(totalAmountProvider.notifier).decrement(oldAmount);
      ref.read(totalAmountProvider.notifier).increment(newAmount);
    }
  }

  void updateTotalAmountByCategory(String categoryName,
      {required bool isMonthly}) {
    ref.read(totalAmountCateProvider.notifier).updateTotalAmountByCategory(
          categoryName,
          isMonthly: isMonthly,
        );
  }
}

final categoryExpensesViewModelProvider =
    Provider<CategoryExpensesViewModel>((ref) {
  // Pass the ref to the ViewModel constructor
  return CategoryExpensesViewModel(ExpensesRepository(), ref);
});
