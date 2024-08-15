import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/wallet_model.dart';
import '../services/wallet_service.dart';

final walletServiceProvider = Provider((ref) => WalletService());

final walletProvider =
    StateNotifierProvider<WalletNotifier, AsyncValue<List<WalletModel>>>((ref) {
  return WalletNotifier(ref);
});

class WalletNotifier extends StateNotifier<AsyncValue<List<WalletModel>>> {
  final Ref _ref;

  WalletNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadWallets();
  }

  Future<void> loadWallets() async {
    try {
      final wallets = await _ref.watch(walletServiceProvider).getWallets();
      if (mounted) {
        state = AsyncValue.data(wallets);
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.empty);
      }
    }
  }

  Future<void> createWallet(String name) async {
    try {
      await _ref.watch(walletServiceProvider).createWallet(name);
      if (mounted) {
        loadWallets();
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.empty);
      }
    }
  }

  Future<void> updateWallet(int id, String name) async {
    try {
      await _ref.watch(walletServiceProvider).updateWallet(id, name);
      if (mounted) {
        loadWallets(); // Refresh wallets after update
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.empty);
      }
    }
  }

  Future<void> deleteWallet(int id) async {
    try {
      await _ref.watch(walletServiceProvider).deleteWallet(id);
      if (mounted) {
        loadWallets(); // Refresh wallets after deletion
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.empty);
      }
    }
  }
}
