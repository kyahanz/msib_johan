import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/expense_model.dart';
import '../services/expense_service.dart';

final expenseServiceProvider = Provider((ref) => ExpenseService());

final expenseProvider =
    StateNotifierProvider<ExpenseNotifier, AsyncValue<List<ExpenseModel>>>(
        (ref) {
  return ExpenseNotifier(ref);
});

class ExpenseNotifier extends StateNotifier<AsyncValue<List<ExpenseModel>>> {
  final Ref _ref;

  ExpenseNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    try {
      final expenses = await _ref.watch(expenseServiceProvider).getExpenses();
      state = AsyncValue.data(expenses);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.empty);
    }
  }

  Future<void> createExpense(int walletId, String name, int categoryId,
      String amount, DateTime time) async {
    try {
      final expense = await _ref
          .watch(expenseServiceProvider)
          .createExpense(walletId, name, categoryId, amount, time);

      final currentExpenses = state.value ?? [];
      state = AsyncValue.data([...currentExpenses, expense]);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.empty);
    }
  }

  Future<void> updateExpense(int walletId, int expenseId, String name,
      int categoryId, String amount, DateTime time) async {
    try {
      await _ref
          .watch(expenseServiceProvider)
          .updateExpense(walletId, expenseId, name, categoryId, amount, time);
      // Reload expenses after updating
      loadExpenses();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.empty);
    }
  }

  Future<void> deleteExpense(int expenseId) async {
    try {
      await _ref.watch(expenseServiceProvider).deleteExpense(expenseId);
      // Reload expenses after deletion
      loadExpenses();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.empty);
    }
  }
}
