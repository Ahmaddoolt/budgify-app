// lib/domain/models/wallet.dart

import 'package:hive/hive.dart';

// --- HELPER CLASS REQUIRED FOR THE FIX ---
// This simple wrapper class is necessary to fix the `copyWith` method.
// It allows us to tell the difference between "not providing a value"
// and "providing a null value".
class Optional<T> {
  final T value;
  const Optional(this.value);
}

// --- YOUR ENUMS (Unchanged) ---
enum WalletType { cash, bank, digital }

enum WalletFunctionality { income, expense, both }

// --- YOUR WALLET CLASS (with the bug fixed) ---
class Wallet extends HiveObject {
  // Your fields are exactly as you had them.
  String id;
  String name;
  WalletType type;
  bool isDefault;
  double value;
  final String currencyCode;
  final String currencySymbol;
  bool isEnabled;
  WalletFunctionality allowedTransactionType;
  bool isTransferEnabled;
  double? minValue;
  double? maxValue;

  // Your constructor is exactly as you had it.
  Wallet({
    required this.id,
    required this.name,
    required this.type,
    required this.currencyCode,
    required this.currencySymbol,
    this.isDefault = false,
    this.value = 0.0,
    this.isEnabled = true,
    this.allowedTransactionType = WalletFunctionality.both,
    this.isTransferEnabled = true,
    this.minValue,
    this.maxValue,
  });

  /// Creates a complete copy of this Wallet instance.
  /// THIS METHOD IS NOW FIXED to allow `minValue` and `maxValue` to be set to null.
  Wallet copyWith({
    String? name,
    WalletType? type,
    String? currencyCode,
    String? currencySymbol,
    bool? isEnabled,
    WalletFunctionality? allowedTransactionType,
    bool? isTransferEnabled,
    double? value,
    bool? isDefault,
    // --- THE FIX IS HERE ---
    // We now accept the Optional wrapper for the fields that need to be nullable.
    Optional<double?>? minValue,
    Optional<double?>? maxValue,
  }) {
    return Wallet(
      id: this.id, // ID should never change
      name: name ?? this.name,
      type: type ?? this.type,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      isEnabled: isEnabled ?? this.isEnabled,
      allowedTransactionType:
          allowedTransactionType ?? this.allowedTransactionType,
      isTransferEnabled: isTransferEnabled ?? this.isTransferEnabled,
      value: value ?? this.value,
      isDefault: isDefault ?? this.isDefault,

      // --- THE CRITICAL LOGIC CHANGE ---
      // If a `minValue` was passed in the Optional wrapper, use its value (even if it's null).
      // Otherwise, keep the old value from `this.minValue`.
      minValue: minValue != null ? minValue.value : this.minValue,
      maxValue: maxValue != null ? maxValue.value : this.maxValue,
    );
  }
}
