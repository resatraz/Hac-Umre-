import '../../services/dua_api_service.dart';

abstract class DuaAdapter {
  Future<List<ApiDua>> fetchAll();
  Future<List<String>> fetchCategories();
}
