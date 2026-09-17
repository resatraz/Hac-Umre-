import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/takvim_data.dart';
import '../../services/ezan_vakti_service.dart';
import 'ezan_sesleri_screen.dart';

class MekkeMedineSaatiScreen extends StatefulWidget {
  const MekkeMedineSaatiScreen({super.key});
  @override
  State<MekkeMedineSaatiScreen> createState() => _MekkeMedineSaatiScreenState();
}

class _MekkeMedineSaatiScreenState extends State<MekkeMedineSaatiScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  late Timer _timer;
  DateTime _nowUtc = DateTime.now().toUtc();
  final _service = EzanVaktiService();
  late Future<VakitGun> _mekkeFuture;
  late Future<VakitGun> _medineFuture;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _nowUtc = DateTime.now().toUtc()));
    _mekkeFuture = _service.fetchBugun(EzanVaktiService.mekkaId);
    _medineFuture = _service.fetchBugun(EzanVaktiService.medineId);
  }

  @override
  void dispose() {
    _tab.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _mekkeFuture = _service.fetchBugun(EzanVaktiService.mekkaId);
      _medineFuture = _service.fetchBugun(EzanVaktiService.medineId);
    });
  }

  DateTime get _riyadh => _nowUtc.add(const Duration(hours: 3));
  String _two(int n) => n.toString().padLeft(2, '0');
  String _timeStr(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}:${_two(d.second)}';
  String _dateStr(DateTime d) {
    const aylar = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    const gunler = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    return '${d.day} ${aylar[d.month - 1]} ${d.year} ${gunler[d.weekday - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mekke & Medine'),
        actions: [IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _refresh, tooltip: 'Yenile')],
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppTheme.gold,
          tabs: const [
            Tab(icon: Icon(Icons.mosque_rounded, size: 18), text: 'Mekke'),
            Tab(icon: Icon(Icons.mosque_outlined, size: 18), text: 'Medine'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _SehirTab(
            sehir: 'Mekke',
            aciklama: 'Mescid-i Haram • Kâbe • 21.3891°N 39.8579°E',
            icon: Icons.mosque_rounded,
            gradient: const [Color(0xFF0D5C3D), Color(0xFF1B8A5A)],
            riyadh: _riyadh,
            timeStr: _timeStr(_riyadh),
            dateStr: _dateStr(_riyadh),
            hicri: miladiToHicri(_riyadh),
            future: _mekkeFuture,
            onRefresh: _refresh,
          ),
          _SehirTab(
            sehir: 'Medine',
            aciklama: 'Mescid-i Nebevi • Ravza • 24.4672°N 39.6111°E',
            icon: Icons.mosque_outlined,
            gradient: const [Color(0xFF4A148C), Color(0xFF7B1FA2)],
            riyadh: _riyadh,
            timeStr: _timeStr(_riyadh),
            dateStr: _dateStr(_riyadh),
            hicri: miladiToHicri(_riyadh),
            future: _medineFuture,
            onRefresh: _refresh,
          ),
        ],
      ),
    );
  }
}

class _SehirTab extends StatelessWidget {
  final String sehir, aciklama, timeStr, dateStr, hicri;
  final IconData icon;
  final List<Color> gradient;
  final DateTime riyadh;
  final Future<VakitGun> future;
  final VoidCallback onRefresh;
  const _SehirTab({required this.sehir, required this.aciklama, required this.icon, required this.gradient, required this.riyadh, required this.timeStr, required this.dateStr, required this.hicri, required this.future, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SaatKart(sehir: sehir, aciklama: aciklama, icon: icon, gradient: gradient, time: riyadh, timeStr: timeStr, dateStr: dateStr, hicri: hicri),
          const SizedBox(height: 14),
          FutureBuilder<VakitGun>(
            future: future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                  child: const Center(child: Column(children: [CircularProgressIndicator(), SizedBox(height: 8), Text('ezanvakti.emushaf.net yükleniyor...', style: TextStyle(fontSize: 11))])), 
                );
              }
              if (snap.hasError) {
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.red.shade200)),
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_off_rounded, color: Colors.red),
                      const SizedBox(height: 6),
                      Text('Vakit alınamadı: ${snap.error}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(icon: const Icon(Icons.refresh_rounded, size: 16), label: const Text('Tekrar Dene', style: TextStyle(fontSize: 12)), onPressed: onRefresh, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Kaynak: ezanvakti.emushaf.net/vakitler/${sehir == "Mekke" ? "16309" : "16308"} • Diyanet', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                    ],
                  ),
                );
              }
              final v = snap.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 14, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      Expanded(child: Text('${v.miladiUzun} • ${v.hicriUzun}', style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w600))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _VakitGrid(vakit: v),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.goldLight, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.verified_rounded, size: 12, color: AppTheme.goldDark), const SizedBox(width: 4), Text('Kaynak: ezanvakti.emushaf.net • Diyanet İşleri', style: TextStyle(fontSize: 10, color: Colors.grey.shade700))]),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.music_note_rounded, size: 16),
                      label: const Text('Ezan Sesleri (9) • İndir & Dinle', style: TextStyle(fontSize: 12)),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EzanSesleriScreen())),
                      style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SaatKart extends StatelessWidget {
  final String sehir, aciklama, timeStr, dateStr, hicri;
  final IconData icon;
  final List<Color> gradient;
  final DateTime time;
  const _SaatKart({required this.sehir, required this.aciklama, required this.icon, required this.gradient, required this.time, required this.timeStr, required this.dateStr, required this.hicri});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: gradient.first.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.white, size: 22)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(sehir, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)), Text(aciklama, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11))])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)), child: const Text('UTC+3 AST', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(width: 90, height: 90, child: CustomPaint(painter: _AnalogPainter(time: time))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(timeStr, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 1)), Text(dateStr, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)), child: Text(hicri, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)))])),
            ],
          ),
        ],
      ),
    );
  }
}

