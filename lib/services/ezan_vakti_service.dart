import 'dart:convert';
import 'package:http/http.dart' as http;

class VakitGun {
  final String hicriKisa;
  final String hicriUzun;
  final String miladiKisa;
  final String miladiUzun;
  final String imsak;
  final String gunes;
  final String ogle;
  final String ikindi;
  final String aksam;
  final String yatsi;

  const VakitGun({
    required this.hicriKisa,
    required this.hicriUzun,
    required this.miladiKisa,
    required this.miladiUzun,
    required this.imsak,
    required this.gunes,
    required this.ogle,
    required this.ikindi,
    required this.aksam,
    required this.yatsi,
  });

  factory VakitGun.fromJson(Map<String, dynamic> j) => VakitGun(
        hicriKisa: j['HicriTarihKisa'] ?? '',
        hicriUzun: j['HicriTarihUzun'] ?? '',
        miladiKisa: j['MiladiTarihKisa'] ?? '',
        miladiUzun: j['MiladiTarihUzun'] ?? '',
        imsak: j['Imsak'] ?? '',
        gunes: j['Gunes'] ?? '',
        ogle: j['Ogle'] ?? '',
        ikindi: j['Ikindi'] ?? '',
        aksam: j['Aksam'] ?? '',
        yatsi: j['Yatsi'] ?? '',
      );
}

class EzanVaktiService {
  static const _base = 'https://ezanvakti.emushaf.net';
  static const _headers = {'Accept': 'application/json'};

  static const int mekkaId = 16309;
  static const int medineId = 16308;

  Future<List<VakitGun>> fetchVakitler(int ilceId) async {
    final uri = Uri.parse('$_base/vakitler/$ilceId');
    final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) throw Exception('Vakit ${res.statusCode}');
    final List decoded = jsonDecode(res.body) as List;
    return decoded.map((e) => VakitGun.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<VakitGun> fetchBugun(int ilceId) async {
    final list = await fetchVakitler(ilceId);
    if (list.isEmpty) throw Exception('Boş liste');
    // Bugünün tarihine en yakın olanı bul, yoksa ilk
    final now = DateTime.now();
    final todayStr = '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
    final found = list.where((v) => v.miladiKisa == todayStr).toList();
    if (found.isNotEmpty) return found.first;
    return list.first;
  }
}
