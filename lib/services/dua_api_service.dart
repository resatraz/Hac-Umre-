import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiDua {
  final String id;
  final String category;
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String translationTr;
  final String source;
  final String? audioUrl;
  final int repeat;

  const ApiDua({
    required this.id,
    required this.category,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.translationTr,
    required this.source,
    this.audioUrl,
    this.repeat = 1,
  });

  factory ApiDua.fromUmmah(Map<String, dynamic> j) {
    return ApiDua(
      id: (j['id'] ?? j['dua_id'] ?? '').toString(),
      category: (j['category'] ?? 'genel').toString(),
      title: (j['title'] ?? j['name'] ?? 'Dua').toString(),
      arabic: (j['arabic'] ?? j['arabic_text'] ?? '').toString(),
      transliteration: (j['transliteration'] ?? j['transliteration_en'] ?? j['latin'] ?? '').toString(),
      translation: (j['translation'] ?? j['english_text'] ?? '').toString(),
      translationTr: (j['translation_tr'] ?? j['translation'] ?? j['english_text'] ?? '').toString(),
      source: (j['source'] ?? j['reference'] ?? 'UmmahAPI').toString(),
      audioUrl: j['audio_url']?.toString() ?? j['audio']?.toString(),
      repeat: int.tryParse('${j['repeat'] ?? 1}') ?? 1,
    );
  }

  factory ApiDua.fromMasnunTr(Map<String, dynamic> j, String fallbackArabic) {
    final tr = j['translation'] ?? j['turkce'] ?? j['text'] ?? '';
    final arabic = j['arabic'] ?? j['arabic_text'] ?? fallbackArabic;
    final translit = j['transliteration'] ?? j['latin'] ?? j['transliteration_en'] ?? '';
    return ApiDua(
      id: (j['dua_id'] ?? j['id'] ?? '').toString(),
      category: (j['category'] ?? 'masnun').toString(),
      title: (j['title'] ?? j['name'] ?? 'Dua').toString(),
      arabic: arabic.toString(),
      transliteration: translit.toString(),
      translation: tr.toString(),
      translationTr: tr.toString(),
      source: (j['source'] ?? 'Masnun Dua').toString(),
      audioUrl: j['audio']?.toString() ?? j['audio_url']?.toString(),
      repeat: 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'title': title,
        'arabic': arabic,
        'transliteration': transliteration,
        'translation': translation,
        'translationTr': translationTr,
        'source': source,
        'audioUrl': audioUrl,
        'repeat': repeat,
      };

  factory ApiDua.fromJson(Map<String, dynamic> j) => ApiDua(
        id: j['id'] ?? '',
        category: j['category'] ?? 'genel',
        title: j['title'] ?? '',
        arabic: j['arabic'] ?? '',
        transliteration: j['transliteration'] ?? '',
        translation: j['translation'] ?? '',
        translationTr: j['translationTr'] ?? j['translation'] ?? '',
        source: j['source'] ?? '',
        audioUrl: j['audioUrl'],
        repeat: j['repeat'] ?? 1,
      );
}

class DuaApiService {
  static const _ummahBase = 'https://ummahapi.com/api/duas';
  static const _hisnBase = 'https://uthumany.github.io/hisn-al-muslim-api/api/v1';
  static const _masnunBase = 'https://raw.githubusercontent.com/islamicapi/masnun-dua/main/translation/tr';
  static const _cacheKey = 'dua_api_cache_v2';
  static const _cacheTimeKey = 'dua_api_cache_time';
  static const _headers = {'Accept': 'application/json'};

  Future<List<ApiDua>> fetchFromUmmah() async {
    final catRes = await http.get(Uri.parse('$_ummahBase/categories'), headers: _headers).timeout(const Duration(seconds: 12));
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
          final r = await http.get(Uri.parse('$_ummahBase/category/$id'), headers: _headers).timeout(const Duration(seconds: 10));
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

  Future<List<ApiDua>> fetchFromHisnStatic() async {
    final res = await http.get(Uri.parse('$_hisnBase/items.json'), headers: _headers).timeout(const Duration(seconds: 12));
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
        arabic: m['arabic_text'] ?? '',
        transliteration: m['LANGUAGE_ARABIC_TRANSLATED_TEXT']?['raw'] ?? m['transliteration'] ?? '',
        translation: m['english_text'] ?? '',
        translationTr: m['english_text'] ?? '',
        source: m['source'] ?? 'Hisn al-Muslim',
        audioUrl: m['audio_url'],
        repeat: 1,
      );
    }).toList();
  }

  Future<List<ApiDua>> fetchFromMasnunTr({int limit = 30}) async {
    final List<ApiDua> out = [];
    const batch = 10;
    for (int start = 1; start <= limit; start += batch) {
      final futures = <Future<ApiDua?>>[];
      for (int i = start; i < start + batch && i <= limit; i++) {
        futures.add(_fetchMasnunOne(i));
      }
      final results = await Future.wait(futures);
      for (final r in results) {
        if (r != null) out.add(r);
      }
    }
    return out;
  }

  Future<ApiDua?> _fetchMasnunOne(int id) async {
    try {
      final url = '$_masnunBase/dua_$id.json';
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

  Future<List<ApiDua>> fetchAllWithFallback() async {
    List<ApiDua> result = [];
    String? lastError;
    try {
      result = await fetchFromUmmah();
      if (result.isNotEmpty) {
        await _saveCache(result);
        return result;
      }
    } catch (e) {
      lastError = 'Ummah: $e';
      debugPrint(lastError);
    }
    try {
      result = await fetchFromMasnunTr(limit: 40);
      if (result.isNotEmpty) {
        await _saveCache(result);
        return result;
      }
    } catch (e) {
      lastError = 'Masnun: $e';
      debugPrint(lastError);
    }
    try {
      result = await fetchFromHisnStatic();
      if (result.isNotEmpty) {
        await _saveCache(result);
        return result;
      }
    } catch (e) {
      lastError = 'Hisn: $e';
      debugPrint(lastError);
    }
    final cached = await loadCache();
    if (cached.isNotEmpty) return cached;
    throw Exception(lastError ?? 'Hicbir kaynaktan dua alinamadi');
  }

  Future<void> _saveCache(List<ApiDua> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_cacheKey, jsonStr);
    await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<List<ApiDua>> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_cacheKey);
    if (str == null) return [];
    try {
      final List decoded = jsonDecode(str) as List;
      return decoded.map((e) => ApiDua.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<DateTime?> cacheTime() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_cacheTimeKey);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<List<String>> fetchCategories() async {
    try {
      final res = await http.get(Uri.parse('$_ummahBase/categories'), headers: _headers).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final List cats = body['data']?['categories'] ?? [];
        return cats.map((e) => (e['id'] ?? e['name']).toString()).toList();
      }
    } catch (_) {}
    return ['hajj', 'morning', 'evening', 'travel', 'food', 'sleep', 'forgiveness', 'protection', 'dhikr', 'after_prayer'];
  }
}
