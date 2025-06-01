import 'package:budgify/views/pages/graphscreen/graph_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';

class NoDataWidget extends StatelessWidget {
  const NoDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = context.scaleConfig;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            "assets/money_s.json",
            width: scale.scale(86.5),
            fit: BoxFit.fill,
          ),
          Text(
            'No Data found.'.tr,
            style: TextStyle(
              fontSize: scale.scaleText(12),
            ),
          ),
          SizedBox(height: scale.scale(8)),
        ],
      ),
    );
  }
}
