// lib/views/pages/home_page/budget/list_budget.dart

import 'package:budgify/core/utils/no_data_widget.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/core/utils/snackbar_helper.dart';
import 'package:budgify/viewmodels/providers/lang_provider.dart';
import 'package:budgify/core/utils/format_amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../domain/models/budget.dart';
import '../../../../domain/models/category.dart';
import '../../../../domain/models/expense.dart';
import '../../../../data/repo/expenses_repository.dart';

class BudgetListView extends ConsumerWidget {
  // --- THE FIX: Receive both code for logic and symbol for display ---
  final String currencyCode;
  final String currencySymbol;

  const BudgetListView({
    super.key,
    required this.currencyCode,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = context.responsive;
    bool isArabic = ref.watch(languageProvider).toString() == "ar";

    final budgetBox = Hive.box<Budget>('budgets');
    final categoriesBox = Hive.box<Category>('categories');
    final repository = ExpensesRepository();

    Color cardColor = Theme.of(context).cardTheme.color!;

    return ValueListenableBuilder(
      valueListenable: budgetBox.listenable(),
      builder: (context, Box<Budget> box, _) {
        final allBudgets = box.values.toList();
        // --- THE FIX: Filter budgets by the unique currencyCode ---
        final budgets =
            allBudgets.where((b) => b.currencyCode == currencyCode).toList();

        if (budgets.isEmpty) {
          return const NoDataWidget();
        }

        return StreamBuilder<List<CashFlow>>(
          stream: repository.getExpensesStream(),
          builder: (context, snapshot) {
            final expenses = snapshot.data ?? [];
            final now = DateTime.now();
            // --- THE FIX: Also filter expenses by the unique currencyCode ---
            final currentMonthExpenses = expenses.where(
              (expense) =>
                  expense.date.year == now.year &&
                  expense.date.month == now.month &&
                  expense.currencyCode == currencyCode,
            );

            final Map<String, double> monthlyCategoryTotals = {};
            for (var expense in currentMonthExpenses) {
              final categoryName = expense.category.name;
              monthlyCategoryTotals[categoryName] =
                  (monthlyCategoryTotals[categoryName] ?? 0) + expense.amount;
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(budgets.length, (index) {
                  final budget = budgets[index];
                  final category = categoriesBox.get(budget.categoryId);

                  // Use the symbol stored in the budget itself
                  final String currency = budget.currencySymbol;

                  if (category == null) return const SizedBox();

                  final spentAmount =
                      monthlyCategoryTotals[category.name] ?? 0.0;
                  final budgetAmount = budget.budgetAmount;

                  final progress = (budgetAmount > 0)
                      ? (spentAmount / budgetAmount).clamp(0.0, 1.0)
                      : 0.0;

                  bool showWarning = progress >= 0.75;

                  return Padding(
                    padding: EdgeInsets.all(responsive.setWidth(12)),
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: responsive.setWidth(185),
                        maxWidth: responsive.setWidth(195),
                      ),
                      padding: EdgeInsets.all(responsive.setWidth(16)),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(
                          responsive.setWidth(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: responsive.setWidth(45),
                                      height: responsive.setHeight(45),
                                      decoration: BoxDecoration(
                                        color: category.color.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(
                                          responsive.setWidth(12),
                                        ),
                                      ),
                                      child: Icon(
                                        category.icon,
                                        color: category.color,
                                      ),
                                    ),
                                    SizedBox(width: responsive.setWidth(12)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category.name.tr,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: responsive.setSp(10),
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          SizedBox(
                                            height: responsive.setHeight(2),
                                          ),
                                          Row(
                                            children: [
                                              isArabic
                                                  ? Row(
                                                      children: [
                                                        Text(
                                                          getFormattedAmount(
                                                            (budgetAmount / 30),
                                                            ref,
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: responsive
                                                                .setSp(8),
                                                            color: Colors
                                                                .grey[400],
                                                          ),
                                                        ),
                                                        Text(
                                                          currency,
                                                          style: TextStyle(
                                                            fontSize: responsive
                                                                .setSp(8),
                                                            color: Colors
                                                                .grey[400],
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Text(
                                                      '$currency${getFormattedAmount((budgetAmount / 30), ref)}',
                                                      style: TextStyle(
                                                        fontSize:
                                                            responsive.setSp(8),
                                                        color: Colors.grey[400],
                                                      ),
                                                    ),
                                              Text(
                                                " per day".tr,
                                                style: TextStyle(
                                                  fontSize: responsive.setSp(8),
                                                  color: Colors.grey[400],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: responsive.setWidth(30),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    Icons.remove_circle,
                                    color: AppColors.accentColor2,
                                    size: responsive.setWidth(15),
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Row(
                                          children: [
                                            Icon(
                                              Icons.warning_amber_rounded,
                                              color: AppColors.accentColor2,
                                              size: responsive.setWidth(20),
                                            ),
                                            SizedBox(
                                              width: responsive.setWidth(6),
                                            ),
                                            Text(
                                              'Delete Budget'.tr,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: responsive.setSp(
                                                  14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        content: Text(
                                          'Are you sure you want to delete this budget? This action cannot be undone.'
                                              .tr,
                                          style: TextStyle(
                                            fontSize: responsive.setSp(12),
                                            color: Colors.white,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(
                                              context,
                                            ).pop(),
                                            child: Text(
                                              'Cancel'.tr,
                                              style: TextStyle(
                                                color: AppColors.accentColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: responsive.setSp(
                                                  12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // Use the budget's key for safe deletion
                                              budgetBox.delete(budget.key);
                                              Navigator.of(context).pop();
                                              showFeedbackSnackbar(
                                                context,
                                                'Budget deleted successfully!'
                                                    .tr,
                                              );
                                            },
                                            child: Text(
                                              'Delete'.tr,
                                              style: TextStyle(
                                                color: AppColors.accentColor2,
                                                fontWeight: FontWeight.bold,
                                                fontSize: responsive.setSp(
                                                  12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                        backgroundColor: cardColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            responsive.setWidth(16),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: responsive.setHeight(8)),
                          LinearProgressIndicator(
                            borderRadius: BorderRadius.circular(12),
                            value: progress,
                            color: showWarning
                                ? AppColors.accentColor2
                                : AppColors.accentColor,
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            minHeight: responsive.setHeight(10),
                          ),
                          SizedBox(height: responsive.setHeight(6)),
                          !isArabic
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$currency${getFormattedAmount(spentAmount, ref)}',
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: responsive.setSp(7),
                                      ),
                                    ),
                                    Text(
                                      "$currency${getFormattedAmount(budgetAmount, ref)}",
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: responsive.setSp(7),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${getFormattedAmount(spentAmount, ref)}$currency',
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: responsive.setSp(7),
                                      ),
                                    ),
                                    Text(
                                      "${getFormattedAmount(budgetAmount, ref)}$currency",
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: responsive.setSp(7),
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        );
      },
    );
  }
}
