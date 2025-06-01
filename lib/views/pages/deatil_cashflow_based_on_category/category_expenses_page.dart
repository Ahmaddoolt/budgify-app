import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/core/utils/snackbar_helper.dart';
import 'package:budgify/domain/models/expense.dart';
import 'package:budgify/viewmodels/providers/currency_symbol.dart';
import 'package:budgify/viewmodels/expense/category_expenses_viewmodel.dart';
import 'package:budgify/viewmodels/providers/total_amount_exp_category.dart';
import 'package:budgify/viewmodels/providers/wallet_provider.dart';
import 'package:budgify/views/widgets/cards/status_expenses_card.dart';
import 'package:budgify/views/pages/deatil_cashflow_based_on_category/widgets_detail_cashflow/expense_update_dialog.dart';
import 'package:budgify/views/pages/deatil_cashflow_based_on_category/widgets_detail_cashflow/expenses_list_view.dart';
import 'package:budgify/views/pages/deatil_cashflow_based_on_category/widgets_detail_cashflow/view_type_selector.dart';
import 'package:budgify/core/utils/no_data_widget.dart';
import 'package:budgify/core/utils/parrot_animation_waiting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'category_expenses_grid_page.dart';
import 'category_expenses_list_page.dart';

class CategoryExpensesPage extends ConsumerStatefulWidget {
  final String categoryName;
  final IconData iconCategory;
  final Color iconColor;
  final bool isIncome;
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
    ref
        .read(categoryExpensesViewModelProvider)
        .updateTotalAmountByCategory(
          widget.categoryName,
          isMonthly: widget.isMonth,
        );
    debugPrint(
      'CategoryExpensesPage initState: categoryName=${widget.categoryName}, '
      'isIncome=${widget.isIncome}, isDay=${widget.isDay}, isMonth=${widget.isMonth}, '
      'isYear=${widget.isYear}, day=${widget.day}, month=${widget.month}, year=${widget.year}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaleConfig = ScaleConfig(context);
    final viewModel = ref.read(categoryExpensesViewModelProvider);
    final totalAmount = ref.watch(totalAmountCateProvider);
    final currencySymbol = ref.watch(currencyProvider).currencySymbol;
    final wallets = ref.watch(walletProvider).toSet().toList();
    debugPrint(
      'Wallets from walletProvider: ${wallets.map((w) => "${w.id}: ${w.name}").toList()}',
    );

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
            Text(
              widget.isIncome ? 'Incomes in '.tr : 'Expenses in '.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: scaleConfig.scaleText(12),
              ),
            ),
            Text(
              widget.categoryName.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: scaleConfig.scaleText(12),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: scaleConfig.scale(20)),
          ExpensesCardProgress(
            totalAmount,
            widget.categoryName,
            currencySymbol,
            widget.isIncome,
            widget.isMonth,
          ),
          SizedBox(height: scaleConfig.scale(20)),
          Expanded(
            child: StreamBuilder<List<CashFlow>>(
              stream: viewModel.getExpensesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ParrotAnimation();
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(
                        fontSize: scaleConfig.scaleText(16),
                        color: Colors.red,
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return NoDataWidget();
                }

                final expenses = viewModel.filterExpenses(
                  snapshot.data!,
                  categoryName: widget.categoryName,
                  isYear: widget.isYear,
                  isMonth: widget.isMonth,
                  isDay: widget.isDay,
                  year: widget.year,
                  month: widget.month,
                  day: widget.day,
                );
                debugPrint(
                  'CategoryExpensesPage: Filtered expenses: ${expenses.length}',
                );

                if (chartType == 0) {
                  return ExpensesListView(
                    expenses: expenses,
                    wallets: wallets,
                    categoryName: widget.categoryName,
                    iconCategory: widget.iconCategory,
                    iconColor: widget.iconColor,
                    onUpdate: (expense) => _showUpdateDialog(context, expense),
                    onDelete: (expense) => _deleteExpense(expense),
                  );
                } else if (chartType == 1) {
                  return CategoryExpensesGridPage(
                    day: widget.day,
                    month: widget.month,
                    year: widget.year,
                    isYear: widget.isYear,
                    isMonth: widget.isMonth,
                    isDay: widget.isDay,
                    categoryName: widget.categoryName,
                    iconCategory: widget.iconCategory,
                    iconColor: widget.iconColor,
                    isIncome: widget.isIncome,
                    expenses: expenses,
                    wallets: wallets,
                    onUpdate: (expense) => _showUpdateDialog(context, expense),
                    onDelete: (expense) => _deleteExpense(expense),
                  );
                } else {
                  return CategoryExpensesListPage(
                    day: widget.day,
                    month: widget.month,
                    year: widget.year,
                    isYear: widget.isYear,
                    isMonth: widget.isMonth,
                    isDay: widget.isDay,
                    categoryName: widget.categoryName,
                    iconCategory: widget.iconCategory,
                    iconColor: widget.iconColor,
                    isIncome: widget.isIncome,
                    expenses: expenses,
                    wallets: wallets,
                    onUpdate: (expense) => _showUpdateDialog(context, expense),
                    onDelete: (expense) => _deleteExpense(expense),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, CashFlow expense) {
    final scaleConfig = ScaleConfig(context);
    final wallets = ref.read(walletProvider).toSet().toList();
    showDialog(
      context: context,
      builder:
          (context) => ExpenseUpdateDialog(
            expense: expense,
            wallets: wallets,
            scale: scaleConfig.scaleFactor,
            onUpdate: (updatedExpense) async {
              final viewModel = ref.read(categoryExpensesViewModelProvider);
              await viewModel.updateExpense(
                expense,
                updatedExpense,
                isIncome: widget.isIncome,
                isMonth: widget.isMonth,
              );
              setState(() {});
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
    // ignore: use_build_context_synchronously
    showFeedbackSnackbar(context, 'Expense deleted successfully.'.tr);
  }
}
