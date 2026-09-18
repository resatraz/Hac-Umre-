import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class HacUmreSes {
  final String asset;
  final String streamUrl;
  final String kaynak;
  const HacUmreSes({required this.asset, required this.streamUrl, required this.kaynak});
}

// Hisn al-Muslim orijinal insan sesi (ID3 MP3, offline asset + stream fallback)
// ch115 Telbiye, ch116 Tekbir, ch117 Rabbena, ch118 Safa/Merve, ch119 Arafat, ch120 Müzdelife, ch121 Taşlama
const Map<String, HacUmreSes> hacUmreSesleri = {
  'hac_1': HacUmreSes(asset: 'audio/hac_umre/ihram.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/233.mp3', kaynak: 'Hisn al-Muslim 115 • Telbiye'),
  'hac_2': HacUmreSes(asset: 'audio/hac_umre/tavaf.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/235.mp3', kaynak: 'Hisn al-Muslim 117 • Rabbena'),
  'hac_3': HacUmreSes(asset: 'audio/hac_umre/say.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/236.mp3', kaynak: 'Hisn al-Muslim 118 • Safa/Merve'),
  'hac_4': HacUmreSes(asset: 'audio/hac_umre/arafat.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/237.mp3', kaynak: 'Hisn al-Muslim 119 • Arafat'),
  'hac_5': HacUmreSes(asset: 'audio/hac_umre/muzdelife.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/238.mp3', kaynak: 'Hisn al-Muslim 120 • Müzdelife'),
  'hac_6': HacUmreSes(asset: 'audio/hac_umre/mina.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/239.mp3', kaynak: 'Hisn al-Muslim 121 • Taşlama'),
  'hac_7': HacUmreSes(asset: 'audio/hac_umre/tavaf.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/235.mp3', kaynak: 'Hisn al-Muslim 117 • Rabbena'),
  'umre_1': HacUmreSes(asset: 'audio/hac_umre/ihram.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/233.mp3', kaynak: 'Hisn al-Muslim 115 • Telbiye'),
  'umre_2': HacUmreSes(asset: 'audio/hac_umre/tavaf_baslangic.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/234.mp3', kaynak: 'Hisn al-Muslim 116 • Tekbir'),
  'umre_3': HacUmreSes(asset: 'audio/hac_umre/say.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/236.mp3', kaynak: 'Hisn al-Muslim 118 • Safa/Merve'),
};

class HacUmreAudioService {
  static final HacUmreAudioService _i = HacUmreAudioService._();
  factory HacUmreAudioService() => _i;
  HacUmreAudioService._();
  final AudioPlayer _player = AudioPlayer();
  String? _playingKey;
  DateTime? _lastClick;
  VoidCallback? onComplete;

  bool _canClick() {
    final now = DateTime.now();
    if (_lastClick != null && now.difference(_lastClick!).inMilliseconds < 800) return false;
    _lastClick = now;
    return true;
  }

  bool isPlaying(String key) => _playingKey == key;

  Future<bool> toggle(String key, {VoidCallback? onDone}) async {
    if (_playingKey == key) {
      await stop();
      return false;
    }
    await play(key, onDone: onDone);
    return true;
  }

  Future<void> play(String key, {VoidCallback? onDone}) async {
    if (!_canClick() && _playingKey != null) return;
    final ses = hacUmreSesleri[key];
    if (ses == null) return;
    onComplete = onDone;
    _playingKey = key;
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.stop);
      // Önce offline asset (en sağlam), olmazsa API stream
      try {
        await _player.play(AssetSource(ses.asset));
        debugPrint('hac_umre audio asset $key ${ses.asset}');
      } catch (e) {
        debugPrint('asset failed $key $e, stream fallback');
        await _player.play(UrlSource(ses.streamUrl));
      }
      _player.onPlayerComplete.first.then((_) {
        _playingKey = null;
        if (onComplete != null) onComplete!();
      });
    } catch (e) {
      debugPrint('hac_umre play $key error $e');
      _playingKey = null;
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    _playingKey = null;
  }

  void dispose() => _player.dispose();
}
