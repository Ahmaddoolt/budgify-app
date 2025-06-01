import 'package:hive/hive.dart';
import 'package:budgify/domain/models/wallet.dart';

class WalletAdapter extends TypeAdapter<Wallet> {
  @override
  final int typeId = 3; // Unique typeId (must be unique across all adapters)

  @override
  Wallet read(BinaryReader reader) {
    // Read the fields from Hive
    final id = reader.readString();
    final name = reader.readString();
    final typeIndex = reader.readInt();
    final isDefault = reader.readBool();

    // Create and return a Wallet object
    return Wallet(
      id: id,
      name: name,
      type: WalletType.values[typeIndex], // Convert index back to enum
      isDefault: isDefault,
    );
  }

  @override
  void write(BinaryWriter writer, Wallet obj) {
    // Write the fields to Hive
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.type.index); // Convert enum to index
    writer.writeBool(obj.isDefault);
  }
}