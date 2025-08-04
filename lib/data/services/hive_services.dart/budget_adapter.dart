// lib/data/adapters/budget_adapter.dart

import 'package:hive/hive.dart';
import '../../../domain/models/budget.dart';

class BudgetAdapter extends TypeAdapter<Budget> {
  @override
  final int typeId = 2; // IMPORTANT: Ensure this ID is unique in your app.

  @override
  Budget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    // Fallback logic for old data: if currencyCode (field 3) doesn't exist,
    // use the currencySymbol (field 2) as a substitute to prevent crashes.
    final symbol = fields[2] as String? ?? '\$';
    final code =
        fields[3] as String? ?? 'USD'; // Default to USD if code is missing

    return Budget(
      categoryId: fields[0] as String,
      budgetAmount: fields[1] as double,
      currencySymbol: symbol,
      currencyCode: code,
    );
  }

  @override
  void write(BinaryWriter writer, Budget obj) {
    writer
      // --- THE FIX: Increased field count to 4 ---
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.categoryId)
      ..writeByte(1)
      ..write(obj.budgetAmount)
      ..writeByte(2)
      ..write(obj.currencySymbol)
      // --- THE FIX: Write the new currencyCode field ---
      ..writeByte(3)
      ..write(obj.currencyCode);
  }
}
