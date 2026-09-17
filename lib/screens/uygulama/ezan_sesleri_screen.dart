import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadDownloaded();
    _bildirim.init();
  }

  Future<void> _loadDownloaded() async {
    for (final f in ezanDriveFiles) {
      final ok = await _ses.isDownloaded(f['id']!);
      if (mounted) setState(() => _downloaded[f['id']!] = ok);
    }
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name hazır • Offline çalınabilir ✓'), backgroundColor: AppTheme.primary));
    } catch (e) {
      setState(() => _prog.remove(id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('İndirme hatası: $e')));
    }
  }

  Future<void> _cal(String id, String name) async {
    if (!_ses.canClick()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tıklama koruması: bekleyin'), duration: Duration(milliseconds: 600)));
      return;
    }
    try {
      setState(() => _playing = {id});
      await _ses.play(id, name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name çalıyor... • Dinleme kaydedildi'), backgroundColor: AppTheme.primary, duration: const Duration(seconds: 1)));
      // 3 sn sonra playing temizle
      Future.delayed(const Duration(seconds: 3), () => mounted ? setState(() => _playing = {}) : null);
    } catch (e) {
      setState(() => _playing = {});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Çalma hatası: $e')));
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
                    Expanded(child: Text('Ezan vakitlerinde bildirim al (Mekke/Medine)', style: TextStyle(fontSize: 11, color: Colors.grey.shade800))),
                    Switch(value: _bildirimAcik, activeThumbColor: AppTheme.primary, onChanged: (v) async {
                      setState(() => _bildirimAcik = v);
                      if (v) {
                        try {
                          final vakit = await EzanVaktiService().fetchBugun(16309);
                          await _bildirim.scheduleVakitBildirimleri(vakit, 'Mekke');
                          await _bildirim.showTestBildirim(sehir: 'Mekke');
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vakit bildirimleri planlandı • ${vakit.miladiUzun} 6 vakit • Zamanında gelecek'), backgroundColor: AppTheme.primary));
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Planlama hatası: $e')));
                          setState(() => _bildirimAcik = false);
                        }
                      } else {
                        await _bildirim.cancelAll();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tüm vakit bildirimleri iptal edildi')));
                      }
                    }),
                  ],
                ),
                Text('Drive 9 ses • İndirmeli offline • Tıklama koruması (800ms) • Dinleme geçmişi kaydedilir', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
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
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), Text(prog != null ? '${(prog * 100).toInt()}% indiriliyor...' : (dl ? 'Offline • Hazır ✓' : 'Çevrimdışı için dokunun'), style: TextStyle(fontSize: 11, color: dl ? AppTheme.primary : Colors.grey.shade600)), Text('ID: ${id.substring(0, 8)}...', style: TextStyle(fontSize: 9, color: Colors.grey.shade400))])),
                      if (prog != null)
                        SizedBox(width: 60, height: 60, child: Stack(alignment: Alignment.center, children: [CircularProgressIndicator(value: prog, strokeWidth: 3, color: AppTheme.primary), Text('${(prog * 100).toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))])),
                      if (prog == null) ...[
                        IconButton(icon: Icon(playing ? Icons.pause_circle_rounded : Icons.play_circle_rounded, color: AppTheme.primary, size: 30), onPressed: () => _cal(id, name)),
                        IconButton(
                          icon: Icon(dl ? Icons.check_circle_rounded : Icons.download_rounded, color: dl ? Colors.green : AppTheme.goldDark, size: 22),
                          onPressed: dl ? null : () => _indirme(id, name),
                          tooltip: dl ? 'İndirildi' : 'İndir (offline)',
                        ),
                      ],
                    ],
                  ),
                  if (playing)
                    Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)), child: Row(children: [const Icon(Icons.graphic_eq_rounded, size: 14, color: AppTheme.primary), const SizedBox(width: 6), Expanded(child: Text('$name • Tıklama koruması aktif • Dinleme kaydediliyor', style: const TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.w600))), InkWell(onTap: () async { await _ses.stop(); setState(() => _playing = {}); }, child: const Text('Durdur', style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w700)))])),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FutureBuilder<int>(future: _ses.getCount(id), builder: (c, s) => Text('Dinlenme: ${s.data ?? 0}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600))),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dinleme Geçmişi (son 10)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(height: 8),
                FutureBuilder<List<String>>(future: _ses.getHistory(), builder: (c, s) {
                  final h = s.data ?? [];
                  if (h.isEmpty) return Text('Henüz dinleme yok', style: TextStyle(fontSize: 11, color: Colors.grey.shade600));
                  return Column(children: h.take(10).map((e) {
                    final parts = e.split('|');
                    final ts = parts.isNotEmpty ? parts[0] : '';
                    final name = parts.length > 2 ? parts[2] : parts.last;
                    return Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [const Icon(Icons.history_rounded, size: 12, color: Colors.grey), const SizedBox(width: 6), Expanded(child: Text('$name • ${ts.substring(0, 19).replaceAll('T', ' ')}', style: const TextStyle(fontSize: 10)))]));
                  }).toList());
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('Kaynak: 9 Drive dosyası • İndirmeli offline çalma • Tıklama koruması 800ms • Her dinleme SharedPreferences ile kaydedilir', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
