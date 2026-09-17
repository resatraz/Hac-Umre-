import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

enum AudioState { idle, playing, paused }

class AppAudioService {
  static final AppAudioService _instance = AppAudioService._internal();
  factory AppAudioService() => _instance;
  AppAudioService._internal();

  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();
  AudioState state = AudioState.idle;
  String? currentId;
  VoidCallback? onComplete;
  bool _ttsReady = false;

  Future<void> init() async {
    try {
      await _tts.setLanguage('ar-SA');
      await _tts.setSpeechRate(0.35);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
      _tts.setCompletionHandler(() {
        state = AudioState.idle;
        currentId = null;
        if (onComplete != null) onComplete!();
      });
      _tts.setCancelHandler(() {
        state = AudioState.idle;
      });
      _tts.setErrorHandler((msg) {
        debugPrint('TTS error: $msg');
        state = AudioState.idle;
      });
      _ttsReady = true;
    } catch (e) {
      debugPrint('TTS init failed: $e');
      _ttsReady = false;
    }
    // audioplayers for click sound
    await _player.setReleaseMode(ReleaseMode.stop);
  }

  Future<bool> speak({required String id, required String arapca, required String okunus, VoidCallback? onDone}) async {
    // if same id is playing -> stop
    if (state == AudioState.playing && currentId == id) {
      await stop();
      return false;
    }
    await stop();
    currentId = id;
    onComplete = onDone;
    state = AudioState.playing;

    if (_ttsReady) {
      try {
        // Önce Arapça, sonra yavaş okunuş için Türkçe
        // Cihazda ar-SA yoksa okunuşu Türkçe okut
        var result = await _tts.speak(arapca);
        if (result != 1) {
          // fallback: okunuşu konuş
          await _tts.setLanguage('tr-TR');
          await _tts.speak(okunus);
          await _tts.setLanguage('ar-SA');
        }
        return true;
      } catch (e) {
        debugPrint('speak failed: $e');
        state = AudioState.idle;
        return false;
      }
    } else {
      // Fallback: kısa bip sesi ile simüle et
      try {
        await _player.play(AssetSource('audio/bip.mp3'));
      } catch (_) {}
      // 2.5 sn sonra otomatik bitir
      Future.delayed(const Duration(milliseconds: 2500), () {
        state = AudioState.idle;
        currentId = null;
        if (onComplete != null) onComplete!();
      });
      return true;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
      await _player.stop();
    } catch (_) {}
    state = AudioState.idle;
    currentId = null;
  }

  Future<void> playClick() async {
    try {
      // Hafif tıklama - sistem sesi yoksa sessiz geç
      await _player.play(AssetSource('audio/click.mp3'));
    } catch (_) {}
  }

  bool isPlaying(String id) => state == AudioState.playing && currentId == id;

  void dispose() {
    _tts.stop();
    _player.dispose();
  }
}
