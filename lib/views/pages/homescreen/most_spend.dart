import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/core/utils/no_data_widget.dart';
import 'package:budgify/core/utils/parrot_animation_waiting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../domain/models/expense.dart';
import '../../../data/repo/expenses_repository.dart';
import '../deatil_cashflow_based_on_category/category_expenses_page.dart';

// Responsive Horizontal Expense List
class HorizontalExpenseList extends ConsumerWidget {
  final bool isIncome;

  const HorizontalExpenseList({super.key, required this.isIncome});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ExpensesRepository();
    final scale = context.scaleConfig;
    final cardColor = Theme.of(context).cardTheme.color!;

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return StreamBuilder<List<CashFlow>>(
          stream: repository.getExpensesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ParrotAnimation();
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return NoDataWidget();
            }

            final now = DateTime.now();
            final filteredExpenses =
                snapshot.data!.where((expense) {
                  return expense.date.month == now.month &&
                      expense.date.year == now.year &&
                      (isIncome ? expense.isIncome : !expense.isIncome);
                }).toList();

            if (filteredExpenses.isEmpty) {
              return NoDataWidget();
            }

            final Map<String, double> categoryTotals = {};
            final Map<String, List<CashFlow>> expensesByCategory = {};

            for (var expense in filteredExpenses) {
              final categoryName = expense.category.name;
              categoryTotals[categoryName] =
                  (categoryTotals[categoryName] ?? 0) + expense.amount;
              expensesByCategory.putIfAbsent(categoryName, () => []);
              expensesByCategory[categoryName]!.add(expense);
            }

            final sortedCategories =
                categoryTotals.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: scale.scale(15),
                vertical: scale.scale(10),
              ),
              child: SizedBox(
                height: scale.scale(120),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: sortedCategories.length,
                  itemBuilder: (context, index) {
                    final categoryName = sortedCategories[index].key;
                    final categoryExpenses = expensesByCategory[categoryName]!;

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => CategoryExpensesPage(
                                  day: now.day,
                                  month: now.month,
                                  year: now.year,
                                  isYear: true,
                                  isMonth: true,
                                  isDay: false,
                                  categoryName: categoryName,
                                  iconCategory:
                                      categoryExpenses.first.category.icon,
                                  iconColor:
                                      categoryExpenses.first.category.color,
                                  isIncome: isIncome,
                                ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(
                                scale.scale(15),
                              ),
                            ),
                            width: scale.scale(80),
                            height: scale.scale(80),
                            margin: EdgeInsets.symmetric(
                              horizontal: scale.scale(8),
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  scale.scale(15),
                                ),
                              ),
                              color: categoryExpenses.first.category.color
                                  .withOpacity(0.015),
                              elevation: 0,
                              child: Center(
                                child: Icon(
                                  categoryExpenses.first.category.icon,
                                  color: categoryExpenses.first.category.color,
                                  size: scale.scale(30),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: scale.scale(10)),
                          Text(
                            categoryName.tr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: scale.scaleText(11),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
