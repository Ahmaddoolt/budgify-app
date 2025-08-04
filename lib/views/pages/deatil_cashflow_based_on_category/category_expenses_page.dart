import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/core/utils/snackbar_helper.dart';
import 'package:budgify/domain/models/expense.dart';
import 'package:budgify/viewmodels/expense/category_expenses_viewmodel.dart';
import 'package:budgify/viewmodels/providers/wallet_provider.dart';
import 'package:budgify/views/pages/deatil_cashflow_based_on_category/category_expenses_grid_page.dart';
import 'package:budgify/views/pages/deatil_cashflow_based_on_category/category_expenses_list_page.dart';
import 'package:budgify/views/widgets/cards/status_expenses_card.dart';
import 'package:budgify/views/pages/deatil_cashflow_based_on_category/widgets_detail_cashflow/expense_update_dialog.dart';
import 'package:budgify/views/pages/deatil_cashflow_based_on_category/widgets_detail_cashflow/expenses_list_view.dart';
import 'package:budgify/views/pages/deatil_cashflow_based_on_category/widgets_detail_cashflow/view_type_selector.dart';
import 'package:budgify/core/utils/no_data_widget.dart';
import 'package:budgify/core/utils/parrot_animation_waiting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class CategoryExpensesPage extends ConsumerStatefulWidget {
  final String categoryName;
  final IconData iconCategory;
  final Color iconColor;
  final bool isIncome;
  final String currencyCode;
  final String currencySymbol;
  final bool isDay;
  final bool isMonth;
  final bool isYear;
  final int day;
  final int month;
  final int year;

  const CategoryExpensesPage({
    super.key,
    required this.categoryName,
    required this.iconCategory,
    required this.iconColor,
    required this.isIncome,
    required this.currencyCode,
    required this.currencySymbol,
    this.isDay = false,
    this.isMonth = false,
    this.isYear = false,
    this.day = 1,
    this.month = 1,
    this.year = 2024,
  });

  @override
  ConsumerState<CategoryExpensesPage> createState() =>
      _CategoryExpensesPageState();
}

class _CategoryExpensesPageState extends ConsumerState<CategoryExpensesPage> {
  int chartType = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryExpensesViewModelProvider).updateTotalAmountByCategory(
            widget.categoryName,
            isMonthly: widget.isMonth,
          );
    });
  }

  bool _isDateInPeriod(DateTime date) {
    if (widget.isDay) {
      return date.year == widget.year &&
          date.month == widget.month &&
          date.day == widget.day;
    }
    if (widget.isMonth) {
      return date.year == widget.year && date.month == widget.month;
    }
    if (widget.isYear) {
      return date.year == widget.year;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final viewModel = ref.read(categoryExpensesViewModelProvider);
    final wallets = ref.watch(walletProvider).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        actions: [
          ViewTypeSelector(
            chartType: chartType,
            onChanged: (value) {
              setState(() {
                chartType = value ?? 0;
              });
            },
          ),
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.isIncome ? 'Incomes in '.tr : 'Expenses in '.tr,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: responsive.setSp(14.5))),
            Text(widget.categoryName.tr,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: responsive.setSp(14))),
          ],
        ),
      ),
      body: StreamBuilder<List<CashFlow>>(
        stream: viewModel.getExpensesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ParrotAnimation();
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(
                        fontSize: responsive.setSp(16), color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const NoDataWidget();
          }

          final allTransactionsInPeriod = snapshot.data!.where((exp) {
            final dateMatches = _isDateInPeriod(exp.date);
            return dateMatches && exp.currencyCode == widget.currencyCode;
          }).toList();

          final double allCategoriesTotal = allTransactionsInPeriod
              .where((exp) => exp.isIncome == widget.isIncome)
              .fold(0.0, (sum, exp) => sum + exp.amount);

          final expensesForThisCategory = allTransactionsInPeriod
              .where((exp) =>
                  exp.category.name == widget.categoryName &&
                  exp.isIncome == widget.isIncome)
              .toList();

          final double thisCategoryTotal =
              expensesForThisCategory.fold(0.0, (sum, exp) => sum + exp.amount);

          return Column(
            children: [
              SizedBox(height: responsive.setHeight(20)),
              ExpensesCardProgress(
                categoryTotal: thisCategoryTotal,
                allCategoriesTotal: allCategoriesTotal,
                categoryName: widget.categoryName,
                currencySymbol: widget.currencySymbol,
                isIncome: widget.isIncome,
              ),
              SizedBox(height: responsive.setHeight(20)),
              Expanded(
                child: Builder(builder: (context) {
                  if (expensesForThisCategory.isEmpty) {
                    return NoDataWidget();
                  }
                  if (chartType == 0) {
                    return ExpensesListView(
                      expenses: expensesForThisCategory,
                      wallets: wallets,
                      categoryName: widget.categoryName,
                      iconCategory: widget.iconCategory,
                      iconColor: widget.iconColor,
                      onUpdate: (expense) =>
                          _showUpdateDialog(context, expense),
                      onDelete: (expense) => _deleteExpense(expense),
                    );
                  } else if (chartType == 1) {
                    return CategoryExpensesGridPage(
                      expenses: expensesForThisCategory,
                      wallets: wallets,
                      onUpdate: (expense) =>
                          _showUpdateDialog(context, expense),
                      onDelete: (expense) => _deleteExpense(expense),
                      day: widget.day,
                      month: widget.month,
                      year: widget.year,
                      isDay: widget.isDay,
                      isMonth: widget.isMonth,
                      isYear: widget.isYear,
                      categoryName: widget.categoryName,
                      iconCategory: widget.iconCategory,
                      iconColor: widget.iconColor,
                      isIncome: widget.isIncome,
                    );
                  } else {
                    return CategoryExpensesListPage(
                      expenses: expensesForThisCategory,
                      wallets: wallets,
                      onUpdate: (expense) =>
                          _showUpdateDialog(context, expense),
                      onDelete: (expense) => _deleteExpense(expense),
                      day: widget.day,
                      month: widget.month,
                      year: widget.year,
                      isDay: widget.isDay,
                      isMonth: widget.isMonth,
                      isYear: widget.isYear,
                      categoryName: widget.categoryName,
                      iconCategory: widget.iconCategory,
                      iconColor: widget.iconColor,
                      isIncome: widget.isIncome,
                    );
                  }
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, CashFlow expense) {
    final responsive = context.responsive;
    final wallets = ref.read(walletProvider).toSet().toList();
    showDialog(
      context: context,
      builder: (context) => ExpenseUpdateDialog(
        expense: expense,
        wallets: wallets,
        scale: responsive.scaleFactor,
        onUpdate: (updatedExpense) async {
          final viewModel = ref.read(categoryExpensesViewModelProvider);
          await viewModel.updateExpense(
            expense,
            updatedExpense,
            isIncome: widget.isIncome,
            isMonth: widget.isMonth,
          );
          if (mounted) setState(() {});
        },
      ),
    );
  }

  void _deleteExpense(CashFlow expense) async {
    final viewModel = ref.read(categoryExpensesViewModelProvider);
    await viewModel.deleteExpense(
      expense,
      isIncome: widget.isIncome,
      isMonth: widget.isMonth,
    );
    if (mounted) {
      showFeedbackSnackbar(context, 'Expense deleted successfully.'.tr);
    }
  }
}
