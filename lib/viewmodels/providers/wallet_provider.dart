import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgify/domain/models/wallet.dart';
import 'package:hive/hive.dart';
import '../../data/repo/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final walletBox = Hive.box<Wallet>('wallets');
  return WalletRepository(walletBox);
});

final walletProvider = StateNotifierProvider<WalletNotifier, List<Wallet>>((ref) {
  final repository = ref.watch(walletRepositoryProvider);
  return WalletNotifier(repository);
});

class WalletNotifier extends StateNotifier<List<Wallet>> {
  final WalletRepository _repository;

  WalletNotifier(this._repository) : super(_repository.getWallets()) {
    _initializeWallets();
  }

  Future<void> _initializeWallets() async {
    if (state.isEmpty) {
      final defaultCash = Wallet(
        id: 'cash_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Cash',
        type: WalletType.cash,
        isDefault: true,
      );
      final defaultBank = Wallet(
        id: 'bank_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Bank',
        type: WalletType.bank,
        isDefault: true,
      );
      
      addWallet(defaultCash);
      addWallet(defaultBank);
    }
  }

  void addWallet(Wallet wallet) {
    try {
      _repository.addWallet(wallet);
      state = [...state, wallet];
    } catch (e) {
      throw Exception('Failed to add wallet: $e');
    }
  }

  void updateWallet(Wallet updatedWallet) {
    try {
      _repository.updateWallet(updatedWallet);
      state = [
        for (final wallet in state)
          if (wallet.id == updatedWallet.id) updatedWallet else wallet
      ];
    } catch (e) {
      throw Exception('Failed to update wallet: $e');
    }
  }

  void deleteWallet(Wallet wallet) {
    try {
      _repository.deleteWallet(wallet);
      state = state.where((w) => w.id != wallet.id).toList();
    } catch (e) {
      throw Exception('Failed to delete wallet: $e');
    }
  }
}