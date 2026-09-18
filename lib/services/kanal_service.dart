import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Kanal {
  final String ad;
  final String kategori;
  final String link;
  const Kanal({required this.ad, required this.kategori, required this.link});

  factory Kanal.fromJson(Map<String, dynamic> j) => Kanal(
        ad: (j['ad'] ?? '').toString(),
        kategori: (j['kategori'] ?? 'Radyo').toString(),
        link: (j['link'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {'ad': ad, 'kategori': kategori, 'link': link};
  factory Kanal.fromCache(Map<String, dynamic> j) => Kanal.fromJson(j);
}

class KanalService {
  static const _url = 'https://raw.githubusercontent.com/resatraz/islami-uygulama-data/main/kanallar.json';
  static const _cacheKey = 'kanallar_cache_v1';

  Future<List<Kanal>> fetchKanallar() async {
    try {
      final res = await http.get(Uri.parse(_url), headers: const {'Accept': 'application/json'}).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
      final List decoded = jsonDecode(utf8.decode(res.bodyBytes)) as List;
      final list = decoded.map((e) => Kanal.fromJson(e as Map<String, dynamic>)).where((k) => k.ad.isNotEmpty && k.link.isNotEmpty).toList();
      if (list.isEmpty) throw Exception('Boş liste');
      await _saveCache(list);
      return list;
    } catch (e) {
      debugPrint('kanal fetch failed $e');
      final cached = await loadCache();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<void> _saveCache(List<Kanal> list) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_cacheKey, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  Future<List<Kanal>> loadCache() async {
    final p = await SharedPreferences.getInstance();
    final str = p.getString(_cacheKey);
    if (str == null) return [];
    try {
      final List decoded = jsonDecode(str) as List;
      return decoded.map((e) => Kanal.fromCache(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
