import 'dart:math';
import 'dart:math' as math;
// UPDATED: Import the new responsive utility
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/domain/models/currency.dart';
import 'package:budgify/viewmodels/providers/lang_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/expense.dart';
import '../../../data/repo/expenses_repository.dart';
import '../../../core/utils/format_amount.dart';
import 'package:budgify/core/themes/app_colors.dart';

class BalanceCard extends ConsumerWidget {
  // --- THE FIX: Accept the currency object as a parameter ---
  final Currency currency;

  const BalanceCard({super.key, required this.currency});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = context.responsive;
    final randomIndex = Random().nextInt(_imageNames.length);
    final monthName = DateFormat.MMM().format(DateTime.now());
    final language = ref.watch(languageProvider).toString();

    return StreamBuilder<List<CashFlow>>(
      stream: ExpensesRepository().getExpensesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCardSkeleton(responsive);
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allTransactions = snapshot.data ?? [];

        // --- THE FIX: Filter expenses by the passed currency code ---
        final totalExpenses = allTransactions
            .where((e) => !e.isIncome && e.currencyCode == currency.code)
            .fold(0.0, (sum, e) => sum + e.amount);

        return Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.setWidth(16)),
          ),
          child: Container(
            height: responsive.setHeight(160),
            width: responsive.widthPercent(0.93),
            padding: EdgeInsets.all(responsive.setWidth(16)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      language == 'ar'
                          ? Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    color: Colors.white,
                                    size: responsive.setWidth(14.8)),
                                SizedBox(width: responsive.setWidth(3)),
                                Text('Expenses'.tr,
                                    style: TextStyle(
                                        fontSize: responsive.setSp(14),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                SizedBox(width: responsive.setWidth(4)),
                                Text(monthName.tr,
                                    style: TextStyle(
                                        fontSize: responsive.setSp(14),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ],
                            )
                          : Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    color: Colors.white,
                                    size: responsive.setWidth(14.8)),
                                SizedBox(width: responsive.setWidth(3)),
                                Text(monthName.tr,
                                    style: TextStyle(
                                        fontSize: responsive.setSp(14),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                SizedBox(width: responsive.setWidth(4)),
                                Text('Expenses'.tr,
                                    style: TextStyle(
                                        fontSize: responsive.setSp(14),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ],
                            ),
                      Text(
                        '${currency.symbol} ${getFormattedAmount(totalExpenses, ref)}',
                        style: TextStyle(
                          fontSize: responsive.setSp(15.5),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      CustomPaint(
                        size: Size(
                          responsive.setWidth(150),
                          responsive.setHeight(30),
                        ),
                        painter: WaveLinePainter(totalExpenses),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Lottie.asset(
                    "assets/${_imageNames[randomIndex]}.json",
                    width: responsive.setWidth(90),
                    height: responsive.setHeight(100),
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardSkeleton(ResponsiveUtil responsive) {
    return Center(
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.setWidth(16)),
        ),
        child: Container(
          height: responsive.setHeight(170),
          width: responsive.widthPercent(0.93),
          padding: EdgeInsets.all(responsive.setWidth(16)),
        ),
      ),
    );
  }

  static const List<String> _imageNames = [
    "pppigo",
    "save9",
    "money_s",
    "cash_fly",
    "digital_card",
    "bud_splash",
    "cash_money_wallet",
  ];
}

class WaveLinePainter extends CustomPainter {
  final double totalExpenses;
  WaveLinePainter(this.totalExpenses);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..shader = const LinearGradient(
        colors: [AppColors.accentColor2, Colors.red],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    Path path = Path();
    path.moveTo(0, size.height / 2);
    for (double i = 0; i < size.width; i++) {
      double wavePeriod = 2 * math.pi;
      double amplitude = 10;
      double frequency = 3;
      double y = size.height / 2 +
          math.sin((i / size.width) * frequency * wavePeriod) * amplitude;
      path.lineTo(i, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
