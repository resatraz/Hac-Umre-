import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../data/models.dart';
import '../services/hac_umre_audio.dart';

class AdimDetailScreen extends StatefulWidget {
  final RehberAdim adim;
  final String ibadet; // Hac / Umre
  const AdimDetailScreen({super.key, required this.adim, required this.ibadet});

  @override
  State<AdimDetailScreen> createState() => _AdimDetailScreenState();
}

class _AdimDetailScreenState extends State<AdimDetailScreen> {
  bool showArapca = true;
  bool isPlaying = false;
  final _audio = HacUmreAudioService();

  String get _sesKey => '${widget.ibadet.toLowerCase() == 'hac' ? 'hac' : 'umre'}_${widget.adim.sira}';
  String get _sesKaynak => hacUmreSesleri[_sesKey]?.kaynak ?? 'Orijinal ses';

  Future<void> _toggleAudio() async {
    if (isPlaying) {
      await _audio.stop();
      setState(() => isPlaying = false);
      return;
    }
    setState(() => isPlaying = true);
    try {
      await _audio.play(_sesKey, onDone: () {
        if (mounted) setState(() => isPlaying = false);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isPlaying = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ses çalınamadı. İnternet bağlantınızı kontrol edin.')));
    }
  }

  ({double lat, double lng, String ad})? _konumBilgisi() {
    final b = widget.adim.baslik.toLowerCase();
    if (b.contains('tavaf') || b.contains('kud')) return (lat: 21.3891, lng: 39.8579, ad: 'Kâbe');
    if (b.contains('say') || b.contains("sa'y")) return (lat: 21.3900, lng: 39.8570, ad: 'Safa-Merve');
    if (b.contains('arafat')) return (lat: 21.3561, lng: 39.9762, ad: 'Arafat');
    if (b.contains('muzdelife')) return (lat: 21.3850, lng: 39.9350, ad: 'Müzdelife');
    if (b.contains('mina') || b.contains('şeytan')) return (lat: 21.4133, lng: 39.8933, ad: 'Mina');
    if (b.contains('ziyaret') || b.contains('veda')) return (lat: 21.3891, lng: 39.8579, ad: 'Kâbe');
    return null;
  }

  Future<void> _openKonum() async {
    final k = _konumBilgisi();
    if (k == null) return;
    final url = Uri.parse('https://yandex.com.tr/maps/?rtext=~${k.lat},${k.lng}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${k.ad} • ${k.lat}, ${k.lng}')));
    }
  }

  @override
  void dispose() {
    _audio.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.adim;
    return Scaffold(
      appBar: AppBar(
        title: Text('${a.sira}. ${a.baslik}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paylaşım yakında'))),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF1B8A5A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                    child: Icon(a.icon, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${widget.ibadet} • Adım ${a.sira}', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Text(a.baslik, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(a.kisaAciklama, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.schedule_rounded, size: 12, color: Colors.white), const SizedBox(width: 4), Text(a.sure, style: const TextStyle(color: Colors.white, fontSize: 11))]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (a.imagePath != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  a.imagePath!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    height: 200,
                    decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(14)),
                    child: Icon(a.icon, size: 48, color: AppTheme.primary.withValues(alpha: 0.4)),
                  ),
                ),
              ),
            ],
            if (_konumBilgisi() != null) ...[
              InkWell(
                onTap: _openKonum,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
                  child: Row(children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 18)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${_konumBilgisi()!.ad} Konumu', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)), Text('Yandex Maps ile yol tarifi', style: TextStyle(fontSize: 11, color: Colors.grey.shade600))])),
                    const Icon(Icons.navigation_rounded, color: AppTheme.primary, size: 18),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text('Detaylı Anlatım', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(a.detay, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 14),
            Text('Yapılacaklar', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...a.maddeler.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(7)),
                        child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(m, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14))),
                    ],
                  ),
                )),
            if (a.uyari.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFCC80))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_rounded, color: Color(0xFFE65100), size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(a.uyari, style: const TextStyle(fontSize: 12.5, color: Color(0xFF6D4C00), height: 1.4))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppTheme.goldLight, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.menu_book_rounded, color: AppTheme.goldDark, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text('Bu Adımda Okunacak Dua', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                      const Spacer(),
                      IconButton(
                        icon: Icon(isPlaying ? Icons.pause_circle_rounded : Icons.play_circle_rounded, color: AppTheme.primary, size: 30),
                        onPressed: _toggleAudio,
                      ),
                    ],
                  ),
                  if (isPlaying)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          const Icon(Icons.graphic_eq_rounded, size: 16, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Orijinal ses çalınıyor • $_sesKaynak', style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w600))),
                          TextButton(onPressed: _toggleAudio, child: const Text('Durdur', style: TextStyle(fontSize: 11))),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Arapça'),
                        selected: showArapca,
                        onSelected: (v) => setState(() => showArapca = true),
                        selectedColor: AppTheme.primaryLight,
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Okunuş & Anlam'),
                        selected: !showArapca,
                        onSelected: (v) => setState(() => showArapca = false),
                        selectedColor: AppTheme.goldLight,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (showArapca)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(12)),
                      child: Text(a.duaArapca, textAlign: TextAlign.center, style: AppTheme.arabic(size: 20)),
                    )
                  else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('OKUNUŞ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text(a.duaOkunus, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, height: 1.5)),
                          const SizedBox(height: 10),
                          const Text('ANLAM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primary, letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text(a.duaAnlam, style: const TextStyle(fontSize: 13, height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded, size: 18),
                      label: Text(isPlaying ? 'Durdur' : 'Sesli Dinle'),
                      onPressed: _toggleAudio,
                      style: ElevatedButton.styleFrom(backgroundColor: isPlaying ? Colors.red.shade600 : AppTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                  Text('Orijinal ses • $_sesKaynak • Offline (asset) + API yedeği', style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
