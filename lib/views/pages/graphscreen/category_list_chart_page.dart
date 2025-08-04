// lib/views/pages/graphscreen/category_list_chart_page.dart

import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/no_data_widget.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/data/repo/expenses_repository.dart';
import 'package:budgify/domain/models/expense.dart';
import 'package:budgify/viewmodels/providers/lang_provider.dart';
import 'package:budgify/views/pages/deatil_cashflow_based_on_category/category_expenses_page.dart';
import 'package:budgify/core/utils/format_amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class CategoryList extends ConsumerWidget {
  // --- THE FIX: Receive currencyCode for logic ---
  final String currencyCode;
  final int month;
  final int year;
  final int day;
  final bool isYear;
  final bool isMonth;
  final bool isDay;
  final bool isIncome;

  const CategoryList({
    super.key,
    required this.currencyCode,
    required this.month,
    required this.year,
    required this.day,
    required this.isYear,
    required this.isMonth,
    required this.isDay,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = context.responsive;
    final repository = ExpensesRepository();
    final cardColor = Theme.of(context).appBarTheme.backgroundColor ??
        AppColors.secondaryDarkColor;
    bool isArabic = ref.watch(languageProvider).toString() == 'ar';

    return StreamBuilder<List<CashFlow>>(
      stream: repository.getExpensesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox(height: 10));
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}'.tr,
                  style: TextStyle(
                      fontSize: responsive.setSp(16), color: Colors.red)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(height: 10);
        }

        final now = DateTime.now();

        // --- THE FIX: Filter by currencyCode and income/expense type ---
        final expenses = snapshot.data!.where((expense) {
          if (expense.currencyCode != currencyCode) return false;
          if (expense.isIncome != isIncome) return false;

          final expenseDate = expense.date;
          bool yearMatches = isYear ? expenseDate.year == year : true;
          if (!isYear && (isMonth || isDay)) {
            yearMatches = expenseDate.year == now.year;
          }
          bool monthMatches = isMonth ? expenseDate.month == month : true;
          bool dayMatches = isDay ? expenseDate.day == day : true;

          return yearMatches && monthMatches && dayMatches;
        }).toList();

        if (expenses.isEmpty) {
          return const NoDataWidget();
        }

        final Map<String, double> categoryTotals = {};
        final Map<String, CashFlow> categoryDetails = {};

        for (var expense in expenses) {
          final categoryName = expense.category.name;
          categoryTotals[categoryName] =
              (categoryTotals[categoryName] ?? 0) + expense.amount;
          categoryDetails[categoryName] = expense;
        }

        final sortedCategoryTotals = categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        if (sortedCategoryTotals.isEmpty) {
          return const NoDataWidget();
        }

        List<Widget> categoryItems = sortedCategoryTotals.map((entry) {
          final categoryExpense = categoryDetails[entry.key]!;
          // Use the symbol from the transaction itself
          final String currencySymbol = categoryExpense.currencySymbol;

          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: responsive.setWidth(0),
                vertical: responsive.setHeight(5)),
            child: ListTile(
              leading: Container(
                decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius:
                        BorderRadius.circular(responsive.setWidth(12))),
                width: responsive.setWidth(55),
                height: responsive.setHeight(55),
                margin:
                    EdgeInsets.symmetric(horizontal: responsive.setWidth(0)),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(responsive.setWidth(15))),
                  color: categoryExpense.category.color.withOpacity(0.03),
                  elevation: 0,
                  child: Center(
                      child: Icon(categoryExpense.category.icon,
                          color: categoryExpense.category.color,
                          size: responsive.setWidth(22))),
                ),
              ),
              title: Text(
                entry.key.tr,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: responsive.setSp(11),
                    color: AppColors.textColorDarkTheme),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: isArabic
                  ? Text(
                      '${getFormattedAmount(entry.value, ref)} $currencySymbol',
                      style: TextStyle(
                          fontSize: responsive.setSp(11),
                          color: AppColors.textColorDarkTheme))
                  : Text(
                      '$currencySymbol ${getFormattedAmount(entry.value, ref)}',
                      style: TextStyle(
                          fontSize: responsive.setSp(11),
                          color: AppColors.textColorDarkTheme)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryExpensesPage(
                      // --- THE FIX: Pass both code and symbol ---
                      currencyCode: currencyCode,
                      currencySymbol: currencySymbol,
                      categoryName: entry.key,
                      iconCategory: categoryExpense.category.icon,
                      iconColor: categoryExpense.category.color,
                      day: day,
                      month: month,
                      year: year,
                      isYear: isYear,
                      isMonth: isMonth,
                      isDay: isDay,
                      isIncome: isIncome,
                    ),
                  ),
                );
              },
            ),
          );
        }).toList();

        return ListView(
          padding: EdgeInsets.symmetric(horizontal: responsive.setWidth(8)),
          children: categoryItems,
        );
      },
    );
  }
}
