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
  final ScrollController _scrollCtrl = ScrollController();
  Hafiz _hafiz = hafizlar.first;
  int _seciliCuz = 30;
  List<QuranAyah> _ayahs = [];
  bool _loading = false;
  String? _error;
  int _currentIndex = 0;
  bool _isPlaying = false;
  final bool _sirali = true;
  DateTime? _lastClick;
  StreamSubscription? _completeSub;
  final List<GlobalKey> _itemKeys = [];

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
    if (mounted) setState(() { _seciliCuz = cuz; _currentIndex = idx; _hafiz = hafiz; });
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
      final p = await SharedPreferences.getInstance();
      final savedIdx = p.getInt('cuz_idx_$_seciliCuz') ?? 0;
      setState(() {
        _ayahs = list;
        _itemKeys.clear();
        _itemKeys.addAll(List.generate(list.length, (_) => GlobalKey()));
        _currentIndex = savedIdx.clamp(0, list.isEmpty ? 0 : list.length - 1);
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent());
    } catch (e) {
      setState(() { _error = '$e'; _loading = false; });
    }
  }

  void _scrollToCurrent() {
    if (_currentIndex < 0 || _currentIndex >= _itemKeys.length) return;
    final key = _itemKeys[_currentIndex];
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, alignment: 0.5, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
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
    _scrollToCurrent();
    try {
      await _player.stop();
      await _player.play(UrlSource(url));
    } catch (e) {
      setState(() => _isPlaying = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Çalma hatası: $e')));
    }
  }

  Future<void> _togglePlayAt(int index) async {
    if (_isPlaying && _currentIndex == index) {
      final ok = await _showDurdurDialog();
      if (!ok) return;
      await _player.pause();
      setState(() => _isPlaying = false);
    } else {
      await _playAt(index);
    }
  }

  Future<bool> _showDurdurDialog() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [Icon(Icons.pause_circle_rounded, color: AppTheme.primary), SizedBox(width: 8), Text('Durdurulsun mu?', style: TextStyle(fontSize: 16))]),
        content: const Text('Dinleme durdurulsun mu? Kaldığınız yer otomatik kaydedilir.', style: TextStyle(fontSize: 13)),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Devam')), FilledButton(onPressed: () => Navigator.pop(context, true), style: FilledButton.styleFrom(backgroundColor: AppTheme.primary), child: const Text('Durdur'))],
      ),
    );
    return res ?? false;
  }

  Future<bool> _showCikisDialog() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [Icon(Icons.exit_to_app_rounded, color: AppTheme.primary), SizedBox(width: 8), Text('Çıkış', style: TextStyle(fontSize: 16))]),
        content: const Text('Uygulamadan çıkmak istiyor musunuz? Dinleme durdurulacak ve yeriniz kaydedilecek.', style: TextStyle(fontSize: 13)),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Kal')), FilledButton(onPressed: () => Navigator.pop(context, true), style: FilledButton.styleFrom(backgroundColor: AppTheme.primary), child: const Text('Çık'))],
      ),
    );
    return res ?? false;
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

  @override
  void dispose() {
    _completeSub?.cancel();
    _player.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final ok = await _showCikisDialog();
        if (!ok) return;
        await _player.stop();
        await _kaydet();
        if (context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cüz (30 Cüz)'),
          actions: [
            IconButton(icon: const Icon(Icons.bookmark_rounded), tooltip: 'Kaydet', onPressed: _kaydet),
            IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _fetch),
          ],
        ),
        body: Column(
          children: [
            // PRO header
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: BoxDecoration(
                gradient: AppTheme.proGradient,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.person_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            const Text('Hafız', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _hafiz.edition,
                                    isDense: true,
                                    isExpanded: true,
                                    style: const TextStyle(fontSize: 11, color: AppTheme.primaryDark, fontWeight: FontWeight.w700, overflow: TextOverflow.ellipsis),
                                    items: hafizlar.map((h) => DropdownMenuItem(value: h.edition, child: Text(h.display, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)))).toList(),
                                    onChanged: (v) async {
                                      if (v == null) return;
                                      setState(() => _hafiz = hafizlar.firstWhere((e) => e.edition == v));
                                      await _kaydet();
                                      _fetch();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.auto_stories_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            const Text('Cüz', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _seciliCuz,
                                    isDense: true,
                                    isExpanded: true,
                                    style: const TextStyle(fontSize: 11, color: AppTheme.primaryDark, fontWeight: FontWeight.w700),
                                    items: List.generate(30, (i) => DropdownMenuItem(value: i + 1, child: Text('Cüz ${i + 1}', style: const TextStyle(fontSize: 11)))),
                                    onChanged: (v) {
                                      if (v == null) return;
                                      setState(() => _seciliCuz = v);
                                      _fetch();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(gradient: AppTheme.goldGradient, borderRadius: BorderRadius.circular(20)),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.workspace_premium_rounded, size: 10, color: Colors.white), SizedBox(width: 3), Text('PRO', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
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
                          selectedColor: Colors.white,
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          labelStyle: TextStyle(color: sel ? AppTheme.primary : Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                          side: BorderSide(color: sel ? Colors.white : Colors.white.withValues(alpha: 0.3)),
                          onSelected: (v) {
                            if (!v) return;
                            setState(() => _seciliCuz = n);
                            _fetch();
                          },
                        );
                      },
                    ),
                  ),
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
                child: Row(children: [
                  Icon(_isPlaying ? Icons.graphic_eq_rounded : Icons.auto_stories_rounded, size: 14, color: _isPlaying ? AppTheme.primary : AppTheme.goldDark),
                  const SizedBox(width: 6),
                  Expanded(child: Text(_isPlaying ? 'Cüz $_seciliCuz • ${_hafiz.display} • Ayet ${_currentIndex + 1}/${_ayahs.length} • Ortada' : 'Cüz $_seciliCuz • ${_ayahs.length} ayet • ${_hafiz.display} • Sıralı otomatik', style: TextStyle(fontSize: 11, color: _isPlaying ? AppTheme.primaryDark : Colors.grey.shade700, fontWeight: FontWeight.w600))),
                  const Icon(Icons.swipe_up_rounded, size: 14, color: AppTheme.goldDark),
                  const SizedBox(width: 4),
                  const Text('Otomatik kayar', style: TextStyle(fontSize: 10, color: AppTheme.goldDark)),
                ]),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(12),
                      itemCount: _ayahs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final a = _ayahs[i];
                        final sel = i == _currentIndex;
                        final playing = sel && _isPlaying;
                        return Container(
                          key: _itemKeys.length > i ? _itemKeys[i] : null,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: sel ? AppTheme.primaryLight : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: playing ? AppTheme.primary : (sel ? AppTheme.gold.withValues(alpha: 0.3) : Colors.grey.shade200), width: playing ? 1.5 : 1),
                            boxShadow: playing ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.15), blurRadius: 10)] : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: sel ? AppTheme.primary : Colors.grey.shade100, borderRadius: BorderRadius.circular(20)), child: Text('${a.surahNumber}:${a.numberInSurah}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: sel ? Colors.white : Colors.black87))),
                                  const SizedBox(width: 6),
                                  Expanded(child: Text(a.surahName, style: TextStyle(fontSize: 11, color: Colors.grey.shade600))),
                                  if (playing) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(20)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.graphic_eq_rounded, size: 10, color: Colors.white), SizedBox(width: 3), Text('Çalıyor', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))])),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(a.text, textAlign: TextAlign.right, style: const TextStyle(fontSize: 19, height: 1.9, color: AppTheme.primaryDark)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text('Ayet ${a.number} • Cüz ${a.juz}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                                  const Spacer(),
                                  // Ayet üzerine Play/Dur
                                  InkWell(
                                    onTap: () => _togglePlayAt(i),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(color: playing ? Colors.red.shade600 : AppTheme.primary, borderRadius: BorderRadius.circular(20)),
                                      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 14, color: Colors.white), const SizedBox(width: 4), Text(playing ? 'Durdur' : 'Oynat', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))]),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
