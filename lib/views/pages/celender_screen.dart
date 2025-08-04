// UPDATED: Import the necessary providers
import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/viewmodels/providers/currency_symbol.dart';
import 'package:budgify/viewmodels/providers/thousands_separator_provider.dart';
import 'package:budgify/core/utils/parrot_animation_waiting.dart';
import 'package:budgify/core/utils/format_amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../domain/models/expense.dart';
import '../../data/repo/expenses_repository.dart';

class CalendarViewPage extends ConsumerWidget {
  final int month;
  final int year;
  final bool showIncomes;

  const CalendarViewPage({
    super.key,
    required this.month,
    required this.year,
    this.showIncomes = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = context.responsive;
    final repository = ExpensesRepository();
    final now = DateTime.now();
    final isCurrentMonth = (month == now.month && year == now.year);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final separatorState = ref.watch(separatorProvider);

    // THE FIX: Watch the currently selected display currency from the provider.
    final displayCurrency = ref.watch(currencyProvider).displayCurrency;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendar View - ${getShortMonthName(month)}'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: responsive.setSp(14),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: StreamBuilder<List<CashFlow>>(
        stream: repository.getExpensesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ParrotAnimation();
          }

          // THE FIX: Filter the expenses by the selected currency code.
          final allExpenses = snapshot.data ?? [];
          final filteredExpenses = allExpenses.where((expense) {
            final isCorrectCurrency =
                expense.currencyCode == displayCurrency.code;
            final isCorrectType = showIncomes || !expense.isIncome;
            return isCorrectCurrency && isCorrectType;
          }).toList();

          final List<double> dailyIncomes = List.filled(daysInMonth, 0);
          final List<double> dailyExpenses = List.filled(daysInMonth, 0);

          // Now loop through the correctly filtered expenses.
          for (var expense in filteredExpenses) {
            if (expense.date.year == year && expense.date.month == month) {
              final day = expense.date.day - 1;
              if (expense.isIncome) {
                dailyIncomes[day] += expense.amount;
              } else {
                dailyExpenses[day] += expense.amount;
              }
            }
          }

          return Padding(
            padding: EdgeInsets.all(responsive.setWidth(10)),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: responsive.setWidth(6),
                mainAxisSpacing: responsive.setHeight(16),
                childAspectRatio: responsive.isTablet ? 1.0 : 0.8,
              ),
              itemCount: daysInMonth,
              itemBuilder: (context, index) {
                final day = index + 1;
                final income = dailyIncomes[index];
                final expense = dailyExpenses[index];
                final savings = income - expense;

                final isCurrentDay = isCurrentMonth && day == now.day;

                return Container(
                  decoration: BoxDecoration(
                    color: isCurrentDay
                        ? Colors.black
                        : Theme.of(context).appBarTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(responsive.setWidth(8)),
                    boxShadow: [
                      BoxShadow(
                        color: savings == 0
                            ? Theme.of(context).appBarTheme.backgroundColor!
                            : (savings > 0
                                ? AppColors.accentColor
                                : AppColors.accentColor2),
                        blurRadius: responsive.setWidth(3),
                        offset: Offset(
                          responsive.setWidth(3),
                          responsive.setHeight(3),
                        ),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(responsive.setWidth(6)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontSize: responsive.setSp(7),
                          fontWeight: FontWeight.bold,
                          color: isCurrentDay
                              ? Colors.white
                              : Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                        ),
                      ),
                      if (showIncomes) ...[
                        SizedBox(height: responsive.setHeight(2)),
                        _buildRow(
                          context,
                          Icons.arrow_upward,
                          income,
                          Colors.green,
                          responsive,
                          separatorState.isSeparatorEnabled,
                          ref,
                        ),
                      ],
                      SizedBox(height: responsive.setHeight(1)),
                      _buildRow(
                        context,
                        Icons.arrow_downward,
                        expense,
                        Colors.red,
                        responsive,
                        separatorState.isSeparatorEnabled,
                        ref,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    IconData icon,
    double amount,
    Color color,
    ResponsiveUtil responsive,
    bool useSeparator,
    WidgetRef ref,
  ) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              getFormattedAmount(amount, ref),
              style: TextStyle(fontSize: responsive.setSp(6), color: color),
              softWrap: false,
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  String getShortMonthName(int monthNumber) {
    const List<String> monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    if (monthNumber < 1 || monthNumber > 12) {
      throw ArgumentError("Month number must be between 1 and 12");
    }
    return monthNames[monthNumber - 1];
  }
}
