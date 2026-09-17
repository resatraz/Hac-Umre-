import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

const List<Map<String, String>> ezanDriveFiles = [
  {'id': '161Xi34QQ8J7k6MBvApzcsAp0hY1eVA6F', 'name': 'Ezan 1 - Sabah'},
  {'id': '1Ht1UaBHoySEhP779RT3Z8OUY5qP5NJ1U', 'name': 'Ezan 2 - Öğle'},
  {'id': '1KwjCqSdfHF-ZkGuQQgzcMcobXCc-DyLU', 'name': 'Ezan 3 - İkindi'},
  {'id': '1QIJMJscvPbg2Bdlz7GJHRMiSMdZvOVFr', 'name': 'Ezan 4 - Akşam'},
  {'id': '1UbGZ515HI5ziBDsvij0yasXeowO9ZHtw', 'name': 'Ezan 5 - Yatsı'},
  {'id': '1jWpe4qCBfjUO80UCMjyeou8qrd1YZn93', 'name': 'Ezan 6 - Mekke'},
  {'id': '1llMsqpELui4Y9ikJcJcrEKpobS8ADSn8', 'name': 'Ezan 7 - Medine'},
  {'id': '1ueVq0c8tOmyDFnVF_NFBMaTKmc160JAP', 'name': 'Ezan 8 - Hicaz'},
  {'id': '1vI_PqcvdayjGslorkCZ8eau1sC6-PCMD', 'name': 'Ezan 9 - Segah'},
];

String driveDownloadUrl(String id) => 'https://drive.usercontent.google.com/download?id=$id&export=download&authuser=0&confirm=t';
String driveFallbackUrl(String id) => 'https://drive.google.com/uc?export=download&id=$id';

class EzanSesService {
  static final EzanSesService _i = EzanSesService._();
  factory EzanSesService() => _i;
  EzanSesService._();
  final AudioPlayer _player = AudioPlayer();
  final Map<String, double> _progress = {};
  final Set<String> _downloading = {};
  DateTime? _lastClick;

  bool canClick() {
    final now = DateTime.now();
    if (_lastClick != null && now.difference(_lastClick!).inMilliseconds < 800) return false;
    _lastClick = now;
    return true;
  }

  Future<Directory> _dir() async {
    final base = await getApplicationDocumentsDirectory();
    final d = Directory('${base.path}/ezan_sesleri');
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  Future<File> _fileFor(String id) async {
    final dir = await _dir();
    return File('${dir.path}/$id.mp3');
  }

  Future<bool> isDownloaded(String id) async => (await _fileFor(id)).exists();
  double progress(String id) => _progress[id] ?? 0;
  bool isDownloading(String id) => _downloading.contains(id);

  Future<File?> download(String id, {void Function(double)? onProgress}) async {
    if (!canClick()) return null;
    if (_downloading.contains(id)) return null;
    _downloading.add(id);
    _progress[id] = 0;
    try {
      // Önce usercontent, olmazsa fallback
      File? file;
      Exception? lastError;
      for (final url in [driveDownloadUrl(id), driveFallbackUrl(id)]) {
        try {
          file = await _downloadWithUrl(url, id, onProgress);
          break;
        } catch (e) {
          lastError = e is Exception ? e : Exception('$e');
          debugPrint('download $id $url failed $e, trying fallback');
        }
      }
      if (file == null) throw lastError ?? Exception('İndirme başarısız');
      _progress[id] = 1;
      await _kaydetIndirildi(id);
      return file;
    } catch (e) {
      debugPrint('download $id error $e');
      final f = await _fileFor(id);
      if (await f.exists()) await f.delete();
      rethrow;
    } finally {
      _downloading.remove(id);
    }
  }

  Future<File> _downloadWithUrl(String url, String id, void Function(double)? onProgress) async {
    final req = http.Request('GET', Uri.parse(url));
    req.headers['User-Agent'] = 'Mozilla/5.0';
    final streamed = await req.send().timeout(const Duration(seconds: 30));
    if (streamed.statusCode != 200) throw Exception('HTTP ${streamed.statusCode}');
    // Drive bazen text/html döner (virus scan sayfası) — kontrol et
    final contentType = streamed.headers['content-type'] ?? '';
    if (contentType.contains('text/html')) {
      throw Exception('Drive HTML sayfası döndü, dosya büyük olabilir');
    }
    final total = streamed.contentLength ?? 0;
    final file = await _fileFor(id);
    final sink = file.openWrite();
    int received = 0;
    await for (final chunk in streamed.stream) {
      received += chunk.length;
      sink.add(chunk);
      if (total > 0) {
        final p = (received / total).clamp(0.0, 1.0);
        _progress[id] = p;
        onProgress?.call(p);
      } else if (received % 8192 == 0) {
        // bilinmeyen toplamda da ilerleme hissi
        onProgress?.call(0.5);
      }
    }
    await sink.close();
    // Dosya çok küçükse (<10KB) HTML olabilir
    final len = await file.length();
    if (len < 1024 * 10) {
      final head = await file.readAsString();
      if (head.contains('<html') || head.contains('Google Drive')) {
        throw Exception('İndirilen dosya ses değil (HTML)');
      }
    }
    return file;
  }

  Future<void> _kaydetIndirildi(String id) async {
    final p = await SharedPreferences.getInstance();
    final list = p.getStringList('ezan_indirilen') ?? [];
    if (!list.contains(id)) {
      list.add(id);
      await p.setStringList('ezan_indirilen', list);
    }
  }

  Future<void> play(String id, String name) async {
    if (!canClick()) return;
    try {
      final file = await _fileFor(id);
      Source src;
      if (await file.exists()) {
        // İndirilmiş dosya — doğrudan çal, en güvenli
        src = DeviceFileSource(file.path);
        debugPrint('play $id from file ${file.path}');
      } else {
        // Stream — Drive doğrudan, header ile
        final url = driveDownloadUrl(id);
        src = UrlSource(url);
        debugPrint('play $id from url $url');
      }
      await _player.stop();
      // Ses modu
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setVolume(1.0);
      await _player.play(src);
      // Dinleme kaydet
      _player.onPlayerComplete.first.then((_) => kaydetDinleme(id, name));
      Future.delayed(const Duration(seconds: 2), () => kaydetDinleme(id, name));
    } catch (e) {
      debugPrint('play $id error $e');
      rethrow;
    }
  }

  Future<void> stop() async => _player.stop();
  Future<void> pause() async => _player.pause();

  Future<void> kaydetDinleme(String id, String name) async {
    final p = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    final key = 'ezan_dinleme_history';
    final list = p.getStringList(key) ?? [];
    list.insert(0, '$now|$id|$name');
    if (list.length > 100) list.removeRange(100, list.length);
    await p.setStringList(key, list);
    final countKey = 'ezan_dinleme_sayac_$id';
    final c = p.getInt(countKey) ?? 0;
    await p.setInt(countKey, c + 1);
    debugPrint('Dinleme kaydedildi $id $name');
  }

  Future<List<String>> getHistory() async {
    final p = await SharedPreferences.getInstance();
    return p.getStringList('ezan_dinleme_history') ?? [];
  }

  Future<int> getCount(String id) async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('ezan_dinleme_sayac_$id') ?? 0;
  }

  Future<List<String>> getDownloadedIds() async {
    final p = await SharedPreferences.getInstance();
    return p.getStringList('ezan_indirilen') ?? [];
  }

  void dispose() => _player.dispose();
}
