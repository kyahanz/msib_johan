import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:msib_johan/core/services/api_method.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());
String globalToken = '';

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> login(
      BuildContext context, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user =
          await _ref.watch(authRepositoryProvider).login(email, password);

      // Simpan token ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      globalToken = user.token ?? '';
      await prefs.setString('auth_token', globalToken);

      Navigator.pushReplacementNamed(context, '/homepage');

      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.empty);
    }
  }

  Future<void> register(
      BuildContext context, String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _ref
          .watch(authRepositoryProvider)
          .register(name, email, password);

      // Simpan token ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      globalToken = user.token ?? '';
      await prefs.setString('auth_token', globalToken);

      Navigator.pushReplacementNamed(context, '/login');

      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.empty);
    }
  }
}

Future<void> loadToken() async {
  final prefs = await SharedPreferences.getInstance();
  globalToken = prefs.getString('auth_token') ?? '';
}
