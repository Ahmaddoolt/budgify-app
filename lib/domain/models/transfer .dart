// lib/domain/models/transfer.dart

import 'package:hive/hive.dart';

class Transfer extends HiveObject {
  final String id;
  final String fromWalletId;
  final String toWalletId;
  final String fromWalletName;
  final String toWalletName;
  final double amountSent;
  final double amountReceived;
  final String fromCurrency;
  final String toCurrency;
  final double exchangeRate;
  final DateTime date;

  Transfer({
    required this.id,
    required this.fromWalletId,
    required this.toWalletId,
    required this.fromWalletName,
    required this.toWalletName,
    required this.amountSent,
    required this.amountReceived,
    required this.fromCurrency,
    required this.toCurrency,
    required this.exchangeRate,
    required this.date,
  });
}