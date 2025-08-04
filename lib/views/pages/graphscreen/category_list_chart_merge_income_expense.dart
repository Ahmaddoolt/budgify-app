// lib/views/pages/graphscreen/category_list_chart_merge_income_expense.dart

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

class IncomeExpenseCategoryList extends ConsumerWidget {
  // --- THE FIX: Receive currencyCode for logic ---
  final String currencyCode;
  final int month;
  final int year;
  final int day;
  final bool isYear;
  final bool isMonth;
  final bool isDay;

  const IncomeExpenseCategoryList({
    super.key,
    required this.currencyCode,
    required this.month,
    required this.year,
    required this.day,
    required this.isYear,
    required this.isMonth,
    required this.isDay,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = context.responsive;
    final repository = ExpensesRepository();
    final cardColor = Theme.of(context).appBarTheme.backgroundColor ??
        AppColors.secondaryDarkColor;

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

        // --- THE FIX: Filter by currencyCode ---
        final expenses = snapshot.data!.where((expense) {
          if (expense.currencyCode != currencyCode) return false;

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
          return const SizedBox(height: 10);
        }

        final Map<String, double> expenseCategoryTotals = {};
        final Map<String, double> incomeCategoryTotals = {};
        final Map<String, CashFlow> expenseCategoryDetails = {};
        final Map<String, CashFlow> incomeCategoryDetails = {};

        for (var expense in expenses) {
          final categoryName = expense.category.name;
          if (expense.isIncome) {
            incomeCategoryTotals[categoryName] =
                (incomeCategoryTotals[categoryName] ?? 0) + expense.amount;
            incomeCategoryDetails[categoryName] = expense;
          } else {
            expenseCategoryTotals[categoryName] =
                (expenseCategoryTotals[categoryName] ?? 0) + expense.amount;
            expenseCategoryDetails[categoryName] = expense;
          }
        }

        final sortedExpenseCategories = expenseCategoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final sortedIncomeCategories = incomeCategoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        List<Widget> categoryItems = [];

        if (sortedExpenseCategories.isNotEmpty) {
          categoryItems.add(
            Padding(
              padding: EdgeInsets.only(
                  top: responsive.setHeight(7),
                  left: responsive.setWidth(15.5),
                  right: responsive.setWidth(15.5),
                  bottom: responsive.setHeight(4)),
              child: Text('Expenses'.tr,
                  style: TextStyle(
                      fontSize: responsive.setSp(15),
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentColor2)),
            ),
          );

          for (var entry in sortedExpenseCategories) {
            final categoryExpense = expenseCategoryDetails[entry.key]!;
            categoryItems.add(
              _buildCategoryItem(context, categoryExpense, entry.key,
                  entry.value, responsive, cardColor, ref,
                  isIncome: false),
            );
          }
        }

        if (sortedIncomeCategories.isNotEmpty) {
          categoryItems.add(
            Padding(
              padding: EdgeInsets.only(
                  top: responsive.setHeight(16),
                  left: responsive.setWidth(15.5),
                  right: responsive.setWidth(15.5),
                  bottom: responsive.setHeight(4)),
              child: Text('Incomes'.tr,
                  style: TextStyle(
                      fontSize: responsive.setSp(15),
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentColor)),
            ),
          );

          for (var entry in sortedIncomeCategories) {
            final categoryExpense = incomeCategoryDetails[entry.key]!;
            categoryItems.add(
              _buildCategoryItem(context, categoryExpense, entry.key,
                  entry.value, responsive, cardColor, ref,
                  isIncome: true),
            );
          }
        }

        if (categoryItems.isEmpty) {
          return const NoDataWidget();
        }

        return ListView(
          padding: EdgeInsets.symmetric(horizontal: responsive.setWidth(8)),
          children: categoryItems,
        );
      },
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    CashFlow categoryExpense,
    String categoryName,
    double amount,
    ResponsiveUtil responsive,
    Color cardColor,
    WidgetRef ref, {
    required bool isIncome,
  }) {
    bool isArabic = ref.watch(languageProvider).toString() == 'ar';
    // Use the symbol from the transaction itself
    final String currencySymbol = categoryExpense.currencySymbol;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.setWidth(0),
        vertical: responsive.setHeight(5),
      ),
      child: ListTile(
        leading: Container(
          decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(responsive.setWidth(15))),
          width: responsive.setWidth(55),
          height: responsive.setHeight(55),
          margin: EdgeInsets.symmetric(horizontal: responsive.setWidth(0)),
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.setWidth(15))),
            color: categoryExpense.category.color.withOpacity(0.03),
            elevation: 0,
            child: Center(
                child: Icon(categoryExpense.category.icon,
                    color: categoryExpense.category.color,
                    size: responsive.setWidth(22))),
          ),
        ),
        title: Text(
          categoryName.tr,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: responsive.setSp(11),
              color: AppColors.textColorDarkTheme),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: !isArabic
            ? Text('$currencySymbol ${getFormattedAmount(amount, ref)}',
                style: TextStyle(
                    fontSize: responsive.setSp(11),
                    color: AppColors.textColorDarkTheme))
            : Text('${getFormattedAmount(amount, ref)} $currencySymbol',
                style: TextStyle(
                    fontSize: responsive.setSp(11),
                    color: AppColors.textColorDarkTheme)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryExpensesPage(
                // --- THE FIX: Pass both code and symbol ---
                currencyCode: categoryExpense.currencyCode,
                currencySymbol: currencySymbol,
                categoryName: categoryName,
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
  }
}
