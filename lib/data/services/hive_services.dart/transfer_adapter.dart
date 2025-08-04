// lib/data/adapters/transfer_adapter.dart

import 'package:budgify/domain/models/transfer%20.dart';
import 'package:hive/hive.dart';

class TransferAdapter extends TypeAdapter<Transfer> {
  @override
  // IMPORTANT: This ID must be unique across your entire app.
  // Since your WalletAdapter is 3, we'll use 4.
  final int typeId = 4; 

  @override
  Transfer read(BinaryReader reader) {
    // We expect 11 fields to be read.
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Transfer(
      id: fields[0] as String,
      fromWalletId: fields[1] as String,
      toWalletId: fields[2] as String,
      fromWalletName: fields[3] as String,
      toWalletName: fields[4] as String,
      amountSent: fields[5] as double,
      amountReceived: fields[6] as double,
      fromCurrency: fields[7] as String,
      toCurrency: fields[8] as String,
      exchangeRate: fields[9] as double,
      date: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Transfer obj) {
    writer
      ..writeByte(11) // Total number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fromWalletId)
      ..writeByte(2)
      ..write(obj.toWalletId)
      ..writeByte(3)
      ..write(obj.fromWalletName)
      ..writeByte(4)
      ..write(obj.toWalletName)
      ..writeByte(5)
      ..write(obj.amountSent)
      ..writeByte(6)
      ..write(obj.amountReceived)
      ..writeByte(7)
      ..write(obj.fromCurrency)
      ..writeByte(8)
      ..write(obj.toCurrency)
      ..writeByte(9)
      ..write(obj.exchangeRate)
      ..writeByte(10)
      ..write(obj.date);
  }
}