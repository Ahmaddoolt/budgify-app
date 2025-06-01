import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/domain/models/expense.dart';
import 'package:budgify/domain/models/wallet.dart';
import 'package:budgify/core/utils/no_data_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/format_amount.dart';

class CategoryExpensesListPage extends ConsumerWidget {
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

  const CategoryExpensesListPage({
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
    final scaleConfig = ScaleConfig(context);
    final screenWidth = MediaQuery.of(context).size.width;
    Color? cardcolor = Theme.of(context).appBarTheme.backgroundColor;

    debugPrint(
      'CategoryExpensesListPage: Rendering with ${expenses.length} expenses',
    );

    if (expenses.isEmpty) {
      debugPrint('No expenses to display');
      return NoDataWidget();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        width: scaleConfig.scale(screenWidth * 0.85), // Responsive width
        margin: EdgeInsets.symmetric(
          horizontal: scaleConfig.scale(screenWidth * 0.05),
        ),
        decoration: BoxDecoration(
          color: cardcolor,
          borderRadius: BorderRadius.circular(scaleConfig.scale(8)),
          border: Border.all(color: cardcolor!.withOpacity(0.3)),
        ),
        child: DataTable(
          showCheckboxColumn: false, // Explicitly disable checkbox
          columnSpacing: scaleConfig.scale(screenWidth * 0.03),
          dataRowHeight: scaleConfig.scale(screenWidth * 0.12),
          headingRowColor: WidgetStateProperty.all(
            AppColors.accentColor.withOpacity(0.2),
          ),
          dataRowColor: WidgetStateProperty.all(cardcolor),
          border: TableBorder(
            horizontalInside: BorderSide(
              color: AppColors.accentColor.withOpacity(0.1),
              width: 1,
            ),
            verticalInside: BorderSide(
              color: AppColors.accentColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          columns: [
            DataColumn(
              label: Text(
                'Title'.tr,
                style: TextStyle(
                  fontSize: scaleConfig.scaleText(10),
                  color: AppColors.textColorDarkTheme,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Amount'.tr,
                style: TextStyle(
                  fontSize: scaleConfig.scaleText(10),
                  color: AppColors.textColorDarkTheme,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Date'.tr,
                style: TextStyle(
                  fontSize: scaleConfig.scaleText(10),
                  color: AppColors.textColorDarkTheme,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Wallet'.tr,
                style: TextStyle(
                  fontSize: scaleConfig.scaleText(10),
                  color: AppColors.textColorDarkTheme,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          rows:
              expenses.map((expense) {
                final wallet = wallets.firstWhere(
                  (wallet) => wallet.id == expense.walletType.id,
                  orElse: () {
                    debugPrint(
                      'No wallet found for ID: ${expense.walletType.id}, using default',
                    );
                    return Wallet(
                      id: 'default',
                      name: 'Default',
                      type: WalletType.cash,
                    );
                  },
                );

                return DataRow(
                  cells: [
                    DataCell(
                      GestureDetector(
                        onTapDown:
                            (details) => _showPopupMenu(
                              context,
                              expense,
                              details.globalPosition,
                            ),
                        child: Row(
                          children: [
                            // Icon(
                            //   iconCategory,
                            //   size: scaleConfig.scale(18),
                            //   color: iconColor,
                            // ),
                            // SizedBox(width: scaleConfig.scale(0)),
                            Text(
                              expense.title,
                              style: TextStyle(
                                fontSize: scaleConfig.scaleText(9),
                                color: AppColors.textColorDarkTheme,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      GestureDetector(
                        onTapDown:
                            (details) => _showPopupMenu(
                              context,
                              expense,
                              details.globalPosition,
                            ),
                        child: Text(
                          getFormattedAmount(expense.amount, ref),
                          style: TextStyle(
                            fontSize: scaleConfig.scaleText(9),
                            color: AppColors.textColorDarkTheme,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      GestureDetector(
                        onTapDown:
                            (details) => _showPopupMenu(
                              context,
                              expense,
                              details.globalPosition,
                            ),
                        child: Text(
                          DateFormat('yyyy-MM-dd').format(expense.date),
                          style: TextStyle(
                            fontSize: scaleConfig.scaleText(9),
                            color: AppColors.textColorDarkTheme,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      GestureDetector(
                        onTapDown:
                            (details) => _showPopupMenu(
                              context,
                              expense,
                              details.globalPosition,
                            ),
                        child: Text(
                          wallet.name,
                          style: TextStyle(
                            fontSize: scaleConfig.scaleText(9),
                            color: AppColors.textColorDarkTheme,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  void _showPopupMenu(BuildContext context, CashFlow expense, Offset position) {
    final scaleConfig = ScaleConfig(context);
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
                size: scaleConfig.scale(16),
              ),
              SizedBox(width: scaleConfig.scale(6)),
              Text(
                'Update'.tr,
                style: TextStyle(
                  color: AppColors.textColorDarkTheme,
                  fontSize: scaleConfig.scaleText(12),
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
                size: scaleConfig.scale(16),
              ),
              SizedBox(width: scaleConfig.scale(6)),
              Text(
                'Delete'.tr,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: scaleConfig.scaleText(12),
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
