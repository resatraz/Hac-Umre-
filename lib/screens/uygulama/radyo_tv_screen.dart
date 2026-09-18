import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import '../../theme/app_theme.dart';
import '../../services/kanal_service.dart';

class RadyoTvScreen extends StatefulWidget {
  const RadyoTvScreen({super.key});
  @override
  State<RadyoTvScreen> createState() => _RadyoTvScreenState();
}

class _RadyoTvScreenState extends State<RadyoTvScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _service = KanalService();
  final _audio = AudioPlayer();
  late Future<List<Kanal>> _future;
  Kanal? _seciliRadyo;
  Kanal? _seciliTv;
  bool _radyoLoading = false;
  bool _radyoPlaying = false;
  List<Kanal> _sonRadyolar = [];
  VideoPlayerController? _videoCtrl;
  bool _videoLoading = false;
  DateTime? _lastClick;
  StreamSubscription? _audioCompleteSub;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _future = _service.fetchKanallar();
    _audioCompleteSub = _audio.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _radyoPlaying = false);
    });
  }

  bool _canClick() {
    final now = DateTime.now();
    if (_lastClick != null && now.difference(_lastClick!).inMilliseconds < 800) return false;
    _lastClick = now;
    return true;
  }

  Future<void> _playRadyo(Kanal k, [List<Kanal>? liste]) async {
    if (!_canClick()) return;
    // Aynı kanal çalıyorsa durdur
    if (_radyoPlaying && _seciliRadyo?.link == k.link) {
      await _audio.pause();
      setState(() => _radyoPlaying = false);
      return;
    }
    // Sıralı deneme: seçilen kanaldan başla, en fazla 5 kanal dene
    final sirali = liste ?? [k];
    int startIdx = sirali.indexWhere((e) => e.link == k.link);
    if (startIdx < 0) startIdx = 0;
    int deneme = 0;
    for (int i = startIdx; i < sirali.length && deneme < 5; i++, deneme++) {
      final kanal = sirali[i];
      setState(() { _seciliRadyo = kanal; _radyoLoading = true; });
      try {
        await _pauseTv();
        await _audio.stop();
        await _audio.setReleaseMode(ReleaseMode.stop);
        await _audio.play(UrlSource(kanal.link)).timeout(const Duration(seconds: 12));
        setState(() { _radyoLoading = false; _radyoPlaying = true; });
        if (deneme > 0 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${kanal.ad} açıldı (${deneme + 1}. deneme)'), backgroundColor: AppTheme.primary, duration: const Duration(seconds: 2)));
        }
        return;
      } catch (e) {
        debugPrint('radyo deneme ${deneme + 1} ${kanal.ad} failed: $e');
        continue;
      }
    }
    setState(() { _radyoLoading = false; _radyoPlaying = false; });
    if (!mounted) return;
    _showInternetDialog();
  }

  Future<void> _showInternetDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [Icon(Icons.wifi_off_rounded, color: Colors.red), SizedBox(width: 8), Text('Radyo Açılamadı', style: TextStyle(fontSize: 16))]),
        content: const Text('İNTERNET BAĞLANTINIZI KONTROL EDİNİZ.', style: TextStyle(fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kapat')),
          FilledButton(onPressed: () => Navigator.pop(context), style: FilledButton.styleFrom(backgroundColor: AppTheme.primary), child: const Text('Tamam')),
        ],
      ),
    );
  }

  Future<void> _stopRadyo() async {
    if (!_canClick()) return;
    await _audio.stop();
    setState(() => _radyoPlaying = false);
  }

  Future<void> _playTv(Kanal k) async {
    if (!_canClick()) return;
    setState(() { _seciliTv = k; _videoLoading = true; });
    try {
      await _audio.stop();
      setState(() => _radyoPlaying = false);
      await _videoCtrl?.dispose();
      final ctrl = VideoPlayerController.networkUrl(Uri.parse(k.link));
      _videoCtrl = ctrl;
      await ctrl.initialize().timeout(const Duration(seconds: 20));
      await ctrl.play();
      setState(() => _videoLoading = false);
    } catch (e) {
      setState(() { _videoLoading = false; });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('TV açılamadı: $e')));
    }
  }

  Future<void> _pauseTv() async {
    try {
      await _videoCtrl?.pause();
    } catch (_) {}
  }

  Future<void> _stopTv() async {
    if (!_canClick()) return;
    try {
      await _videoCtrl?.pause();
    } catch (_) {}
    setState(() {});
  }

  Future<void> _closeTv() async {
    try {
      await _videoCtrl?.pause();
      await _videoCtrl?.dispose();
    } catch (_) {}
    _videoCtrl = null;
    setState(() => _seciliTv = null);
  }

  bool get _tvAcik => _videoCtrl != null && _videoCtrl!.value.isInitialized;

  Future<void> _openFullscreen() async {
    final ctrl = _videoCtrl;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _TvFullscreen(kanal: _seciliTv, controller: ctrl)),
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tab.dispose();
    _audioCompleteSub?.cancel();
    _audio.dispose();
    _videoCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Radyo & TV'),
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppTheme.gold,
          tabs: const [
            Tab(icon: Icon(Icons.radio_rounded, size: 18), text: 'Radyo'),
            Tab(icon: Icon(Icons.live_tv_rounded, size: 18), text: 'TV'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Kanal>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 8), Text('Kanallar GitHub\'dan yükleniyor...', style: TextStyle(fontSize: 12))]));
                }
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off_rounded, size: 32, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text('Kanallar alınamadı: ${snap.error}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(icon: const Icon(Icons.refresh_rounded, size: 16), label: const Text('Tekrar Dene'), onPressed: () => setState(() => _future = _service.fetchKanallar()), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white)),
                        ],
                      ),
                    ),
                  );
                }
                final all = snap.data ?? [];
                final radyolar = all.where((k) => k.kategori.toLowerCase() != 'tv').toList();
                final tvler = all.where((k) => k.kategori.toLowerCase() == 'tv').toList();
                _sonRadyolar = radyolar;
                return TabBarView(
                  controller: _tab,
                  children: [
                    _KanalListe(
                      kanallar: radyolar,
                      seciliLink: _radyoPlaying ? _seciliRadyo?.link : null,
                      loadingLink: _radyoLoading ? _seciliRadyo?.link : null,
                      icon: Icons.radio_rounded,
                      onTap: (k, liste) => _playRadyo(k, liste),
                    ),
                    Column(
                      children: [
                        _TvPlayer(
                          controller: _videoCtrl,
                          loading: _videoLoading,
                          kanal: _seciliTv,
                          onStop: _stopTv,
                          onClose: _closeTv,
                          onFullscreen: _openFullscreen,
                        ),
                        Expanded(
                          child: _KanalListe(
                            kanallar: tvler,
                            seciliLink: _seciliTv?.link,
                            loadingLink: _videoLoading ? _seciliTv?.link : null,
                            icon: Icons.live_tv_rounded,
                            onTap: (k, _) => _playTv(k),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          // TV açıkken radyo barı kapanır
          if (!_tvAcik)
            _ProPlayerBar(
              radyo: _seciliRadyo,
              playing: _radyoPlaying,
              loading: _radyoLoading,
              onPlayPause: _seciliRadyo == null ? null : () => _playRadyo(_seciliRadyo!, _sonRadyolar),
              onStop: _stopRadyo,
            ),
        ],
      ),
    );
  }
}

class _KanalListe extends StatelessWidget {
  final List<Kanal> kanallar;
  final String? seciliLink;
  final String? loadingLink;
  final IconData icon;
  final void Function(Kanal, List<Kanal>) onTap;
  const _KanalListe({required this.kanallar, required this.seciliLink, required this.loadingLink, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (kanallar.isEmpty) return const Center(child: Text('Kanal yok', style: TextStyle(fontSize: 12)));
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: kanallar.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final k = kanallar[i];
        final sel = seciliLink == k.link;
        final loading = loadingLink == k.link;
        return InkWell(
          onTap: () => onTap(k, kanallar),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: sel ? const LinearGradient(colors: [Color(0xFF0D5C3D), Color(0xFF1B8A5A)], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
              color: sel ? null : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: sel ? AppTheme.primary : Colors.grey.shade200),
              boxShadow: sel ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.2), blurRadius: 8)] : null,
            ),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: sel ? Colors.white.withValues(alpha: 0.2) : AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: sel ? Colors.white : AppTheme.primary)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(k.ad, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: sel ? Colors.white : Colors.black87)), Text(k.kategori, style: TextStyle(fontSize: 11, color: sel ? Colors.white70 : Colors.grey.shade600))])),
                if (loading)
                  const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary))
                else
                  Icon(sel ? Icons.pause_circle_rounded : Icons.play_circle_rounded, color: sel ? Colors.white : AppTheme.primary, size: 28),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TvPlayer extends StatelessWidget {
  final VideoPlayerController? controller;
  final bool loading;
  final Kanal? kanal;
  final VoidCallback onStop;
  final VoidCallback onClose;
  final VoidCallback onFullscreen;
  const _TvPlayer({required this.controller, required this.loading, required this.kanal, required this.onStop, required this.onClose, required this.onFullscreen});

  Widget _buildTvBody() {
    if (loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 6),
            Text('Yükleniyor...', style: TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      );
    }
    final c = controller;
    // Gerçek en-boy oranıyla doğru dolgu (siyah barlar yerine çerçeveye tam oturur)
    if (c != null && c.value.isInitialized) return FittedBox(fit: BoxFit.contain, child: SizedBox(width: c.value.size.width == 0 ? 640 : c.value.size.width, height: c.value.size.height == 0 ? 360 : c.value.size.height, child: VideoPlayer(c)));
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.live_tv_rounded, color: Colors.white54, size: 32),
          SizedBox(height: 4),
          Text('Uygulama içinde açılır • Harici açılmaz', style: TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0D5C3D), Color(0xFF1B8A5A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(gradient: AppTheme.goldGradient, borderRadius: BorderRadius.circular(20)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.workspace_premium_rounded, size: 10, color: Colors.white), SizedBox(width: 3), Text('PRO', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))]),
              ),
              const SizedBox(width: 6),
              Expanded(child: Text(kanal?.ad ?? 'TV seçilmedi — listeden seç', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))),
              if (kanal != null && controller != null && controller!.value.isInitialized) InkWell(onTap: onFullscreen, child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.fullscreen_rounded, size: 14, color: Colors.white), SizedBox(width: 2), Text('Tam Ekran', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))])),
              if (kanal != null) const SizedBox(width: 8),
              if (kanal != null) InkWell(onTap: onStop, child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.stop_rounded, size: 14, color: Colors.white), SizedBox(width: 2), Text('Durdur', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))])),
              if (kanal != null) const SizedBox(width: 4),
              if (kanal != null) InkWell(onTap: onClose, child: const Icon(Icons.close_rounded, size: 16, color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: (controller != null && controller!.value.isInitialized && controller!.value.aspectRatio > 0) ? controller!.value.aspectRatio : 16 / 9,
              child: Container(
                color: Colors.black,
                child: _buildTvBody(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TvFullscreen extends StatefulWidget {
  final Kanal? kanal;
  final VideoPlayerController controller;
  const _TvFullscreen({required this.kanal, required this.controller});
  @override
  State<_TvFullscreen> createState() => _TvFullscreenState();
}

class _TvFullscreenState extends State<_TvFullscreen> {
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white, title: Text(widget.kanal?.ad ?? 'Canlı Yayın', style: const TextStyle(fontSize: 14))),
      body: Center(
        child: c.value.isInitialized
            ? AspectRatio(aspectRatio: c.value.aspectRatio > 0 ? c.value.aspectRatio : 16 / 9, child: VideoPlayer(c))
            : const CircularProgressIndicator(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        onPressed: () => setState(() => c.value.isPlaying ? c.pause() : c.play()),
        child: Icon(c.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
      ),
    );
  }
}

class _ProPlayerBar extends StatelessWidget {
  final Kanal? radyo;
  final bool playing;
  final bool loading;
  final VoidCallback? onPlayPause;
  final VoidCallback onStop;
  const _ProPlayerBar({required this.radyo, required this.playing, required this.loading, required this.onPlayPause, required this.onStop});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0D5C3D), Color(0xFF1B8A5A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.radio_rounded, color: Colors.white, size: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(radyo?.ad ?? 'Radyo seçilmedi', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13))),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(gradient: AppTheme.goldGradient, borderRadius: BorderRadius.circular(20)), child: const Text('PRO', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))),
                  ],
                ),
                Text(loading ? 'Bağlanıyor...' : (playing ? 'Çalıyor • Uygulama içinde' : 'Duraklatıldı'), style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11)),
              ],
            ),
          ),
          if (loading)
            const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          else
            InkWell(
              onTap: onPlayPause,
              borderRadius: BorderRadius.circular(30),
              child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: AppTheme.primary, size: 20)),
            ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onStop,
            borderRadius: BorderRadius.circular(30),
            child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), child: const Icon(Icons.stop_rounded, color: Colors.white, size: 18)),
          ),
        ],
      ),
    );
  }
}
