import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/models.dart';
import '../theme/app_theme.dart';
import '../services/audio_service.dart';

class ZiyaretDetailScreen extends StatefulWidget {
  final ZiyaretYeri yer;
  const ZiyaretDetailScreen({super.key, required this.yer});
  @override
  State<ZiyaretDetailScreen> createState() => _ZiyaretDetailScreenState();
}

class _ZiyaretDetailScreenState extends State<ZiyaretDetailScreen> {
  bool showArapca = true;
  bool fav = false;
  bool isPlaying = false;
  final _audio = AppAudioService();

  @override
  void initState() {
    super.initState();
    _audio.init();
  }

  Future<void> _toggleAudio() async {
    final z = widget.yer;
    if (isPlaying) {
      await _audio.stop();
      setState(() => isPlaying = false);
      return;
    }
    setState(() => isPlaying = true);
    final ok = await _audio.speak(
      id: 'ziyaret_${z.id}',
      arapca: z.duaArapca,
      okunus: z.duaOkunus,
      onDone: () {
        if (mounted) setState(() => isPlaying = false);
      },
    );
    if (!ok && mounted) {
      setState(() => isPlaying = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ses çalınamadı')));
    }
  }

  Future<void> _openMap() async {
    final z = widget.yer;
    final googleUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=${z.lat},${z.lng}');
    final geoUrl = Uri.parse('geo:${z.lat},${z.lng}?q=${z.lat},${z.lng}(${Uri.encodeComponent(z.ad)})');
    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(geoUrl)) {
      await launchUrl(geoUrl);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${z.ad} • ${z.lat}, ${z.lng}')));
    }
  }

  @override
  void dispose() {
    _audio.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final z = widget.yer;
    return Scaffold(
      appBar: AppBar(
        title: Text(z.ad),
        actions: [
          IconButton(icon: Icon(fav ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: fav ? Colors.redAccent : Colors.white), onPressed: () => setState(() => fav = !fav)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: z.sehir == 'Mekke' ? [AppTheme.primary, const Color(0xFF1B8A5A)] : [AppTheme.goldDark, AppTheme.gold], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Icon(z.icon, color: Colors.white, size: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${z.sehir} • ${z.kategori}', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(z.ad, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(z.icon, size: 44, color: AppTheme.primary.withValues(alpha: 0.4)),
                const SizedBox(height: 6),
                Text(z.ad, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                Text('Tarihi görsel', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 14),
            Text('Hakkında', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(z.aciklama, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 10),
            Text('Tarihçe', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Text(z.tarihce, style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(height: 12),
            Text('Ziyaret Adabı', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.goldLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.info_rounded, size: 18, color: AppTheme.goldDark), const SizedBox(width: 8), Expanded(child: Text(z.ziyaretAdabi, style: const TextStyle(fontSize: 13, height: 1.5)))]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.menu_book_rounded, size: 16, color: AppTheme.primary)),
                    const SizedBox(width: 8),
                    const Text('Burada Okunacak Dua', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const Spacer(),
                    IconButton(icon: Icon(isPlaying ? Icons.pause_circle_rounded : Icons.volume_up_rounded, color: AppTheme.primary), onPressed: _toggleAudio),
                  ]),
                  if (isPlaying)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [const Icon(Icons.graphic_eq_rounded, size: 16, color: AppTheme.primary), const SizedBox(width: 8), const Expanded(child: Text('TTS ile okunuyor...', style: TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w700))), TextButton(onPressed: _toggleAudio, child: const Text('Durdur', style: TextStyle(fontSize: 11))) ]),
                    ),
                  Row(children: [
                    ChoiceChip(label: const Text('Arapça'), selected: showArapca, onSelected: (v) => setState(() => showArapca = true), selectedColor: AppTheme.primaryLight),
                    const SizedBox(width: 8),
                    ChoiceChip(label: const Text('Anlam'), selected: !showArapca, onSelected: (v) => setState(() => showArapca = false), selectedColor: AppTheme.goldLight),
                  ]),
                  const SizedBox(height: 10),
                  if (showArapca)
                    Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)), child: Text(z.duaArapca, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, height: 1.8, color: AppTheme.primaryDark, fontWeight: FontWeight.w600)))
                  else
                    Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(z.duaOkunus, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13)), const SizedBox(height: 8), Text(z.duaAnlam, style: const TextStyle(fontSize: 13))])),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded, size: 18),
                      label: Text(isPlaying ? 'Durdur' : 'Sesli Dinle (TTS)'),
                      style: ElevatedButton.styleFrom(backgroundColor: isPlaying ? Colors.red.shade600 : AppTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: _toggleAudio,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.navigation_rounded, size: 18),
                      label: const Text('Haritada Gör / Yol Tarifi'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: _openMap,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
