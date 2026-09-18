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
  // Ziyaret yerleri (orijinal sesler)
  'ziyaret_kabe': HacUmreSes(asset: 'audio/hac_umre/tavaf_baslangic.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/234.mp3', kaynak: 'Hisn al-Muslim 116 • Tekbir'),
  'ziyaret_hacerulesved': HacUmreSes(asset: 'audio/hac_umre/tavaf_baslangic.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/234.mp3', kaynak: 'Hisn al-Muslim 116 • Tekbir'),
  'ziyaret_makam': HacUmreSes(asset: 'audio/hac_umre/makam.mp3', streamUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/132.mp3', kaynak: 'Bakara 125 • Alafasy'),
  'ziyaret_zemzem': HacUmreSes(asset: 'audio/hac_umre/ilim.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/95.mp3', kaynak: 'Hisn al-Muslim • İlim duası'),
  'ziyaret_safa_merve': HacUmreSes(asset: 'audio/hac_umre/say.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/236.mp3', kaynak: 'Hisn al-Muslim 118 • Safa/Merve'),
  'ziyaret_arafat': HacUmreSes(asset: 'audio/hac_umre/arafat.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/237.mp3', kaynak: 'Hisn al-Muslim 119 • Arafat'),
  'ziyaret_mina': HacUmreSes(asset: 'audio/hac_umre/mina.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/239.mp3', kaynak: 'Hisn al-Muslim 121 • Taşlama'),
  'ziyaret_muzdelife': HacUmreSes(asset: 'audio/hac_umre/muzdelife.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/238.mp3', kaynak: 'Hisn al-Muslim 120 • Müzdelife'),
  'ziyaret_mescidi_nebevi': HacUmreSes(asset: 'audio/hac_umre/mescid.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/20.mp3', kaynak: 'Hisn al-Muslim 13 • Mescid'),
  'ziyaret_ravza': HacUmreSes(asset: 'audio/hac_umre/salavat.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/53.mp3', kaynak: 'Hisn al-Muslim 23 • Salavat'),
  'ziyaret_kubbe_hadra': HacUmreSes(asset: 'audio/hac_umre/kabir.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/165.mp3', kaynak: 'Hisn al-Muslim 60 • Kabir ziyareti'),
  'ziyaret_kuba': HacUmreSes(asset: 'audio/hac_umre/kuba.mp3', streamUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/1343.mp3', kaynak: 'Tevbe 108 • Alafasy'),
  'ziyaret_uhud': HacUmreSes(asset: 'audio/hac_umre/kabir.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/165.mp3', kaynak: 'Hisn al-Muslim 60 • Kabir ziyareti'),
  'ziyaret_kibleteyn': HacUmreSes(asset: 'audio/hac_umre/kibleteyn.mp3', streamUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/151.mp3', kaynak: 'Bakara 144 • Alafasy'),
  // Günlük dualar (orijinal sesler)
  'gunluk_sabah': HacUmreSes(asset: 'audio/hac_umre/sabah.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/89.mp3', kaynak: 'Hisn al-Muslim 27 • Sabah'),
  'gunluk_aksam': HacUmreSes(asset: 'audio/hac_umre/sabah.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/89.mp3', kaynak: 'Hisn al-Muslim 27 • Sabah/Akşam'),
  'gunluk_yemek': HacUmreSes(asset: 'audio/hac_umre/yemek.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/108.mp3', kaynak: 'Hisn al-Muslim • Yemek duası'),
  'gunluk_yolculuk': HacUmreSes(asset: 'audio/hac_umre/yolculuk.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/207.mp3', kaynak: 'Hisn al-Muslim 96 • Yolculuk'),
  'gunluk_uyku': HacUmreSes(asset: 'audio/hac_umre/uyku.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/105.mp3', kaynak: 'Hisn al-Muslim 28 • Uyku'),
  'gunluk_sikinti': HacUmreSes(asset: 'audio/hac_umre/sikinti.mp3', streamUrl: 'http://www.hisnmuslim.com/audio/ar/124.mp3', kaynak: 'Hisn al-Muslim 35 • Sıkıntı'),
};

/// Günlük dua başlığı → ses anahtarı.
String gunlukSesKey(String baslik) {
  if (baslik.contains('Sabah')) return 'gunluk_sabah';
  if (baslik.contains('Akşam')) return 'gunluk_aksam';
  if (baslik.contains('Yemek')) return 'gunluk_yemek';
  if (baslik.contains('Yolculuk')) return 'gunluk_yolculuk';
  if (baslik.contains('Uyku')) return 'gunluk_uyku';
  if (baslik.contains('Sıkıntı')) return 'gunluk_sikinti';
  return 'gunluk_sabah';
}

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
