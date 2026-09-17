import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../theme/app_theme.dart';
import '../../services/quran_api_service.dart';

class CuzScreen extends StatefulWidget {
  const CuzScreen({super.key});
  @override
  State<CuzScreen> createState() => _CuzScreenState();
}

class _CuzScreenState extends State<CuzScreen> {
  final _api = QuranApiService();
  final _player = AudioPlayer();
  Hafiz _hafiz = hafizlar.first;
  int _seciliCuz = 30;
  List<QuranAyah> _ayahs = [];
  bool _loading = false;
  String? _error;
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _sirali = true;
  DateTime? _lastClick;
  StreamSubscription? _completeSub;

  @override
  void initState() {
    super.initState();
    _loadKayitli();
    _fetch();
    _completeSub = _player.onPlayerComplete.listen((_) => _nextAuto());
  }

  bool _canClick() {
    final now = DateTime.now();
    if (_lastClick != null && now.difference(_lastClick!).inMilliseconds < 800) return false;
    _lastClick = now;
    return true;
  }

  Future<void> _loadKayitli() async {
    final p = await SharedPreferences.getInstance();
    final cuz = p.getInt('cuz_secili') ?? 30;
    final idx = p.getInt('cuz_idx_$cuz') ?? 0;
    final hafizEdition = p.getString('cuz_hafiz') ?? hafizlar.first.edition;
    final hafiz = hafizlar.firstWhere((h) => h.edition == hafizEdition, orElse: () => hafizlar.first);
    final sirali = p.getBool('cuz_sirali') ?? true;
    if (mounted) setState(() { _seciliCuz = cuz; _currentIndex = idx; _hafiz = hafiz; _sirali = sirali; });
  }

  Future<void> _kaydetSirali(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('cuz_sirali', v);
    setState(() => _sirali = v);
  }

