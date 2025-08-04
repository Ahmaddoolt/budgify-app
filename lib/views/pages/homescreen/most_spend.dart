// lib/views/pages/home_page/most_spend.dart

import 'package:budgify/core/utils/no_data_widget.dart';
import 'package:budgify/core/utils/parrot_animation_waiting.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/data/repo/expenses_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../domain/models/expense.dart';
import '../deatil_cashflow_based_on_category/category_expenses_page.dart';

class HorizontalExpenseList extends ConsumerWidget {
  final bool isIncome;
  // --- THE FIX: Receive both the code for logic and the symbol for display ---
  final String currencyCode;
  final String currencySymbol;

  const HorizontalExpenseList({
    super.key,
    required this.isIncome,
    required this.currencyCode,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // It's better practice to create the repository instance once if possible,
    // but for this fix, we will keep your original structure.
    final expensesRepository = ExpensesRepository();
    final responsive = context.responsive;
    final cardColor = Theme.of(context).cardTheme.color!;

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return StreamBuilder<List<CashFlow>>(
          stream: expensesRepository.getExpensesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ParrotAnimation();
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const NoDataWidget();
            }

            final now = DateTime.now();

            // --- THE FIX: Filter transactions by the unique currencyCode ---
            final filteredExpenses = snapshot.data!.where((expense) {
              return expense.date.month == now.month &&
                  expense.date.year == now.year &&
                  (isIncome ? expense.isIncome : !expense.isIncome) &&
                  expense.currencyCode == currencyCode; // <-- The Correct Logic
            }).toList();

            if (filteredExpenses.isEmpty) {
              return const NoDataWidget();
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

            final sortedCategories = categoryTotals.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.setWidth(15),
                vertical: responsive.setHeight(10),
              ),
              child: SizedBox(
                height: responsive.setHeight(120),
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
                            // --- THE FIX: Pass both code and symbol to the next page ---
                            builder: (_) => CategoryExpensesPage(
                              currencyCode: currencyCode,
                              currencySymbol: currencySymbol,
                              day: now.day,
                              month: now.month,
                              year: now.year,
                              isYear: true,
                              isMonth: true,
                              isDay: false,
                              categoryName: categoryName,
                              iconCategory:
                                  categoryExpenses.first.category.icon,
                              iconColor: categoryExpenses.first.category.color,
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
                                responsive.setWidth(15),
                              ),
                            ),
                            width: responsive.setWidth(80),
                            height: responsive.setHeight(80),
                            margin: EdgeInsets.symmetric(
                              horizontal: responsive.setWidth(8),
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  responsive.setWidth(15),
                                ),
                              ),
                              color: categoryExpenses.first.category.color
                                  .withOpacity(0.015),
                              elevation: 0,
                              child: Center(
                                child: Icon(
                                  categoryExpenses.first.category.icon,
                                  color: categoryExpenses.first.category.color,
                                  size: responsive.setWidth(30),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: responsive.setHeight(10)),
                          Text(
                            categoryName.tr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: responsive.setSp(11),
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