class _VakitGrid extends StatelessWidget {
  final VakitGun vakit;
  const _VakitGrid({required this.vakit});
  @override
  Widget build(BuildContext context) {
    final items = [
      _VakitItem(label: 'İmsak', time: vakit.imsak, icon: Icons.nights_stay_rounded, color: const Color(0xFF263238)),
      _VakitItem(label: 'Güneş', time: vakit.gunes, icon: Icons.wb_sunny_rounded, color: const Color(0xFFE65100)),
      _VakitItem(label: 'Öğle', time: vakit.ogle, icon: Icons.wb_sunny_outlined, color: const Color(0xFF1565C0)),
      _VakitItem(label: 'İkindi', time: vakit.ikindi, icon: Icons.cloud_rounded, color: const Color(0xFF00695C)),
      _VakitItem(label: 'Akşam', time: vakit.aksam, icon: Icons.bedtime_rounded, color: const Color(0xFF4A148C)),
      _VakitItem(label: 'Yatsı', time: vakit.yatsi, icon: Icons.nights_stay_outlined, color: const Color(0xFF37474F)),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.15),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final it = items[i];
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: it.color.withValues(alpha: 0.15)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: it.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(it.icon, size: 16, color: it.color)),
              const SizedBox(height: 6),
              Text(it.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: it.color)),
              Text(it.time, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ],
          ),
        );
      },
    );
  }
}

class _VakitItem {
  final String label, time;
  final IconData icon;
  final Color color;
  _VakitItem({required this.label, required this.time, required this.icon, required this.color});
}

class _AnalogPainter extends CustomPainter {
  final DateTime time;
  _AnalogPainter({required this.time});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;
    final bg = Paint()..color = Colors.white.withValues(alpha: 0.95)..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bg);
    final border = Paint()..color = Colors.white.withValues(alpha: 0.9)..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawCircle(center, radius, border);
    final tick = Paint()..color = const Color(0xFF0D5C3D).withValues(alpha: 0.7)..strokeWidth = 1.5..strokeCap = StrokeCap.round;
    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi / 6 - math.pi / 2;
      final p1 = Offset(center.dx + (radius - 6) * math.cos(angle), center.dy + (radius - 6) * math.sin(angle));
      final p2 = Offset(center.dx + (radius - 2) * math.cos(angle), center.dy + (radius - 2) * math.sin(angle));
      canvas.drawLine(p1, p2, tick);
    }
    final hour = (time.hour % 12) + time.minute / 60.0;
    final hourAngle = hour * math.pi / 6 - math.pi / 2;
    final hourPaint = Paint()..color = const Color(0xFF0D5C3D)..strokeWidth = 3..strokeCap = StrokeCap.round;
    canvas.drawLine(center, Offset(center.dx + (radius * 0.45) * math.cos(hourAngle), center.dy + (radius * 0.45) * math.sin(hourAngle)), hourPaint);
    final minuteAngle = time.minute * math.pi / 30 - math.pi / 2;
    final minPaint = Paint()..color = const Color(0xFF1B8A5A)..strokeWidth = 2..strokeCap = StrokeCap.round;
    canvas.drawLine(center, Offset(center.dx + (radius * 0.65) * math.cos(minuteAngle), center.dy + (radius * 0.65) * math.sin(minuteAngle)), minPaint);
    final secAngle = time.second * math.pi / 30 - math.pi / 2;
    final secPaint = Paint()..color = Colors.red.shade600..strokeWidth = 1..strokeCap = StrokeCap.round;
    canvas.drawLine(center, Offset(center.dx + (radius * 0.75) * math.cos(secAngle), center.dy + (radius * 0.75) * math.sin(secAngle)), secPaint);
    canvas.drawCircle(center, 3, Paint()..color = const Color(0xFF0D5C3D));
  }
  @override
  bool shouldRepaint(covariant _AnalogPainter oldDelegate) => oldDelegate.time.second != time.second || oldDelegate.time.minute != time.minute;
}
