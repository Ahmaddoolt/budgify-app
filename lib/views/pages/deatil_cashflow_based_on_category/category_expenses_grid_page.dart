// lib/views/pages/deatil_cashflow_based_on_category/widgets_detail_cashflow/category_expenses_grid_page.dart

import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/format_amount.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/domain/models/expense.dart';
import 'package:budgify/domain/models/wallet.dart';
import 'package:budgify/core/utils/no_data_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CategoryExpensesGridPage extends ConsumerWidget {
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
  final List<CashFlow> expenses;
  final List<Wallet> wallets;
  final void Function(CashFlow) onUpdate;
  final void Function(CashFlow) onDelete;

  const CategoryExpensesGridPage({
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
    required this.expenses,
    required this.wallets,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = context.responsive;
    final padding = responsive.widthPercent(0.05);

    debugPrint(
      'CategoryExpensesGridPage: Rendering with ${expenses.length} expenses',
    );

    if (expenses.isEmpty) {
      debugPrint('No expenses to display');
      return const NoDataWidget();
    }

    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: responsive.setHeight(10),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: responsive.isTablet ? 3 : 2,
        crossAxisSpacing: responsive.setWidth(10),
        mainAxisSpacing: responsive.setHeight(10),
        childAspectRatio: 0.85,
      ),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        final wallet = wallets.firstWhere(
          (wallet) => wallet.id == expense.walletType.id,
          orElse: () {
            debugPrint(
              'No wallet found for ID: ${expense.walletType.id}, using default',
            );
            return Wallet(
              id: 'default',
              name: 'Unknown Wallet',
              type: WalletType.cash,
              currencyCode: '???', // Add code for model consistency
              currencySymbol: '?', // Add symbol for model consistency
              isDefault: false,
              isEnabled: false,
              allowedTransactionType: WalletFunctionality.both,
              value: 0.0,
            );
          },
        );
        Color? cardcolor = Theme.of(context).appBarTheme.backgroundColor;
        Color? helpercolor = Theme.of(context).scaffoldBackgroundColor;
        return GestureDetector(
          onTapDown: (details) =>
              _showPopupMenu(context, expense, details.globalPosition),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.setWidth(12)),
            ),
            elevation: 4,
            color: cardcolor,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(responsive.setWidth(12)),
                gradient: LinearGradient(
                  colors: [
                    cardcolor!,
                    cardcolor,
                    cardcolor,
                    cardcolor,
                    cardcolor,
                    helpercolor.withOpacity(0.3),
                    cardcolor,
                    cardcolor,
                    helpercolor.withOpacity(0.3),
                    cardcolor,
                    cardcolor,
                    cardcolor,
                    cardcolor,
                    cardcolor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.all(responsive.setWidth(12)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        iconCategory,
                        size: responsive.setWidth(20),
                        color: iconColor,
                      ),
                      SizedBox(width: responsive.setWidth(8)),
                      Expanded(
                        child: Text(
                          expense.title,
                          style: TextStyle(
                            fontSize: responsive.setSp(13),
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorDarkTheme,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Amount: '.tr,
                        style: TextStyle(fontSize: responsive.setSp(11)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 1),
                      // --- THE FIX: Prepend the expense's own currency symbol ---
                      Text(
                        '${expense.currencySymbol} ${getFormattedAmount(expense.amount, ref)}',
                        style: TextStyle(
                            fontSize: responsive.setSp(11),
                            color: expense.isIncome
                                ? AppColors.accentColor
                                : AppColors.accentColor2),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Date: '.tr,
                        style: TextStyle(fontSize: responsive.setSp(11)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 1),
                      Text(
                        DateFormat('yyyy-MM-dd').format(expense.date),
                        style: TextStyle(fontSize: responsive.setSp(11)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Wallet'.tr,
                        style: TextStyle(
                          fontSize: responsive.setSp(11),
                          color: AppColors.textColorDarkTheme.withOpacity(0.8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        ': ',
                        style: TextStyle(
                          fontSize: responsive.setSp(11),
                          color: AppColors.textColorDarkTheme.withOpacity(0.8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 1),
                      Text(
                        wallet.name,
                        style: TextStyle(fontSize: responsive.setSp(11)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  if (expense.notes != null && expense.notes!.isNotEmpty)
                    Row(
                      children: [
                        Text(
                          'Note: '.tr,
                          style: TextStyle(fontSize: responsive.setSp(11)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 1),
                        Expanded(
                          child: Text(
                            '${expense.notes}',
                            style: TextStyle(fontSize: responsive.setSp(11)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPopupMenu(BuildContext context, CashFlow expense, Offset position) {
    final responsive = context.responsive;
    Color? cardcolor = Theme.of(context).appBarTheme.backgroundColor;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        MediaQuery.of(context).size.width - position.dx,
        MediaQuery.of(context).size.height - position.dy,
      ),
      color: cardcolor,
      items: [
        PopupMenuItem<String>(
          value: 'Update',
          child: Row(
            children: [
              Icon(
                Icons.edit,
                color: AppColors.accentColor,
                size: responsive.setWidth(16),
              ),
              SizedBox(width: responsive.setWidth(6)),
              Text(
                'Update'.tr,
                style: TextStyle(
                  color: AppColors.textColorDarkTheme,
                  fontSize: responsive.setSp(12),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'Delete',
          child: Row(
            children: [
              Icon(
                Icons.delete,
                color: Colors.red,
                size: responsive.setWidth(16),
              ),
              SizedBox(width: responsive.setWidth(6)),
              Text(
                'Delete'.tr,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: responsive.setSp(12),
                ),
              ),
            ],
          ),
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value == 'Update') {
        onUpdate(expense);
      } else if (value == 'Delete') {
        onDelete(expense);
      }
    });
  }
}
