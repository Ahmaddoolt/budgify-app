// import 'category.dart';

import 'package:budgify/domain/models/category.dart';
import 'package:budgify/domain/models/wallet.dart';



class CashFlow {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;
  final String? notes;
  final bool isIncome;
  final Wallet walletType; // New field

  CashFlow({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.notes,
    required this.isIncome,
    required this.walletType, // Initialize new field
  });
}
