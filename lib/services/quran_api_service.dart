import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;

class QuranAyah {
  final int number;
  final String text;
  final String? audio;
  final int surahNumber;
  final String surahName;
  final int numberInSurah;
  final int juz;

  const QuranAyah({
    required this.number,
    required this.text,
    this.audio,
    required this.surahNumber,
    required this.surahName,
    required this.numberInSurah,
    required this.juz,
  });

  factory QuranAyah.fromJson(Map<String, dynamic> j) {
    return QuranAyah(
      number: j['number'] ?? 0,
      text: j['text'] ?? '',
      audio: j['audio']?.toString(),
      surahNumber: j['surah']?['number'] ?? 0,
      surahName: j['surah']?['name'] ?? j['surah']?['englishName'] ?? '',
      numberInSurah: j['numberInSurah'] ?? 0,
      juz: j['juz'] ?? 0,
    );
  }
}

class Hafiz {
  final String edition;
  final String name;
  final String display;
  const Hafiz({required this.edition, required this.name, required this.display});
}

// Yaygın hafızlar (alquran.cloud audio edition'ları)
const List<Hafiz> hafizlar = [
  Hafiz(edition: 'ar.alafasy', name: 'Mishary Rashid Alafasy', display: 'Alafasy'),
  Hafiz(edition: 'ar.ahmedajamy', name: 'Ahmed Al Ajamy', display: 'Ahmed Ajamy'),
  Hafiz(edition: 'ar.husary', name: 'Mahmoud Khalil Al Husary', display: 'Husary'),
  Hafiz(edition: 'ar.minshawi', name: 'Mohamed Siddiq Al Minshawi', display: 'Minshawi'),
  Hafiz(edition: 'ar.mahermuaiqly', name: 'Maher Al Muaiqly', display: 'Muaiqly'),
  Hafiz(edition: 'ar.abdullahbasfar', name: 'Abdullah Basfar', display: 'Basfar'),
  Hafiz(edition: 'ar.hanirifai', name: 'Hani Ar Rifai', display: 'Rifai'),
  Hafiz(edition: 'ar.hudhaify', name: 'Ali Al Hudhaify', display: 'Hudhaify'),
];

class QuranApiService {
  static const _base = 'https://api.alquran.cloud/v1';
  // dart-define ile override edilebilir, yoksa default
  static const _apiKey = String.fromEnvironment('ALQURAN_API_KEY', defaultValue: '0e80d086e322984557a5e2d3bdef583d');

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'X-API-Key': _apiKey,
        'User-Agent': 'hac_umre_rehberi/1.0 (Flutter)',
      };

  Future<T> _withRetry<T>(Future<T> Function() fn, {int tries = 3}) async {
    Exception? last;
    for (int i = 0; i < tries; i++) {
      try {
        return await fn();
      } catch (e) {
        last = e is Exception ? e : Exception('$e');
        await Future.delayed(Duration(milliseconds: 400 * (i + 1)));
      }
    }
    throw last ?? Exception('Ağ hatası');
  }

  /// Web'de CORS engeline takılmamak için proxy yedeğiyle GET.
  Future<http.Response> _get(Uri uri, {Duration timeout = const Duration(seconds: 30)}) async {
    try {
      return await http.get(uri, headers: _headers).timeout(timeout);
    } catch (e) {
      if (!kIsWeb) rethrow;
      debugPrint('direct failed, proxy fallback $e');
      final proxy = Uri.parse('https://api.allorigins.win/raw?url=${Uri.encodeComponent(uri.toString())}');
      return await http.get(proxy, headers: const {'Accept': 'application/json'}).timeout(timeout);
    }
  }

  // Not: Proje içinde Cüz için ayrı API yok — hepsi Sure tabanlı, harici olarak cüz destekler.
  // Burada /juz/{num}/{edition} kullanıyoruz (alquran.cloud harici cüz desteği).
  Future<List<QuranAyah>> fetchJuz(int juzNumber, String edition) async {
    final clamped = juzNumber.clamp(1, 30);
    final uri = Uri.parse('$_base/juz/$clamped/$edition');
    final res = await _withRetry(() => _get(uri));
    if (res.statusCode != 200) throw Exception('Juz $clamped ${res.statusCode}');
    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final data = body['data'];
    // /juz returns {data: {ayahs: [...]}} bazen {data: {ayahs: []}} veya {data: [...]}
    List ayahs;
    if (data is Map && data['ayahs'] is List) {
      ayahs = data['ayahs'] as List;
    } else if (data is List) {
      ayahs = data;
    } else if (data is Map && data['ayahs'] == null) {
      // Bazı edition'larda data direkt ayahs listesi
      ayahs = [];
    } else {
      ayahs = [];
    }
    if (ayahs.isEmpty) throw Exception('Juz boş');
    return ayahs.map((e) => QuranAyah.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<QuranAyah>> fetchSurah(int surahNumber, String edition) async {
    final uri = Uri.parse('$_base/surah/$surahNumber/$edition');
    final res = await _withRetry(() => _get(uri, timeout: const Duration(seconds: 15)));
    if (res.statusCode != 200) throw Exception('Sure $surahNumber ${res.statusCode}');
    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final List ayahs = body['data']?['ayahs'] ?? [];
    return ayahs.map((e) => QuranAyah.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchSurahList() async {
    final uri = Uri.parse('$_base/surah');
    final res = await _withRetry(() => _get(uri, timeout: const Duration(seconds: 15)));
    if (res.statusCode != 200) throw Exception('Surah list ${res.statusCode}');
    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final List data = body['data'] ?? [];
    return data.map((e) => e as Map<String, dynamic>).toList();
  }
}
