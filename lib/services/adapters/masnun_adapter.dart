import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../dua_api_service.dart';
import 'dua_adapter.dart';

class MasnunAdapter implements DuaAdapter {
  static const _base = 'https://raw.githubusercontent.com/islamicapi/masnun-dua/main/translation/tr';
  static const _headers = {'Accept': 'application/json'};

  @override
  Future<List<ApiDua>> fetchAll() => fetchWithLimit(100);

  Future<List<ApiDua>> fetchWithLimit(int limit) async {
    final List<ApiDua> out = [];
    const batch = 10;
    for (int start = 1; start <= limit; start += batch) {
      final futures = <Future<ApiDua?>>[];
      for (int i = start; i < start + batch && i <= limit; i++) {
        futures.add(_fetchOne(i));
      }
      final results = await Future.wait(futures);
      for (final r in results) {
        if (r != null) out.add(r);
      }
    }
    return out;
  }

  Future<ApiDua?> _fetchOne(int id) async {
    try {
      final url = '$_base/dua_$id.json';
      final res = await http.get(Uri.parse(url), headers: _headers).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      String arabic = (body['arabic'] ?? body['arabic_text'] ?? '').toString();
      return ApiDua.fromMasnunTr(body, arabic);
    } catch (e) {
      debugPrint('masnun $id failed $e');
      return null;
    }
  }

  @override
  Future<List<String>> fetchCategories() async => [];
}
