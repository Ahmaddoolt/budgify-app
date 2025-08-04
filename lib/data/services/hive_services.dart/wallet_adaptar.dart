// lib/data/adapters/wallet_adapter.dart

import 'package:hive/hive.dart';
import 'package:budgify/domain/models/wallet.dart';

class WalletAdapter extends TypeAdapter<Wallet> {
  @override
  final int typeId = 3; // Must be unique

  @override
  Wallet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Wallet(
      id: fields[0] as String,
      name: fields[1] as String,
      type: WalletType.values[fields[2] as int],
      isDefault: fields[3] as bool,
      value: fields[4] as double? ?? 0.0,

      // --- THE FIX: Read currencyCode with a fallback for old data ---
      // For old wallets that only had a symbol, we will default the code to the symbol.
      // This is not perfect but prevents crashes. New wallets will be correct.
      currencyCode: fields[11] as String? ?? fields[5] as String? ?? 'USD',
      currencySymbol: fields[5] as String? ?? '\$',

      isEnabled: fields[6] as bool? ?? true,
      allowedTransactionType: WalletFunctionality
          .values[fields[7] as int? ?? WalletFunctionality.both.index],
      isTransferEnabled: fields[8] as bool? ?? true,
      minValue: fields[9] as double?,
      maxValue: fields[10] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Wallet obj) {
    writer
      // --- THE FIX: Increased field count to 12 ---
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type.index)
      ..writeByte(3)
      ..write(obj.isDefault)
      ..writeByte(4)
      ..write(obj.value)
      ..writeByte(5)
      ..write(obj.currencySymbol)
      ..writeByte(6)
      ..write(obj.isEnabled)
      ..writeByte(7)
      ..write(obj.allowedTransactionType.index)
      ..writeByte(8)
      ..write(obj.isTransferEnabled)
      ..writeByte(9)
      ..write(obj.minValue)
      ..writeByte(10)
      ..write(obj.maxValue)
      // --- THE FIX: Write the new currencyCode field ---
      ..writeByte(11)
      ..write(obj.currencyCode);
  }
}
