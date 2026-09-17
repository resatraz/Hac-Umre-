import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/app_theme.dart';
import '../../services/ezan_vakti_service.dart';
import '../uygulama/mekke_medine_saati_screen.dart';

class EzanVaktiNamazScreen extends StatefulWidget {
  const EzanVaktiNamazScreen({super.key});
  @override
  State<EzanVaktiNamazScreen> createState() => _EzanVaktiNamazScreenState();
}

class _EzanVaktiNamazScreenState extends State<EzanVaktiNamazScreen> {
  final _service = EzanVaktiService();
  VakitGun? _bugun;
  bool _loading = true;
  String? _error;
  String _sehirLabel = 'İstanbul (Varsayılan)';
  int _ilceId = 9541; // İstanbul - Fatih varsayılan (Diyanet ID)
  Timer? _countdownTimer;
  Duration? _nextDiff;
  String _nextName = '';

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
    _fetch();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  Future<void> _loadSavedLocation() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _ilceId = p.getInt('ezan_ilce') ?? 9541;
      _sehirLabel = p.getString('ezan_label') ?? 'İstanbul (Varsayılan)';
    });
  }

  Future<void> _saveLocation(int id, String label) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('ezan_ilce', id);
    await p.setString('ezan_label', label);
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      final v = await _service.fetchBugun(_ilceId);
      setState(() { _bugun = v; _loading = false; });
      _updateCountdown();
    } catch (e) {
      setState(() { _error = '$e'; _loading = false; });
    }
  }

  void _updateCountdown() {
    if (_bugun == null) return;
    final now = DateTime.now();
    final times = {
      'İmsak': _bugun!.imsak,
      'Güneş': _bugun!.gunes,
      'Öğle': _bugun!.ogle,
      'İkindi': _bugun!.ikindi,
      'Akşam': _bugun!.aksam,
      'Yatsı': _bugun!.yatsi,
    };
    DateTime? nextTime;
    String next = '';
    for (final e in times.entries) {
      final parts = e.value.split(':');
      if (parts.length != 2) continue;
      final t = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
      if (t.isAfter(now)) { nextTime = t; next = e.key; break; }
    }
    nextTime ??= () {
      final p = times.entries.first.value.split(':');
      return DateTime(now.year, now.month, now.day + 1, int.parse(p[0]), int.parse(p[1]));
    }();
    if (next.isEmpty) next = 'İmsak';
    setState(() { _nextDiff = nextTime!.difference(now); _nextName = next; });
  }

  Future<void> _konumBul() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) throw Exception('Konum kapalı');
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) throw Exception('İzin reddedildi');
      final pos = await Geolocator.getCurrentPosition();
      // Basit: konuma göre en yakın ilçe bulunamıyor, İstanbul varsayılan kalıyor ama snackbar göster
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Konum: ${pos.latitude.toStringAsFixed(2)}, ${pos.longitude.toStringAsFixed(2)} • En yakın vakit İstanbul gösteriliyor')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Konum hatası: $e')));
    }
  }

  Future<void> _sehirSec() async {
    // Basit şehir seçici: ezanvakti API ülke/şehir/ilçe listesi yerine sabit kısa liste
    final sec = await showModalBottomSheet<int>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          const ListTile(title: Text('Şehir Seç', style: TextStyle(fontWeight: FontWeight.w800))),
          ...[
            {'label': 'Mekke', 'id': 16309},
            {'label': 'Medine', 'id': 16308},
            {'label': 'İstanbul - Fatih', 'id': 9541},
            {'label': 'Ankara', 'id': 9831},
            {'label': 'İzmir', 'id': 10264},
            {'label': 'Bursa', 'id': 9783},
          ].map((e) => ListTile(
                leading: const Icon(Icons.location_city_rounded, color: AppTheme.primary),
                title: Text(e['label'] as String),
                trailing: Text('${e['id']}', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                onTap: () => Navigator.pop(context, e['id'] as int),
              )),
        ],
      ),
    );
    if (sec != null) {
      final label = sec == 16309 ? 'Mekke' : sec == 16308 ? 'Medine' : 'İlçe $sec';
      await _saveLocation(sec, label);
      setState(() { _ilceId = sec; _sehirLabel = label; });
      _fetch();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ezan Vakti : Namaz ve Kuran'),
        actions: [IconButton(icon: const Icon(Icons.my_location_rounded), onPressed: _konumBul, tooltip: 'Konum bul'), IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _fetch)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(gradient: AppTheme.proGradient, borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [const Icon(Icons.location_on_rounded, color: Colors.white, size: 14), const SizedBox(width: 4), Expanded(child: Text(_sehirLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))), TextButton(onPressed: _sehirSec, child: const Text('Değiştir', style: TextStyle(color: Colors.white, fontSize: 11)))]),
                const SizedBox(height: 6),
                if (_nextDiff != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: Row(children: [const Icon(Icons.timer_rounded, color: Colors.white, size: 16), const SizedBox(width: 6), Text('Sıradaki: $_nextName', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)), const Spacer(), Text('${_nextDiff!.inHours.toString().padLeft(2, '0')}:${(_nextDiff!.inMinutes % 60).toString().padLeft(2, '0')}:${(_nextDiff!.inSeconds % 60).toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14))]),
                  ),
                const SizedBox(height: 6),
                Text('Kaynak: ezanvakti.emushaf.net • Diyanet • ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_loading) const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
          else if (_error != null)
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)), child: Column(children: [Text('Hata: $_error', style: const TextStyle(fontSize: 11)), const SizedBox(height: 8), ElevatedButton.icon(onPressed: _fetch, icon: const Icon(Icons.refresh_rounded, size: 14), label: const Text('Tekrar Dene', style: TextStyle(fontSize: 11)))]))
          else if (_bugun != null) ...[
            Row(children: [const Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.primary), const SizedBox(width: 6), Expanded(child: Text('${_bugun!.miladiUzun} • ${_bugun!.hicriUzun}', style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w600)))]),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.1,
              children: [
                _VakitCard(label: 'İmsak', time: _bugun!.imsak, icon: Icons.nights_stay_rounded, color: const Color(0xFF263238), isNext: _nextName == 'İmsak'),
                _VakitCard(label: 'Güneş', time: _bugun!.gunes, icon: Icons.wb_sunny_rounded, color: const Color(0xFFE65100), isNext: _nextName == 'Güneş'),
                _VakitCard(label: 'Öğle', time: _bugun!.ogle, icon: Icons.wb_sunny_outlined, color: const Color(0xFF1565C0), isNext: _nextName == 'Öğle'),
                _VakitCard(label: 'İkindi', time: _bugun!.ikindi, icon: Icons.cloud_rounded, color: const Color(0xFF00695C), isNext: _nextName == 'İkindi'),
                _VakitCard(label: 'Akşam', time: _bugun!.aksam, icon: Icons.bedtime_rounded, color: const Color(0xFF4A148C), isNext: _nextName == 'Akşam'),
                _VakitCard(label: 'Yatsı', time: _bugun!.yatsi, icon: Icons.nights_stay_outlined, color: const Color(0xFF37474F), isNext: _nextName == 'Yatsı'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.calendar_month_rounded, size: 14), label: const Text('Aylık', style: TextStyle(fontSize: 11)), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aylık tablo: ezanvakti.emushaf.net/vakitler/{ilce}'))))),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.explore_rounded, size: 14), label: const Text('Kıble', style: TextStyle(fontSize: 11)), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MekkeMedineSaatiScreen())))),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [Icon(Icons.auto_stories_rounded, size: 16, color: AppTheme.primary), SizedBox(width: 6), Text('Hızlı Erişim', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))]),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Chip(label: 'Kur\'an', icon: Icons.menu_book_rounded, onTap: () {}),
                    _Chip(label: 'Yasin', icon: Icons.favorite_rounded, onTap: () {}),
                    _Chip(label: 'Dua', icon: Icons.volunteer_activism_rounded, onTap: () {}),
                    _Chip(label: '99 İsim', icon: Icons.stars_rounded, onTap: () {}),
                    _Chip(label: 'Zikir', icon: Icons.touch_app_rounded, onTap: () {}),
                    _Chip(label: 'Radyo', icon: Icons.radio_rounded, onTap: () {}),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.goldLight, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3))),
            child: Row(children: [const Icon(Icons.notifications_active_rounded, size: 14, color: AppTheme.goldDark), const SizedBox(width: 6), const Expanded(child: Text('Bildirim: Ezan vakti, kandil, cuma selası • Ayarlar > Bildirim', style: TextStyle(fontSize: 11, color: AppTheme.goldDark))), TextButton(onPressed: () {}, child: const Text('Aç', style: TextStyle(fontSize: 11)))]),
          ),
        ],
      ),
    );
  }
}

class _VakitCard extends StatelessWidget {
  final String label, time;
  final IconData icon;
  final Color color;
  final bool isNext;
  const _VakitCard({required this.label, required this.time, required this.icon, required this.color, this.isNext = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: isNext ? color : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isNext ? color : color.withValues(alpha: 0.15)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: isNext ? Colors.white.withValues(alpha: 0.2) : color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 14, color: isNext ? Colors.white : color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isNext ? Colors.white : color)),
          Text(time, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isNext ? Colors.white : Colors.black87)),
          if (isNext) Container(margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)), child: const Text('Sıradaki', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 12, color: AppTheme.primary), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w600))])),
      );
}
