// lib/domain/models/currency.dart
class Currency {
  final String code;   // e.g., "USD"
  final String symbol; // e.g., "$"
  // The 'name' field is removed. The 'code' will be used as the translation key.

  const Currency({
    required this.code,
    required this.symbol,
  });
}