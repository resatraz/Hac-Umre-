import 'package:flutter/material.dart';
import '../../data/zikir_data.dart';
import '../../theme/app_theme.dart';
import '../../services/audio_service.dart';

class GunlukDualarScreen extends StatefulWidget {
  const GunlukDualarScreen({super.key});
  @override
  State<GunlukDualarScreen> createState() => _GunlukDualarScreenState();
}

class _GunlukDualarScreenState extends State<GunlukDualarScreen> {
  String? playingId;
  final _audio = AppAudioService();
  @override
  void initState() { super.initState(); _audio.init(); }
  @override
  void dispose() { _audio.stop(); super.dispose(); }
  Future<void> _toggle(Map<String, String> d) async {
    final id = d['baslik']!;
    if (playingId == id) {
      await _audio.stop();
      setState(() => playingId = null);
      return;
    }
    setState(() => playingId = id);
    final ok = await _audio.speak(id: id, arapca: d['arapca']!, okunus: d['okunus']!, onDone: () { if (mounted) setState(() => playingId = null); });
    if (!ok && mounted) {
      setState(() => playingId = null);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ses çalınamadı')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Günlük Dualar')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: gunlukDualar.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final d = gunlukDualar[i];
          final isPlaying = playingId == d['baslik'];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: isPlaying ? AppTheme.primary.withValues(alpha: 0.4) : Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(20)), child: Text(d['kategori']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primary))),
                  const Spacer(),
                  if (isPlaying) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.graphic_eq_rounded, size: 12, color: AppTheme.primary), SizedBox(width: 4), Text('Çalıyor', style: TextStyle(fontSize: 10, color: AppTheme.primary))])),
                  IconButton(icon: Icon(isPlaying ? Icons.pause_circle_rounded : Icons.volume_up_rounded, size: 20, color: AppTheme.primary), onPressed: () => _toggle(d)),
                  IconButton(icon: const Icon(Icons.copy_rounded, size: 18, color: Colors.grey), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kopyalandı')))),
                ]),
                Text(d['baslik']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 8),
                Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)), child: Text(d['arapca']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: AppTheme.primaryDark, fontWeight: FontWeight.w600))),
                const SizedBox(height: 6),
                Text(d['okunus']!, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                const SizedBox(height: 4),
                Text(d['anlam']!, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, child: ElevatedButton.icon(icon: Icon(isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded, size: 16), label: Text(isPlaying ? 'Durdur' : 'Dinle (TTS)'), onPressed: () => _toggle(d), style: ElevatedButton.styleFrom(backgroundColor: isPlaying ? Colors.red.shade600 : AppTheme.primary, foregroundColor: Colors.white))),
              ],
            ),
          );
        },
      ),
    );
  }
}
