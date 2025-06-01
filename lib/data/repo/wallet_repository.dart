import 'package:hive/hive.dart';

import '../../domain/models/wallet.dart';

class WalletRepository {
  final Box<Wallet> _walletBox;

  WalletRepository(this._walletBox);

  // Fetch all wallets
  List<Wallet> getWallets() {
    return _walletBox.values.toList();
  }

  // Add a new wallet
  void addWallet(Wallet wallet) {
    _walletBox.add(wallet); // Add wallet to the box
  }

  // Update a wallet
  void updateWallet(Wallet wallet) {
    wallet.save(); // Save changes to the wallet
  }

  // Delete a wallet (prevent deletion of default wallets)
  void deleteWallet(Wallet wallet) {
    if (wallet.isDefault) {
      throw Exception('Default wallets cannot be deleted.');
    }
    wallet.delete(); // Delete the wallet from the box
  }
}