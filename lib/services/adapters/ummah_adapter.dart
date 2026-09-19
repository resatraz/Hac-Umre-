import 'dart:convert';
import 'package:http/http.dart' as http;
import '../dua_api_service.dart';
import 'dua_adapter.dart';

class UmmahAdapter implements DuaAdapter {
  static const _base = 'https://ummahapi.com/api/duas';
  static const _headers = {'Accept': 'application/json'};

  @override
  Future<List<ApiDua>> fetchAll() async {
    final catRes = await http.get(Uri.parse('$_base/categories'), headers: _headers).timeout(const Duration(seconds: 12));
    if (catRes.statusCode != 200) throw Exception('Ummah categories ${catRes.statusCode}');
    final catBody = jsonDecode(catRes.body) as Map<String, dynamic>;
    final List cats = catBody['data']?['categories'] ?? [];
    if (cats.isEmpty) throw Exception('Kategori yok');
    final List<ApiDua> all = [];
    const batchSize = 5;
    for (int i = 0; i < cats.length; i += batchSize) {
      final batch = cats.sublist(i, (i + batchSize).clamp(0, cats.length));
      final futures = batch.map((c) async {
        final id = (c['id'] ?? c['name']).toString();
        try {
          final r = await http.get(Uri.parse('$_base/category/$id'), headers: _headers).timeout(const Duration(seconds: 10));
          if (r.statusCode != 200) return <ApiDua>[];
          final b = jsonDecode(r.body) as Map<String, dynamic>;
          final List duas = b['data']?['duas'] ?? [];
          return duas.map((e) => ApiDua.fromUmmah(e as Map<String, dynamic>)).toList();
        } catch (_) {
          return <ApiDua>[];
        }
      }).toList();
      final results = await Future.wait(futures);
      for (final r in results) {
        all.addAll(r);
      }
    }
    if (all.isEmpty) throw Exception('Ummah bos');
    return all;
  }

  @override
  Future<List<String>> fetchCategories() async {
    final res = await http.get(Uri.parse('$_base/categories'), headers: _headers).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return [];
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final List cats = body['data']?['categories'] ?? [];
    return cats.map((e) => (e['id'] ?? e['name']).toString()).toList();
  }
}
