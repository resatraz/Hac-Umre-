import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../services/ezan_ses_service.dart';
import '../../services/bildirim_service.dart';
import '../../services/ezan_vakti_service.dart';

class EzanSesleriScreen extends StatefulWidget {
  const EzanSesleriScreen({super.key});
  @override
  State<EzanSesleriScreen> createState() => _EzanSesleriScreenState();
}

class _EzanSesleriScreenState extends State<EzanSesleriScreen> {
  final _ses = EzanSesService();
  final _bildirim = BildirimService();
  final Map<String, double> _prog = {};
  final Map<String, bool> _downloaded = {};
  Set<String> _playing = {};
  bool _bildirimAcik = false;
  String? _bildirimSesId;

  @override
  void initState() {
    super.initState();
    _loadDownloaded();
    _loadBildirimState();
    _bildirim.init();
  }

  Future<void> _loadDownloaded() async {
    for (final f in ezanDriveFiles) {
      final ok = await _ses.isDownloaded(f['id']!);
      if (mounted) setState(() => _downloaded[f['id']!] = ok);
    }
  }

  Future<void> _loadBildirimState() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _bildirimAcik = p.getBool('ezan_bildirim_acik') ?? false;
      _bildirimSesId = p.getString('ezan_bildirim_id');
    });
  }

  Future<void> _saveBildirim(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('ezan_bildirim_acik', v);
  }

  Future<void> _indirme(String id, String name) async {
    if (!_ses.canClick()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Çok hızlı tıkladınız, bekleyin'), duration: Duration(milliseconds: 800)));
      return;
    }
    try {
      setState(() => _prog[id] = 0.01);
      await _ses.download(id, onProgress: (p) => setState(() => _prog[id] = p));
      setState(() {
        _prog.remove(id);
        _downloaded[id] = true;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name hazır ✓'), backgroundColor: AppTheme.primary));
    } catch (e) {
      setState(() => _prog.remove(id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('İndirme hatası: $e')));
    }
  }

  Future<void> _ondinleme(String id, String name) async {
    if (!_ses.canClick()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tıklama koruması: bekleyin'), duration: Duration(milliseconds: 600)));
      return;
    }
    try {
      setState(() => _playing = {id});
      await _ses.play(id, name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name • Öndinleme'), backgroundColor: AppTheme.primary, duration: const Duration(seconds: 1)));
      Future.delayed(const Duration(seconds: 3), () => mounted ? setState(() => _playing = {}) : null);
    } catch (e) {
      setState(() => _playing = {});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Çalma hatası: $e')));
    }
  }

  Future<void> _bildirimSesiYap(String id, String name) async {
    // Seçilen ses indirilmemişse önce indir
    if (!(_downloaded[id] ?? false)) {
      await _indirme(id, name);
      if (!(_downloaded[id] ?? false)) return;
    }
    final p = await SharedPreferences.getInstance();
    await p.setString('ezan_bildirim_id', id);
    await p.setString('ezan_bildirim_ad', name);
    setState(() => _bildirimSesId = id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name • Bildirim sesi yapıldı ✓'), backgroundColor: AppTheme.primary));
  }

  Future<void> _toggleBildirim(bool v) async {
    if (v) {
      // Önce test bildirimi (çevrimdışı da çalışır) — switch hemen tepki verir
      try {
        await _bildirim.showTestBildirim(sehir: 'Mekke');
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bildirim izni gerekli: $e')));
        return;
      }
      setState(() => _bildirimAcik = true);
      await _saveBildirim(true);
      if (!mounted) return;
      final sesAd = _bildirimSesId == null ? null : ezanDriveFiles.firstWhere((f) => f['id'] == _bildirimSesId, orElse: () => const {'name': ''})['name'];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bildirim açık ✓${sesAd != null && sesAd.isNotEmpty ? ' • Ses: $sesAd' : ''}'), backgroundColor: AppTheme.primary));
      // Vakit planlaması en iyi gayretle (internet gerekli)
      try {
        final vakit = await EzanVaktiService().fetchBugun(16309);
        await _bildirim.scheduleVakitBildirimleri(vakit, 'Mekke');
      } catch (e) {
        debugPrint('Vakit planlama hatası: $e');
      }
    } else {
      await _bildirim.cancelAll();
      await _saveBildirim(false);
      setState(() => _bildirimAcik = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bildirim kapatıldı')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ezan Sesleri')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.goldLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [Icon(Icons.notifications_active_rounded, size: 16, color: AppTheme.goldDark), SizedBox(width: 6), Text('Bildirim', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.goldDark))]),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Expanded(child: Text('Ezan vakitlerinde bildirim al (Mekke/Medine)', style: TextStyle(fontSize: 11))),
                    Switch(value: _bildirimAcik, activeThumbColor: AppTheme.primary, onChanged: _toggleBildirim),
                  ],
                ),
                if (_bildirimSesId != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4))),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.notifications_rounded, size: 12, color: AppTheme.goldDark),
                        const SizedBox(width: 4),
                        Text(
                          'Bildirim sesi: ${ezanDriveFiles.firstWhere((f) => f['id'] == _bildirimSesId, orElse: () => const {'name': ''})['name']}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.goldDark),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...ezanDriveFiles.map((f) {
            final id = f['id']!;
            final name = f['name']!;
            final dl = _downloaded[id] ?? false;
            final prog = _prog[id];
            final playing = _playing.contains(id);
            final isBildirimSesi = _bildirimSesId == id;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: playing ? AppTheme.primary.withValues(alpha: 0.4) : Colors.grey.shade200), boxShadow: playing ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.08), blurRadius: 8)] : null),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: dl ? AppTheme.primaryLight : Colors.grey.shade100, borderRadius: BorderRadius.circular(10)), child: Icon(dl ? Icons.offline_pin_rounded : Icons.cloud_download_rounded, size: 18, color: dl ? AppTheme.primary : Colors.grey)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            if (prog != null)
                              Text('${(prog * 100).toInt()}%', style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w700))
                            else if (dl)
                              const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check_circle_rounded, size: 12, color: Colors.green), SizedBox(width: 4), Text('Hazır', style: TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w600))]),
                            if (isBildirimSesi)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: AppTheme.goldLight, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4))),
                                child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.notifications_rounded, size: 10, color: AppTheme.goldDark), SizedBox(width: 3), Text('Bildirim sesi', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.goldDark))]),
                              ),
                          ],
                        ),
                      ),
                      if (prog != null)
                        SizedBox(width: 44, height: 44, child: Stack(alignment: Alignment.center, children: [CircularProgressIndicator(value: prog, strokeWidth: 3, color: AppTheme.primary), Text('${(prog * 100).toInt()}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700))])),
                      if (prog == null) ...[
                        IconButton(icon: Icon(playing ? Icons.pause_circle_rounded : Icons.play_circle_rounded, color: AppTheme.primary, size: 30), onPressed: () => _ondinleme(id, name), tooltip: 'Öndinleme'),
                        IconButton(
                          icon: Icon(isBildirimSesi ? Icons.notifications_rounded : Icons.notifications_outlined, color: isBildirimSesi ? AppTheme.goldDark : Colors.grey, size: 22),
                          onPressed: () => _bildirimSesiYap(id, name),
                          tooltip: 'Bildirim sesi yap',
                        ),
                        IconButton(
                          icon: Icon(dl ? Icons.check_circle_rounded : Icons.download_rounded, color: dl ? Colors.green : AppTheme.goldDark, size: 22),
                          onPressed: dl ? null : () => _indirme(id, name),
                          tooltip: dl ? 'İndirildi' : 'İndir',
                        ),
                      ],
                    ],
                  ),
                  if (playing)
                    Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)), child: Row(children: [const Icon(Icons.graphic_eq_rounded, size: 14, color: AppTheme.primary), const SizedBox(width: 6), Expanded(child: Text('$name • Öndinleme', style: const TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.w600))), InkWell(onTap: () async { await _ses.stop(); setState(() => _playing = {}); }, child: const Text('Durdur', style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w700)))])),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
