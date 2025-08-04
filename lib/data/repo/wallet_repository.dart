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
  Future<void> addWallet(Wallet wallet) async {
    // Using put() with the wallet's ID as the key is more robust
    // than add() as it gives us a predictable key.
    await _walletBox.put(wallet.id, wallet);
  }

  // Update a wallet
  Future<void> updateWallet(Wallet wallet) async {
    // Use put() to update the wallet record using its unique ID.
    // This works even if the 'wallet' object is a copy (e.g., from copyWith).
    await _walletBox.put(wallet.id, wallet);
  }

  // --- NEW METHOD ---
  /// Deletes a wallet directly using its unique ID (the Hive key).
  /// This is called by the WalletNotifier for both deletion scenarios.
  Future<void> deleteWalletById(String walletId) async {
    final wallet = _walletBox.get(walletId);
    if (wallet != null && wallet.isDefault) {
      // This is a safeguard; the UI should prevent this from being called on default wallets.
      throw Exception('Default wallets cannot be deleted.');
    }
    await _walletBox.delete(walletId);
  }

  // Delete a wallet (Kept for compatibility, but new logic uses deleteWalletById)
  @deprecated
  Future<void> deleteWallet(Wallet wallet) async {
    if (wallet.isDefault) {
      throw Exception('Default wallets cannot be deleted.');
    }
    // For consistency, this now calls the new method.
    await deleteWalletById(wallet.id);
  }
}
