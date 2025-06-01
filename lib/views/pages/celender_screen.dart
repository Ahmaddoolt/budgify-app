import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/viewmodels/providers/thousands_separator_provider.dart';
import 'package:budgify/core/utils/parrot_animation_waiting.dart';
import 'package:budgify/core/utils/format_amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../domain/models/expense.dart';
import '../../data/repo/expenses_repository.dart';
// import 'package:intl/intl.dart'; // For number formatting

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
    final scaleConfig = ScaleConfig(context);
    final repository = ExpensesRepository();
    final now = DateTime.now();
    final isCurrentMonth = (month == now.month && year == now.year);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final separatorState = ref.watch(separatorProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendar View - ${getShortMonthName(month)}'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: scaleConfig.scaleText(14),
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.format_list_numbered),
        //     onPressed: () {
        //       ref.read(separatorProvider.notifier).toggleSeparator(
        //             !separatorState.isSeparatorEnabled,
        //           );
        //     },
        //     tooltip: 'Toggle number separators',
        //   ),
        // ],
      ),
      body: StreamBuilder<List<CashFlow>>(
        stream: repository.getExpensesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ParrotAnimation();
          }

          final expenses = (snapshot.data ?? [])
              .where((expense) => showIncomes || !expense.isIncome)
              .toList();

          final List<double> dailyIncomes = List.filled(daysInMonth, 0);
          final List<double> dailyExpenses = List.filled(daysInMonth, 0);

          for (var expense in expenses) {
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
            padding: EdgeInsets.all(scaleConfig.scale(10)),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: scaleConfig.scale(6),
                mainAxisSpacing: scaleConfig.scale(16),
                childAspectRatio: scaleConfig.isTablet ? 1.0 : 0.8,
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
                    borderRadius: BorderRadius.circular(scaleConfig.scale(8)),
                    boxShadow: [
                      BoxShadow(
                        color: savings == 0
                            ? Theme.of(context).appBarTheme.backgroundColor!
                            : (savings > 0
                                ? AppColors.accentColor
                                : AppColors.accentColor2),
                        blurRadius: scaleConfig.scale(3),
                        offset: Offset(
                          scaleConfig.scale(3),
                          scaleConfig.scale(3),
                        ),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(scaleConfig.scale(6)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontSize: scaleConfig.scaleText(7),
                          fontWeight: FontWeight.bold,
                          color: isCurrentDay
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      if (showIncomes) ...[
                        SizedBox(height: scaleConfig.scale(2)),
                        _buildRow(
                          context,
                          Icons.arrow_upward, 
                          income, 
                          Colors.green,
                          scaleConfig,
                          separatorState.isSeparatorEnabled,
                          ref
                        ),
                      ],
                      SizedBox(height: scaleConfig.scale(1)),
                      _buildRow(
                        context,
                        Icons.arrow_downward, 
                        expense, 
                        Colors.red,
                        scaleConfig,
                        separatorState.isSeparatorEnabled,
                        ref
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
    ScaleConfig scaleConfig,
    bool useSeparator,
    WidgetRef ref
  ) {
    // final formattedAmount = useSeparator
    //     ? NumberFormat.decimalPattern().format(amount)
    //     : amount.toStringAsFixed(0);

    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              getFormattedAmount(amount, ref),
              style: TextStyle(
                fontSize: scaleConfig.scaleText(6), 
                color: color,
              ),
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
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];

    if (monthNumber < 1 || monthNumber > 12) {
      throw ArgumentError("Month number must be between 1 and 12");
    }

    return monthNames[monthNumber - 1];
  }
}