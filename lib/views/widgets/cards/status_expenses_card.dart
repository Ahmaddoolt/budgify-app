import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/viewmodels/providers/lang_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../viewmodels/providers/total_expenses_amount.dart';
import '../../../viewmodels/providers/total_expenses_monthly.dart';
import '../../../viewmodels/providers/total_incomes.dart';
import '../../../viewmodels/providers/total_incomes_monthly.dart';
import '../../../core/utils/format_amount.dart';
import 'package:budgify/views/widgets/cards/progress_row.dart';

class ExpensesCardProgress extends ConsumerWidget {
  final double totalSpendCategory;
  final String categoryType;
  final String? currencySymbol;
  final bool isIncome;
  final bool isMonth;

  const ExpensesCardProgress(
    this.totalSpendCategory,
    this.categoryType,
    this.currencySymbol,
    this.isIncome,
    this.isMonth, {
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaleConfig = ScaleConfig(context); // Use ScaleConfig for responsive sizing
    final language = ref.watch(languageProvider).toString();

    // Calculate total amount based on income/expense and time period
    double totalAmount = 0.0;
    if (isIncome && isMonth) {
      totalAmount = ref.watch(monthlyIncomesAmountProvider);
    } else if (isIncome && !isMonth) {
      totalAmount = ref.watch(totalIncomesAmountProvider);
    } else if (!isIncome && isMonth) {
      totalAmount = ref.watch(monthlyAmountProvider);
    } else {
      totalAmount = ref.watch(totalAmountProvider);
    }

    // Responsive sizing for card
    final cardWidth = scaleConfig.isTablet
        ? scaleConfig.widthPercentage(0.9) // 90% for tablets
        : scaleConfig.widthPercentage(0.92); // 92% for phones
    final cardHeight = scaleConfig.isTablet
        ? scaleConfig.scale(180) // Taller for tablets
        : scaleConfig.scale(162); // Standard height for phones
    final padding = scaleConfig.scale(12);
    final borderRadius = scaleConfig.scale(12);

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
                      fontSize: scaleConfig.scaleText(15),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColorDarkTheme,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  language == 'ar'
                      ? Text(
                          '${getFormattedAmount(totalSpendCategory, ref)} $currencySymbol',
                          style: TextStyle(
                            fontSize: scaleConfig.scaleText(15),
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentColor,
                          ),
                        )
                      : Text(
                          '$currencySymbol ${getFormattedAmount(totalSpendCategory, ref)}',
                          style: TextStyle(
                            fontSize: scaleConfig.scaleText(15),
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentColor,
                          ),
                        ),
                  SizedBox(height: scaleConfig.scale(4)),
                  SizedBox(
                    width: scaleConfig.isTablet
                        ? scaleConfig.scale(200) // Wider for tablets
                        : scaleConfig.scale(164), // Standard for phones
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            categoryType.tr,
                            style: TextStyle(
                              fontSize: scaleConfig.isTablet
                                  ? scaleConfig.scaleText(12.5)
                                  : scaleConfig.scaleText(11.5),
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            getFormattedAmount(totalAmount, ref),
                            style: TextStyle(
                              fontSize: scaleConfig.isTablet
                                  ? scaleConfig.scaleText(12.5)
                                  : scaleConfig.scaleText(11.5),
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ProgressRow(
                    progress: totalAmount > 0
                        ? (totalSpendCategory > totalAmount
                            ? 1
                            : totalSpendCategory / totalAmount)
                        : 0,
                    label: 'Spent',
                    amount: '$currencySymbol ${getFormattedAmount(totalAmount, ref)}',
                    progressColor: AppColors.accentColor2,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Lottie.asset(
                "assets/cash_fly.json",
                width: scaleConfig.scale(91.5),
                height: scaleConfig.scale(91.5),
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}