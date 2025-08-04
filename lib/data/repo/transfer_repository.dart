// lib/data/repo/transfer_repository.dart

import 'package:budgify/domain/models/transfer%20.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String _transferBoxName = 'transfers';

// Provider to access the repository
final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  return TransferRepository();
});

// Provider for the GLOBAL transfer history list
final transferHistoryProvider = FutureProvider<List<Transfer>>((ref) async {
  final repository = ref.watch(transferRepositoryProvider);
  return repository.getTransfers();
});

// Provider for filtered history for a single wallet
final walletTransfersProvider = FutureProvider.family<List<Transfer>, String>((
  ref,
  walletId,
) async {
  final repository = ref.watch(transferRepositoryProvider);
  return repository.getTransfersForWallet(walletId);
});

class TransferRepository {
  Future<Box<Transfer>> _getBox() async {
    return Hive.openBox<Transfer>(_transferBoxName);
  }

  Future<void> createTransfer(Transfer transfer) async {
    final box = await _getBox();
    await box.put(transfer.id, transfer);
  }

  Future<List<Transfer>> getTransfers() async {
    final box = await _getBox();
    final transfers = box.values.toList();
    transfers.sort((a, b) => b.date.compareTo(a.date));
    return transfers;
  }

  Future<List<Transfer>> getTransfersForWallet(String walletId) async {
    final box = await _getBox();
    final transfers =
        box.values
            .where(
              (t) => t.fromWalletId == walletId || t.toWalletId == walletId,
            )
            .toList();
    transfers.sort((a, b) => b.date.compareTo(a.date));
    return transfers;
  }

  // --- NEW METHOD: To delete a single transfer record ---
  Future<void> deleteTransfer(String transferId) async {
    final box = await _getBox();
    await box.delete(transferId);
  }

  // --- NEW METHOD: To delete all transfer records ---
  Future<void> deleteAllTransfers() async {
    final box = await _getBox();
    await box.clear();
  }
}
