import 'dart:convert';
import 'package:http/http.dart' as http;

class DiyanetService {
  static const _base = 'https://acikkaynakkuran-dev.diyanet.gov.tr';
  static const _apiKey = String.fromEnvironment('DIYANET_API_KEY', defaultValue: '1456|nbVoLeUyO0xKIGjhyFDjVC7HW2bK2BTAmZzAfupYa493b0cb');

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      };

  // Sure listesi — sınır yok
  Future<List<dynamic>> fetchSureList() async {
    final uri = Uri.parse('$_base/sure');
    final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) throw Exception('Diyanet sure ${res.statusCode}');
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    if (body is List) return body;
    if (body is Map && body['data'] is List) return body['data'];
    return [];
  }

  // Sayfa bazlı ayet — ilk 30 sayfa sınırlı (dev key)
  Future<List<dynamic>> fetchSayfa(int sayfaNo) async {
    final uri = Uri.parse('$_base/sayfa/$sayfaNo');
    final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) throw Exception('Sayfa $sayfaNo ${res.statusCode}');
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    if (body is List) return body;
    if (body is Map && body['data'] is List) return body['data'];
    return [];
  }

  // Cüz — sadece 1. cüz (dev key sınırlı)
  Future<List<dynamic>> fetchCuz(int cuzNo) async {
    final uri = Uri.parse('$_base/cuz/$cuzNo');
    final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) throw Exception('Cüz $cuzNo ${res.statusCode}');
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    if (body is List) return body;
    if (body is Map && body['data'] is List) return body['data'];
    return [];
  }
}
