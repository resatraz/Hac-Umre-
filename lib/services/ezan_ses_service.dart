import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

// Google Drive dosya ID'leri (kullanıcının verdiği 9 link)
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

String driveDownloadUrl(String id) => 'https://drive.google.com/uc?export=download&id=$id';

class EzanSesService {
  static final EzanSesService _i = EzanSesService._();
  factory EzanSesService() => _i;
  EzanSesService._();
  final AudioPlayer _player = AudioPlayer();
  final Map<String, double> _progress = {};
  final Set<String> _downloading = {};
  DateTime? _lastClick;

  // Tıklama koruması: 800ms içinde tekrar tıklamayı engelle
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
      final url = driveDownloadUrl(id);
      final req = http.Request('GET', Uri.parse(url));
      req.headers['User-Agent'] = 'Mozilla/5.0';
      final streamed = await req.send().timeout(const Duration(seconds: 30));
      if (streamed.statusCode != 200) throw Exception('HTTP ${streamed.statusCode}');
      final total = streamed.contentLength ?? 0;
      final file = await _fileFor(id);
      final sink = file.openWrite();
      int received = 0;
      await for (final chunk in streamed.stream) {
        received += chunk.length;
        sink.add(chunk);
        if (total > 0) {
          final p = received / total;
          _progress[id] = p;
          onProgress?.call(p);
        }
      }
      await sink.close();
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
        src = DeviceFileSource(file.path);
      } else {
        // İndirilmemişse stream et (Drive doğrudan çalma)
        src = UrlSource(driveDownloadUrl(id));
      }
      await _player.stop();
      await _player.play(src);
      // Dinleme kaydet (başarılı play sonrası)
      _player.onPlayerComplete.first.then((_) => kaydetDinleme(id, name));
      // Veya 2 sn sonra kaydet (stream için)
      Future.delayed(const Duration(seconds: 2), () => kaydetDinleme(id, name));
    } catch (e) {
      debugPrint('play $id error $e');
      rethrow;
    }
  }

  Future<void> stop() async => _player.stop();
  Future<void> pause() async => _player.pause();

  // Ses dinleme kaydet: SharedPreferences list JSON
  Future<void> kaydetDinleme(String id, String name) async {
    final p = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    final key = 'ezan_dinleme_history';
    final list = p.getStringList(key) ?? [];
    // son 100 kayıt
    list.insert(0, '$now|$id|$name');
    if (list.length > 100) list.removeRange(100, list.length);
    await p.setStringList(key, list);
    // sayac
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
