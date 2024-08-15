import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:msib_johan/features/login%20&%20regis/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';
import '../provider/data_provider.dart';

String apiUrl = 'https://msib-6-test-7uaujedvyq-et.a.run.app';

class AuthRepository {
  String loginUrl = '$apiUrl/api/login';
  String registerUrl = '$apiUrl/api/register';

  Future<UserModel> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return UserModel.fromJson(json);
    } else {
      final errorJson = jsonDecode(response.body);
      final errorMessage = errorJson['message'] ?? 'An unknown error occurred';
      return Future.error(errorMessage);
    }
  }

  Future<UserModel> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("$apiUrl/api/register"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": password,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return UserModel.fromJson(json);
    } else {
      final errorJson = jsonDecode(response.body);
      final errorMessage = errorJson['message'] ?? 'An unknown error occurred';
      return Future.error(errorMessage);
    }
  }
}

void logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token');
  await prefs.clear();

  globalToken = '';

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => LoginScreen()),
    (route) => false,
  );
}
