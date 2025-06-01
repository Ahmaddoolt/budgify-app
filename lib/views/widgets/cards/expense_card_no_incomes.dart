import 'dart:math';
import 'dart:math' as math;
import 'package:budgify/core/utils/scale_config.dart';
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
  final String? currenySympol;

  const BalanceCard({super.key, required this.currenySympol});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = context.scaleConfig;
    final randomIndex = Random().nextInt(_imageNames.length);
    final monthName = DateFormat.MMM().format(DateTime.now());
    final language = ref.watch(languageProvider).toString();
    return StreamBuilder<List<CashFlow>>(
      stream: ExpensesRepository().getExpensesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCardSkeleton(scale);
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final expenses = snapshot.data ?? [];
        final totalExpenses = expenses
            .where((e) => !e.isIncome)
            .fold(0.0, (sum, e) => sum + e.amount);

        return Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(scale.scale(16)),
          ),
          child: Container(
            height: scale.scale(160),
            width: scale.screenWidth * 0.93,
            padding: EdgeInsets.all(scale.scale(16)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // LEFT SIDE
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      language == 'ar'
                          ? Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: scale.scale(14.8),
                              ),
                              SizedBox(width: scale.scale(3)),

                              Text(
                                'Expenses'.tr,
                                style: TextStyle(
                                  fontSize: scale.scaleText(14),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: scale.scale(4)),

                              Text(
                                monthName.tr,
                                style: TextStyle(
                                  fontSize: scale.scaleText(14),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                          : Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: scale.scale(14.8),
                              ),
                              SizedBox(width: scale.scale(3)),
                              Text(
                                monthName.tr,
                                style: TextStyle(
                                  fontSize: scale.scaleText(14),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),

                              SizedBox(width: scale.scale(4)),

                              Text(
                                'Expenses'.tr,
                                style: TextStyle(
                                  fontSize: scale.scaleText(14),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),

                      Text(
                        '$currenySympol ${getFormattedAmount(totalExpenses, ref)}',
                        style: TextStyle(
                          fontSize: scale.scaleText(15.5),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      CustomPaint(
                        size: Size(scale.scale(150), scale.scale(30)),
                        painter: WaveLinePainter(totalExpenses),
                      ),
                    ],
                  ),
                ),

                // RIGHT SIDE
                Expanded(
                  flex: 1,
                  child: Lottie.asset(
                    "assets/${_imageNames[randomIndex]}.json",
                    width: scale.scale(90),
                    height: scale.scale(100),
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

  Widget _buildCardSkeleton(ScaleConfig scale) {
    return Center(
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(scale.scale(16)),
        ),
        child: Container(
          height: scale.scale(170),
          width: scale.screenWidth * 0.93,
          padding: EdgeInsets.all(scale.scale(16)),
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
    Paint paint =
        Paint()
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

      double y =
          size.height / 2 +
          math.sin((i / size.width) * frequency * wavePeriod) * amplitude;
      path.lineTo(i, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