  Future<void> _kaydet() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('cuz_secili', _seciliCuz);
    await p.setInt('cuz_idx_$_seciliCuz', _currentIndex);
    await p.setString('cuz_hafiz', _hafiz.edition);
    await p.setInt('cuz_son_ms', DateTime.now().millisecondsSinceEpoch);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kaydedildi • Cüz $_seciliCuz ayet ${_currentIndex + 1} • ${_hafiz.display}'), backgroundColor: AppTheme.primary));
  }

  Future<void> _fetch() async {
    if (!_canClick() && _ayahs.isNotEmpty) return;
    setState(() { _loading = true; _error = null; });
    try {
      final list = await _api.fetchJuz(_seciliCuz, _hafiz.edition);
      // kayıtlı index clamp
      final p = await SharedPreferences.getInstance();
      final savedIdx = p.getInt('cuz_idx_$_seciliCuz') ?? 0;
      setState(() {
        _ayahs = list;
        _currentIndex = savedIdx.clamp(0, list.isEmpty ? 0 : list.length - 1);
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = '$e'; _loading = false; });
    }
  }

  Future<void> _playAt(int index) async {
    if (!_canClick()) return;
    if (index < 0 || index >= _ayahs.length) return;
    final ayah = _ayahs[index];
    final url = ayah.audio;
    if (url == null || url.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bu ayet için ses yok')));
      return;
    }
    setState(() { _currentIndex = index; _isPlaying = true; });
    await _kaydet();
    try {
      await _player.stop();
      await _player.play(UrlSource(url));
    } catch (e) {
      setState(() => _isPlaying = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Çalma hatası: $e')));
    }
  }

  Future<void> _togglePlay() async {
    if (!_canClick()) return;
    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
      return;
    }
    // devam et
    if (_ayahs.isEmpty) {
      await _fetch();
      return;
    }
    await _playAt(_currentIndex);
  }

  Future<void> _nextAuto() async {
    if (!_sirali) {
      setState(() => _isPlaying = false);
      return;
    }
    if (_currentIndex + 1 < _ayahs.length) {
      await _playAt(_currentIndex + 1);
    } else {
      setState(() => _isPlaying = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cüz $_seciliCuz bitti'), backgroundColor: AppTheme.primary));
    }
  }

  Future<void> _bastanBasla() async {
    if (!_canClick()) return;
    setState(() => _currentIndex = 0);
    await _kaydet();
    await _playAt(0);
  }

  Future<void> _kaldiginYerden() async {
    if (!_canClick()) return;
    final p = await SharedPreferences.getInstance();
    final idx = p.getInt('cuz_idx_$_seciliCuz') ?? _currentIndex;
    final clamped = idx.clamp(0, _ayahs.isEmpty ? 0 : _ayahs.length - 1);
    setState(() => _currentIndex = clamped);
    await _playAt(clamped);
  }

  Future<void> _stop() async {
    if (!_canClick()) return;
    await _player.stop();
    setState(() => _isPlaying = false);
  }

  @override
  void dispose() {
    _completeSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cüz (30 Cüz)'),
        actions: [
          IconButton(icon: const Icon(Icons.bookmark_rounded), tooltip: 'Kaydet', onPressed: _kaydet),
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _fetch),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_rounded, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    const Text('Hafız Seçimi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2))),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _hafiz.edition,
                          isDense: true,
                          style: const TextStyle(fontSize: 12, color: AppTheme.primaryDark, fontWeight: FontWeight.w700),
                          items: hafizlar.map((h) => DropdownMenuItem(value: h.edition, child: Text(h.display))).toList(),
                          onChanged: (v) async {
                            if (v == null) return;
                            setState(() => _hafiz = hafizlar.firstWhere((e) => e.edition == v));
                            await _kaydet();
                            _fetch();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerLeft, child: Text('Cüz seç (1-30) • Kaldığın yerden devam et', style: TextStyle(fontSize: 11, color: Colors.grey.shade600))),
                const SizedBox(height: 6),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 30,
                    separatorBuilder: (_, _) => const SizedBox(width: 6),
                    itemBuilder: (context, i) {
                      final n = i + 1;
                      final sel = n == _seciliCuz;
                      return ChoiceChip(
                        label: Text('$n'),
                        selected: sel,
                        selectedColor: AppTheme.primary,
                        labelStyle: TextStyle(color: sel ? Colors.white : Colors.black87, fontWeight: FontWeight.w700, fontSize: 12),
                        onSelected: (v) {
                          if (!v) return;
                          setState(() => _seciliCuz = n);
                          _fetch();
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 18),
                        label: Text(_isPlaying ? 'Durdur (korumalı)' : 'Oynat', style: const TextStyle(fontSize: 12)),
                        onPressed: _togglePlay,
                        style: ElevatedButton.styleFrom(backgroundColor: _isPlaying ? Colors.orange.shade700 : AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(icon: const Icon(Icons.stop_rounded, size: 16), label: const Text('Durdur', style: TextStyle(fontSize: 12)), onPressed: _stop, style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700)),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(icon: const Icon(Icons.save_rounded, size: 16), label: const Text('Kaydet', style: TextStyle(fontSize: 12)), onPressed: _kaydet),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.history_rounded, size: 14), label: const Text('Kaldığın Yerden', style: TextStyle(fontSize: 11)), onPressed: _kaldiginYerden, style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 8)))),
                    const SizedBox(width: 8),
                    Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.restart_alt_rounded, size: 14), label: const Text('Baştan Başla', style: TextStyle(fontSize: 11)), onPressed: _bastanBasla, style: OutlinedButton.styleFrom(foregroundColor: AppTheme.goldDark))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: _sirali ? AppTheme.primaryLight : Colors.grey.shade100, borderRadius: BorderRadius.circular(20), border: Border.all(color: _sirali ? AppTheme.primary.withValues(alpha: 0.3) : Colors.grey.shade300)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Sıralı', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 4),
                          Switch(value: _sirali, activeThumbColor: AppTheme.primary, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, onChanged: _kaydetSirali),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Sıralı açıkken bir sûre bitince diğeri otomatik başlar • Play/Durdur 800ms korumalı', style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(minHeight: 2, color: AppTheme.primary),
          if (_error != null)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
              child: Column(children: [Text('Hata: $_error', style: const TextStyle(fontSize: 11)), const SizedBox(height: 8), ElevatedButton.icon(icon: const Icon(Icons.refresh_rounded, size: 14), label: const Text('Tekrar Dene', style: TextStyle(fontSize: 11)), onPressed: _fetch)]),
            ),
          if (!_loading && _error == null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: AppTheme.goldLight,
              child: Row(children: [Icon(_isPlaying ? Icons.graphic_eq_rounded : Icons.info_outline_rounded, size: 14, color: _isPlaying ? AppTheme.primary : Colors.grey), const SizedBox(width: 6), Expanded(child: Text(_isPlaying ? 'Cüz $_seciliCuz • ${_hafiz.display} • Ayet ${_currentIndex + 1}/${_ayahs.length} çalıyor • Sıralı ${_sirali ? 'açık' : 'kapalı'}' : 'Cüz $_seciliCuz • ${_ayahs.length} ayet • ${_hafiz.display} • Kaldığın yer: ${_currentIndex + 1} • Sıralı ${_sirali ? 'açık' : 'kapalı'}', style: TextStyle(fontSize: 11, color: _isPlaying ? AppTheme.primaryDark : Colors.grey.shade700, fontWeight: FontWeight.w600))), TextButton(onPressed: _kaydet, child: const Text('Kaydet', style: TextStyle(fontSize: 11)))]),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _ayahs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final a = _ayahs[i];
                      final sel = i == _currentIndex;
                      final playing = sel && _isPlaying;
                      return InkWell(
                        onTap: () => _playAt(i),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: sel ? AppTheme.primaryLight : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: playing ? AppTheme.primary : Colors.grey.shade200), boxShadow: playing ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.12), blurRadius: 8)] : null),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: sel ? AppTheme.primary : Colors.grey.shade100, borderRadius: BorderRadius.circular(20)), child: Text('${a.surahNumber}:${a.numberInSurah}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: sel ? Colors.white : Colors.black87))),
                                  const SizedBox(width: 6),
                                  Expanded(child: Text(a.surahName, style: TextStyle(fontSize: 11, color: Colors.grey.shade600))),
                                  if (playing) const Icon(Icons.graphic_eq_rounded, size: 14, color: AppTheme.primary),
                                  const SizedBox(width: 6),
                                  Icon(playing ? Icons.pause_circle_rounded : Icons.play_circle_rounded, color: AppTheme.primary, size: 22),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(a.text, textAlign: TextAlign.right, style: const TextStyle(fontSize: 18, height: 1.8, color: AppTheme.primaryDark)),
                              const SizedBox(height: 6),
                              Row(children: [Text('Ayet ${a.number} • Cüz ${a.juz}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)), const Spacer(), if (sel) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)), child: const Text('Seçili • Kaydedilir', style: TextStyle(fontSize: 9, color: AppTheme.primary, fontWeight: FontWeight.w700)))]),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
