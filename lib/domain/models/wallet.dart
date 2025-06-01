import 'package:hive/hive.dart';

class Wallet extends HiveObject {
  String id;
  String name; // Make non-final
  WalletType type; // Make non-final
  bool isDefault;

  Wallet({
    required this.id,
    required this.name,
    required this.type,
    this.isDefault = false,
  });

  // Convert Wallet to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.index, // Store enum as an index
      'isDefault': isDefault,
    };
  }

  // Create Wallet from a Map
  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'],
      name: map['name'],
      type: WalletType.values[map['type']], // Convert index back to enum
      isDefault: map['isDefault'] ?? false,
    );
  }
}

enum WalletType {
  cash,
  bank,
  digital,
}