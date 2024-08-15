import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/wallet_model.dart';
import '../provider/data_provider.dart';
import 'api_method.dart';

class WalletService {
  String getWalletUrl = '$apiUrl/api/wallet';
  String createWalletUrl = '$apiUrl/api/wallet';
  String deleteWalletUrl = '$apiUrl/api/wallet/';
  String updateWalletUrl = '$apiUrl/api/wallet/';

  Future<List<WalletModel>> getWallets() async {
    final response = await http.get(Uri.parse(getWalletUrl), headers: {
      'Authorization': 'Bearer $globalToken',
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map((wallet) => WalletModel.fromJson(wallet)).toList();
    } else {
      throw Exception('Failed to load wallets');
    }
  }

  Future<void> createWallet(String name) async {
    final response = await http.post(
      Uri.parse(createWalletUrl),
      headers: {
        'Authorization': 'Bearer $globalToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: json.encode({'name': name}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create wallet');
    }
  }

  Future<void> updateWallet(int id, String name) async {
    final response = await http.put(
      Uri.parse('$updateWalletUrl$id'),
      headers: {
        'Authorization': 'Bearer $globalToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: json.encode({'name': name}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update wallet');
    }
  }

  Future<void> deleteWallet(int id) async {
    final response = await http.delete(
      Uri.parse('$deleteWalletUrl$id'),
      headers: {
        'Authorization': 'Bearer $globalToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete wallet');
    }
  }
}
