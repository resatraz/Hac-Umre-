import 'dart:convert';
import 'package:http/http.dart' as http;
import '../dua_api_service.dart';
import 'dua_adapter.dart';

class HisnAdapter implements DuaAdapter {
  static const _base = 'https://uthumany.github.io/hisn-al-muslim-api/api/v1';
  static const _headers = {'Accept': 'application/json'};

  @override
  Future<List<ApiDua>> fetchAll() async {
    final res = await http.get(Uri.parse('$_base/items.json'), headers: _headers).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) throw Exception('Hisn ${res.statusCode}');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final List items = body['data']?['items'] ?? body['data'] ?? [];
    final List<dynamic> raw = List<dynamic>.from(items);
    return raw.map((e) {
      final m = e as Map<String, dynamic>;
      return ApiDua(
        id: '${m['id']}',
        category: m['chapter_title_en'] ?? 'hisn',
        title: m['title_en'] ?? m['chapter_title_en'] ?? 'Dua ${m['id']}',
        titleTr: '',
        arabic: m['arabic_text'] ?? '',
        transliteration: m['LANGUAGE_ARABIC_TRANSLATED_TEXT']?['raw'] ?? m['transliteration'] ?? '',
        translation: m['english_text'] ?? '',
        translationTr: '',
        source: m['source'] ?? 'Hisn al-Muslim',
        audioUrl: m['audio_url'],
        repeat: 1,
      );
    }).toList();
  }

  @override
  Future<List<String>> fetchCategories() async => [];
}
