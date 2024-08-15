import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/expense_model.dart';
import '../provider/data_provider.dart';
import 'api_method.dart';

class ExpenseService {
  String getExpensesUrl = "$apiUrl/api/expense";
  String createExpensesdUrl = "$apiUrl/api/wallet";
  String updateExpensesdUrl = "$apiUrl/api/expense";
  String deleteExpensesdUrl = "$apiUrl/api/expense";

  Future<List<ExpenseModel>> getExpenses() async {
    final response = await http.get(
      Uri.parse(getExpensesUrl),
      headers: {
        'Authorization': 'Bearer $globalToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map((json) => ExpenseModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Future<List<ExpenseModel>> getExpensesById(int walletId) async {
    final response = await http.get(
      Uri.parse("$getExpensesUrl/$walletId"),
      headers: {
        'Authorization': 'Bearer $globalToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map((json) => ExpenseModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Future<ExpenseModel> createExpense(
    int walletId,
    String name,
    int categoryId,
    String amount,
    DateTime time,
  ) async {
    final response = await http.post(
      Uri.parse('$createExpensesdUrl/$walletId/expense'),
      headers: {
        'Authorization': 'Bearer $globalToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'category_id': categoryId,
        'amount': "$amount.00",
        'time': time.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json.containsKey('expense')) {
        return ExpenseModel.fromJson(json['expense']);
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      final errorJson = jsonDecode(response.body);
      final errorMessage = errorJson['message'] ?? 'Failed to create expense';
      throw Exception(errorMessage);
    }
  }

  Future<ExpenseModel> updateExpense(
    int walletId,
    int expenseId,
    String name,
    int categoryId,
    String amount,
    DateTime time,
  ) async {
    final response = await http.put(
      Uri.parse('$updateExpensesdUrl/$expenseId'),
      headers: {
        'Authorization': 'Bearer $globalToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'name': name,
        'category_id': categoryId,
        'amount': "$amount.00",
        'time': time.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      // Mengganti status code menjadi 201
      final json = jsonDecode(response.body);
      if (json.containsKey('expense')) {
        return ExpenseModel.fromJson(json['expense']);
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      // Tampilkan detail error jika ada
      final errorJson = jsonDecode(response.body);
      final errorMessage = errorJson['message'] ?? 'Failed to create expense';
      throw Exception(errorMessage);
    }
  }

  Future<void> deleteExpense(int expenseId) async {
    final response = await http.delete(
      Uri.parse('$deleteExpensesdUrl/$expenseId'),
      headers: {
        'Authorization': 'Bearer $globalToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete expense');
    }
  }
}
