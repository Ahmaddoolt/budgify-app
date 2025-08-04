// lib/views/widgets/cards/status_expenses_card.dart

import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/viewmodels/providers/lang_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../core/utils/format_amount.dart';
import 'package:budgify/views/widgets/cards/progress_row.dart';

class ExpensesCardProgress extends ConsumerWidget {
  // --- THE FIX: Simplified parameters. It now receives all necessary values directly. ---
  final double categoryTotal;
  final double allCategoriesTotal;
  final String categoryName;
  final String currencySymbol;
  final bool isIncome;

  const ExpensesCardProgress({
    super.key,
    required this.categoryTotal,
    required this.allCategoriesTotal,
    required this.categoryName,
    required this.currencySymbol,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = context.responsive;
    final language = ref.watch(languageProvider).toString();

    final cardWidth = responsive.isTablet
        ? responsive.widthPercent(0.9)
        : responsive.widthPercent(0.92);
    final cardHeight = responsive.isTablet
        ? responsive.setHeight(180)
        : responsive.setHeight(162);
    final padding = responsive.setWidth(12);
    final borderRadius = responsive.setWidth(12);

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        height: cardHeight,
        width: cardWidth,
        padding: EdgeInsets.all(padding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isIncome ? "Total Earning".tr : 'Total Spending'.tr,
                    style: TextStyle(
                        fontSize: responsive.setSp(15),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorDarkTheme),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  language == 'ar'
                      ? Text(
                          '${getFormattedAmount(categoryTotal, ref)} $currencySymbol', // Use categoryTotal from params
                          style: TextStyle(
                              fontSize: responsive.setSp(15),
                              fontWeight: FontWeight.bold,
                              color: isIncome
                                  ? AppColors.accentColor
                                  : AppColors.accentColor2),
                        )
                      : Text(
                          '$currencySymbol ${getFormattedAmount(categoryTotal, ref)}', // Use categoryTotal from params
                          style: TextStyle(
                              fontSize: responsive.setSp(15),
                              fontWeight: FontWeight.bold,
                              color: isIncome
                                  ? AppColors.accentColor
                                  : AppColors.accentColor2),
                        ),
                  SizedBox(height: responsive.setHeight(4)),
                  SizedBox(
                    width: responsive.isTablet
                        ? responsive.setWidth(200)
                        : responsive.setWidth(164),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            categoryName.tr,
                            style: TextStyle(
                                fontSize: responsive.isTablet
                                    ? responsive.setSp(12.5)
                                    : responsive.setSp(11.5),
                                color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            getFormattedAmount(allCategoriesTotal,
                                ref), // Use allCategoriesTotal from params
                            style: TextStyle(
                                fontSize: responsive.isTablet
                                    ? responsive.setSp(12.5)
                                    : responsive.setSp(11.5),
                                color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ProgressRow(
                    progress: allCategoriesTotal > 0
                        ? (categoryTotal > allCategoriesTotal
                            ? 1
                            : categoryTotal / allCategoriesTotal)
                        : 0,
                    label: 'Spent',
                    amount:
                        '$currencySymbol ${getFormattedAmount(allCategoriesTotal, ref)}', // Use allCategoriesTotal from params
                    progressColor: isIncome
                        ? AppColors.accentColor
                        : AppColors.accentColor2,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Lottie.asset(
                "assets/cash_fly.json",
                width: responsive.setWidth(91.5),
                height: responsive.setHeight(91.5),
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
