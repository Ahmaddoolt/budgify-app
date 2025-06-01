import 'package:budgify/data/repo/expenses_repository.dart';
import 'package:budgify/domain/models/expense.dart';
import 'package:budgify/viewmodels/providers/total_amount_exp_category.dart';
import 'package:budgify/viewmodels/providers/total_expenses_amount.dart';
import 'package:budgify/viewmodels/providers/total_expenses_monthly.dart';
import 'package:budgify/viewmodels/providers/total_incomes.dart';
import 'package:budgify/viewmodels/providers/total_incomes_monthly.dart';
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

  Future<void> deleteExpense(CashFlow expense, {required bool isIncome, required bool isMonth}) async {
    await repository.deleteById(expense.id);
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
    CashFlow expense,
    CashFlow updatedExpense, {
    required bool isIncome,
    required bool isMonth,
  }) async {
    await repository.updateExpense(updatedExpense);

    final oldAmount = expense.amount;
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

  void updateTotalAmountByCategory(String categoryName, {required bool isMonthly}) {
    ref.read(totalAmountCateProvider.notifier).updateTotalAmountByCategory(
          categoryName,
          isMonthly: isMonthly,
        );
  }
}

final categoryExpensesViewModelProvider = Provider<CategoryExpensesViewModel>((ref) {
  return CategoryExpensesViewModel(ExpensesRepository(), ref);
});