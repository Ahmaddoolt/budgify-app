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
import '../../../../viewmodels/providers/currency_symbol.dart';
import '../../../../core/utils/scale_config.dart';

class BudgetListView extends ConsumerWidget {
  const BudgetListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = context.scaleConfig;
    final currency = ref.watch(currencyProvider).currencySymbol;
    bool isArabic = ref.watch(languageProvider).toString() == "ar";

    final budgetBox = Hive.box<Budget>('budgets');
    final categoriesBox = Hive.box<Category>('categories');
    final repository = ExpensesRepository();

    Color cardColor = Theme.of(context).cardTheme.color!;

    return ValueListenableBuilder(
      valueListenable: budgetBox.listenable(),
      builder: (context, Box<Budget> box, _) {
        final budgets = box.values.toList();

        if (budgets.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  "assets/money_s.json",
                  width: scale.scale(86),
                  fit: BoxFit.fill,
                ),
                Text(
                  'No Budgets found.'.tr,
                  style: TextStyle(fontSize: scale.scaleText(12)),
                ),
              ],
            ),
          );
        }

        return StreamBuilder<List<CashFlow>>(
          stream: repository.getExpensesStream(),
          builder: (context, snapshot) {
            final expenses = snapshot.data ?? [];
            final now = DateTime.now();
            final currentMonthExpenses = expenses.where(
              (expense) =>
                  expense.date.year == now.year &&
                  expense.date.month == now.month,
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

                  if (category == null) return const SizedBox();

                  final spentAmount = monthlyCategoryTotals[category.name] ?? 0.0;
                  final budgetAmount = budget.budgetAmount;
                  final progress = (spentAmount / budgetAmount).clamp(0.0, 1.0);
                  bool showWarning = progress >= 0.75;

                  return Padding(
                    padding: EdgeInsets.all(scale.scale(12)),
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: scale.tabletScale(185),
                        maxWidth: scale.tabletScale(195),
                      ),
                      padding: EdgeInsets.all(scale.scale(16)),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(scale.scale(16)),
                        boxShadow: [
                          BoxShadow(
                            color: applyOpacity(Colors.black, 0.3),
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
                              // Category icon and info
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: scale.scale(45),
                                      height: scale.scale(45),
                                      decoration: BoxDecoration(
                                        color: applyOpacity(
                                          category.color,
                                          0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          scale.scale(12),
                                        ),
                                      ),
                                      child: Icon(
                                        category.icon,
                                        color: category.color,
                                      ),
                                    ),
                                    SizedBox(width: scale.scale(12)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category.name.tr,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: scale.scaleText(10),
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          SizedBox(height: scale.scale(2)),
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
                                                            fontSize: scale.scaleText(8),
                                                            color: Colors.grey[400],
                                                          ),
                                                        ),
                                                        Text(
                                                          currency,
                                                          style: TextStyle(
                                                            fontSize: scale.scaleText(8),
                                                            color: Colors.grey[400],
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Text(
                                                      '$currency${getFormattedAmount((budgetAmount / 30), ref)}',
                                                      style: TextStyle(
                                                        fontSize: scale.scaleText(8),
                                                        color: Colors.grey[400],
                                                      ),
                                                    ),
                                              Text(
                                                " per day".tr,
                                                style: TextStyle(
                                                  fontSize: scale.scaleText(8),
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
                              // Delete button
                              SizedBox(
                                width: scale.scale(30),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    Icons.remove_circle,
                                    color: AppColors.accentColor2,
                                    size: scale.scale(15),
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
                                              size: scale.scale(20),
                                            ),
                                            SizedBox(width: scale.scale(6)),
                                            Text(
                                              'Delete Budget'.tr,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: scale.scaleText(14),
                                              ),
                                            ),
                                          ],
                                        ),
                                        content: Text(
                                          'Are you sure you want to delete this budget? This action cannot be undone.'
                                              .tr,
                                          style: TextStyle(
                                            fontSize: scale.scaleText(12),
                                            color: Colors.white,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: Text(
                                              'Cancel'.tr,
                                              style: TextStyle(
                                                color: AppColors.accentColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: scale.scaleText(12),
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              budgetBox.deleteAt(index);
                                              Navigator.of(context).pop();
                                              showFeedbackSnackbar(
                                                context,
                                                'Budget deleted successfully!'.tr,
                                              );
                                            },
                                            child: Text(
                                              'Delete'.tr,
                                              style: TextStyle(
                                                color: AppColors.accentColor2,
                                                fontWeight: FontWeight.bold,
                                                fontSize: scale.scaleText(12),
                                              ),
                                            ),
                                          ),
                                        ],
                                        backgroundColor: cardColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            scale.scale(16),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: scale.scale(8)),
                          LinearProgressIndicator(
                            borderRadius: BorderRadius.circular(12),
                            value: progress,
                            color: showWarning
                                ? AppColors.accentColor2
                                : AppColors.accentColor,
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            minHeight: scale.scale(10),
                          ),
                          SizedBox(height: scale.scale(6)),
                          !isArabic
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$currency${getFormattedAmount(spentAmount, ref)}',
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: scale.scaleText(7),
                                      ),
                                    ),
                                    Text(
                                      "$currency${getFormattedAmount(budgetAmount, ref)}",
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: scale.scaleText(7),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${getFormattedAmount(spentAmount, ref)}$currency',
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: scale.scaleText(7),
                                      ),
                                    ),
                                    Text(
                                      "${getFormattedAmount(budgetAmount, ref)}$currency",
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: scale.scaleText(7),
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