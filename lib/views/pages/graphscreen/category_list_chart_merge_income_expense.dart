import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/data/repo/expenses_repository.dart';
import 'package:budgify/domain/models/expense.dart';
import 'package:budgify/viewmodels/providers/currency_symbol.dart';
import 'package:budgify/viewmodels/providers/lang_provider.dart';
import 'package:budgify/views/pages/deatil_cashflow_based_on_category/category_expenses_page.dart';
import 'package:budgify/core/utils/format_amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class IncomeExpenseCategoryList extends ConsumerWidget {
  final int month;
  final int year;
  final int day;
  final bool isYear;
  final bool isMonth;
  final bool isDay;

  const IncomeExpenseCategoryList({
    super.key,
    required this.month,
    required this.year,
    required this.day,
    required this.isYear,
    required this.isMonth,
    required this.isDay,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaleConfig = ScaleConfig(context);
    final repository = ExpensesRepository();
    final cardColor =
        Theme.of(context).appBarTheme.backgroundColor ??
        AppColors.secondaryDarkColor;
    final currency = ref.watch(currencyProvider).currencySymbol;

    return StreamBuilder<List<CashFlow>>(
      stream: repository.getExpensesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: SizedBox(height: 10));
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}'.tr,
              style: TextStyle(
                fontSize: scaleConfig.scaleText(16),
                color: Colors.red,
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(height: 10);
        }

        final now = DateTime.now();
        final expenses =
            snapshot.data!.where((expense) {
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
          return SizedBox(height: 10);
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

        final sortedExpenseCategories =
            expenseCategoryTotals.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
        final sortedIncomeCategories =
            incomeCategoryTotals.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

        List<Widget> categoryItems = [];

        categoryItems.add(
          Padding(
            padding: EdgeInsets.only(
              top: scaleConfig.scale(7),
              left: scaleConfig.scale(15.5),
              right: scaleConfig.scale(15.5),
              bottom: scaleConfig.scale(4),
            ),
            child: Text(
              'Expenses'.tr,
              style: TextStyle(
                fontSize: scaleConfig.scaleText(15),
                fontWeight: FontWeight.bold,
                color: AppColors.accentColor2,
              ),
            ),
          ),
        );

        for (var entry in sortedExpenseCategories) {
          final categoryExpense = expenseCategoryDetails[entry.key]!;
          categoryItems.add(
            _buildCategoryItem(
              context,
              categoryExpense,
              entry.key,
              entry.value,
              scaleConfig,
              cardColor,
              currency,
              ref,
              isIncome: false,
            ),
          );
        }

        categoryItems.add(
          Padding(
            padding: EdgeInsets.only(
              top: scaleConfig.scale(16),
              left: scaleConfig.scale(15.5),
              right: scaleConfig.scale(15.5),
              bottom: scaleConfig.scale(4),
            ),
            child: Text(
              'Incomes'.tr,
              style: TextStyle(
                fontSize: scaleConfig.scaleText(15),
                fontWeight: FontWeight.bold,
                color: AppColors.accentColor,
              ),
            ),
          ),
        );

        for (var entry in sortedIncomeCategories) {
          final categoryExpense = incomeCategoryDetails[entry.key]!;
          categoryItems.add(
            _buildCategoryItem(
              context,
              categoryExpense,
              entry.key,
              entry.value,
              scaleConfig,
              cardColor,
              currency,
              ref,
              isIncome: true,
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.symmetric(horizontal: scaleConfig.scale(8)),
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
    ScaleConfig scaleConfig,
    Color cardColor,
    String currency,
    WidgetRef ref, {
    required bool isIncome,
  }) {
    bool isArabic =
        ref.watch(languageProvider).toString() == 'ar' ? true : false;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: scaleConfig.scale(0),
        vertical: scaleConfig.scale(5),
      ),
      child: ListTile(
        leading: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(scaleConfig.scale(15)),
            // border: Border.all(
            //   color: AppColors.accentColor.withOpacity(0.2),
            //   width: scaleConfig.scale(1),
            // ),
          ),
          width: scaleConfig.scale(55),
          height: scaleConfig.scale(55),
          margin: EdgeInsets.symmetric(horizontal: scaleConfig.scale(0)),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(scaleConfig.scale(15)),
            ),
            // ignore: deprecated_member_use
            color: categoryExpense.category.color.withOpacity(0.03),
            elevation: 0,
            child: Center(
              child: Icon(
                categoryExpense.category.icon,
                color: categoryExpense.category.color,
                size: scaleConfig.scale(22),
              ),
            ),
          ),
        ),
        title: Text(
          categoryName.tr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: scaleConfig.scaleText(11),
            color: AppColors.textColorDarkTheme,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing:
            !isArabic
                ? Text(
                  '$currency ${getFormattedAmount(amount, ref)}',
                  style: TextStyle(
                    fontSize: scaleConfig.scaleText(11),
                    color: AppColors.textColorDarkTheme,
                  ),
                )
                : Text(
                  '${getFormattedAmount(amount, ref)} $currency',
                  style: TextStyle(
                    fontSize: scaleConfig.scaleText(11),
                    color: AppColors.textColorDarkTheme,
                  ),
                ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CategoryExpensesPage(
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
