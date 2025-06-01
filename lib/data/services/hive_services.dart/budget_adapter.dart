import 'package:hive/hive.dart';
import '../../../domain/models/budget.dart';

class BudgetAdapter extends TypeAdapter<Budget> {
  @override
  final int typeId = 2; // Unique ID for Budget type.

  @override
  Budget read(BinaryReader reader) {
    final categoryId = reader.readString(); // Read categoryId as String
    final budgetAmount = reader.readDouble(); // Read budgetAmount

    return Budget(
      categoryId: categoryId,
      budgetAmount: budgetAmount,
    );
  }

  @override
  void write(BinaryWriter writer, Budget obj) {
    writer.writeString(obj.categoryId); // Write categoryId as String
    writer.writeDouble(obj.budgetAmount); // Write budgetAmount
  }
}
