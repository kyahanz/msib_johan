import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/category_model.dart';
import '../services/category_service.dart';

final categoryServiceProvider = Provider((ref) => CategoryService());

final categoryProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final service = ref.watch(categoryServiceProvider);
  return service.getCategories();
});
