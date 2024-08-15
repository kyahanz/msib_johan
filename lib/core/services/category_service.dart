import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/category_model.dart';
import '../provider/data_provider.dart';
import 'api_method.dart';

class CategoryService {
  String getCategoriesUrl = "$apiUrl/api/category";

  Future<List<CategoryModel>> getCategories() async {
    final response = await http.get(
      Uri.parse(getCategoriesUrl),
      headers: {
        'Authorization': 'Bearer $globalToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'];
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
}
