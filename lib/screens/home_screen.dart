import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../data/hac_data.dart';
import '../data/umre_data.dart';
import '../data/ziyaret_data.dart';
import '../data/takvim_data.dart';
import 'hac_rehberi_screen.dart';
import 'umre_rehberi_screen.dart';
import 'ziyaret_list_screen.dart';
import 'harita_screen.dart';
import 'dualar_screen.dart';
import 'zikirmatik_screen.dart';
import 'takvim_screen.dart';
import 'uygulama/uygulama_klasoru_screen.dart';
import 'uygulama/mekke_medine_saati_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final yakin = yakinDiniGunler(limit: 2);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 148,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0D5C3D), Color(0xFF083826)],
                  ),
                ),
                  child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text('app.title'.tr(), style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, height: 1.0, fontSize: 24))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(gradient: AppTheme.goldGradient, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6)]),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.workspace_premium_rounded, size: 12, color: Colors.white), const SizedBox(width: 4), Text('pro.badge'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10))]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('app.subtitle'.tr(), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.goldLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppTheme.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.calendar_month_rounded, color: AppTheme.goldDark, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(yakin.isNotEmpty ? 'Yaklaşan: ${yakin.first.ad}' : 'Hac 2026 için geri sayım', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13)),
                          Text(yakin.isNotEmpty ? '${yakin.first.miladi.day} ${_ayAdi(yakin.first.miladi.month)} • ${yakin.first.hicri}' : 'Arafat: 26 Mayıs 2026 • Hazırlığa bugün başlayın',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.chevron_right_rounded, color: AppTheme.goldDark), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TakvimScreen()))),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverToBoxAdapter(child: _HomeSaatKarti(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MekkeMedineSaatiScreen())))),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverList.list(
              children: [
                _ListCard(
                  title: 'home.zikirmatik'.tr(),
                  subtitle: 'home.zikirmatik_sub'.tr(),
                  count: '3D Pusula',
                  icon: Icons.touch_app_rounded,
                  gradient: const [Color(0xFF0D5C3D), Color(0xFF1B8A5A)],
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ZikirmatikScreen())),
                ),
                const SizedBox(height: 10),
                _ListCard(
                  title: 'home.takvim'.tr(),
                  subtitle: 'home.takvim_sub'.tr(),
                  count: 'Kandil Bildirim',
                  icon: Icons.calendar_month_rounded,
                  gradient: const [Color(0xFF0D5C3D), Color(0xFF1B8A5A)],
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TakvimScreen())),
                ),
                const SizedBox(height: 10),
                _ListCard(
                  title: 'home.hajj'.tr(),
                  subtitle: 'home.hajj_sub'.tr(),
                  count: '${hacAdimlari.length} Adım',
                  icon: Icons.mosque_rounded,
                  gradient: const [Color(0xFF0D5C3D), Color(0xFF1B8A5A)],
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HacRehberiScreen())),
                ),
                const SizedBox(height: 10),
                _ListCard(
                  title: 'home.umrah'.tr(),
                  subtitle: 'home.umrah_sub'.tr(),
                  count: '${umreAdimlari.length} Adım',
                  icon: Icons.spa_rounded,
                  gradient: const [Color(0xFF0D5C3D), Color(0xFF1B8A5A)],
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UmreRehberiScreen())),
                ),
                const SizedBox(height: 10),
                _ListCard(
                  title: 'home.ziyaret'.tr(),
                  subtitle: 'home.ziyaret_sub'.tr(),
                  count: '${ziyaretYerleri.length} Mekan',
                  icon: Icons.place_rounded,
                  gradient: const [Color(0xFF0D5C3D), Color(0xFF1B8A5A)],
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ZiyaretListScreen())),
                ),
                const SizedBox(height: 10),
                _ListCard(
                  title: 'home.harita'.tr(),
                  subtitle: 'home.harita_sub'.tr(),
                  count: 'Mekke • Medine',
                  icon: Icons.map_rounded,
                  gradient: const [Color(0xFF0D5C3D), Color(0xFF1B8A5A)],
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HaritaScreen())),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverToBoxAdapter(
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DualarScreen())),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.menu_book_rounded, color: AppTheme.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('home.dualar'.tr(), style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 2),
                            Text('home.dualar_sub'.tr(), style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            sliver: SliverToBoxAdapter(
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UygulamaKlasoruScreen())),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
                    boxShadow: [BoxShadow(color: AppTheme.proShadow, blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(gradient: AppTheme.proGradient, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.apps_rounded, color: Colors.white, size: 22)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('home.uygulama'.tr(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)), Text('home.uygulama_sub'.tr(), style: const TextStyle(fontSize: 11, color: Colors.grey))])),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(gradient: AppTheme.goldGradient, borderRadius: BorderRadius.circular(20)), child: Text('pro.badge'.tr(), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  String _ayAdi(int m) => const ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'][m - 1];
}

class _HomeSaatKarti extends StatefulWidget {
  final VoidCallback onTap;
  const _HomeSaatKarti({required this.onTap});
  @override
  State<_HomeSaatKarti> createState() => _HomeSaatKartiState();
}

class _HomeSaatKartiState extends State<_HomeSaatKarti> {
  late Timer _timer;
  DateTime _nowUtc = DateTime.now().toUtc();
  String _sehir = 'Mekke';
  String _aciklama = 'Mescid-i Haram • Kâbe';
  IconData _icon = Icons.mosque_rounded;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _nowUtc = DateTime.now().toUtc()));
    _loadSehir();
  }

  Future<void> _loadSehir() async {
    final p = await SharedPreferences.getInstance();
    final id = p.getInt('ezan_ilce');
    if (!mounted) return;
    setState(() {
      if (id == 16308) {
        _sehir = 'Medine';
        _aciklama = 'Mescid-i Nebevi • Ravza';
        _icon = Icons.mosque_outlined;
      } else {
        _sehir = 'Mekke';
        _aciklama = 'Mescid-i Haram • Kâbe';
        _icon = Icons.mosque_rounded;
      }
    });
  }

  Future<void> _refreshSehir() async => _loadSehir();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSehir();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final riyadh = _nowUtc.add(const Duration(hours: 3));
    final timeStr = '${riyadh.hour.toString().padLeft(2, '0')}:${riyadh.minute.toString().padLeft(2, '0')}:${riyadh.second.toString().padLeft(2, '0')}';
    const aylar = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    const gunler = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    final dateStr = '${riyadh.day} ${aylar[riyadh.month - 1]} ${riyadh.year} ${gunler[riyadh.weekday - 1]}';
    final hicri = miladiToHicri(riyadh);
    return InkWell(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const MekkeMedineSaatiScreen()));
        _refreshSehir();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0D5C3D), Color(0xFF1B8A5A)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF0D5C3D).withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(
          children: [
            Row(
              children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)), child: Icon(_icon, color: Colors.white, size: 18)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_sehir, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)), Text(_aciklama, style: const TextStyle(color: Colors.white, fontSize: 11))])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)), child: const Text('UTC+3 AST', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 18),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                SizedBox(width: 80, height: 80, child: CustomPaint(painter: _HomeAnalogPainter(time: riyadh))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(timeStr, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 1)), Text(dateStr, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)), child: Text(hicri, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)))])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeAnalogPainter extends CustomPainter {
  final DateTime time;
  _HomeAnalogPainter({required this.time});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;
    final bg = Paint()..color = Colors.white.withValues(alpha: 0.95)..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bg);
    final border = Paint()..color = Colors.white.withValues(alpha: 0.9)..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawCircle(center, radius, border);
    final tick = Paint()..color = const Color(0xFF0D5C3D).withValues(alpha: 0.7)..strokeWidth = 1.2..strokeCap = StrokeCap.round;
    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi / 6 - math.pi / 2;
      final p1 = Offset(center.dx + (radius - 5) * math.cos(angle), center.dy + (radius - 5) * math.sin(angle));
      final p2 = Offset(center.dx + (radius - 2) * math.cos(angle), center.dy + (radius - 2) * math.sin(angle));
      canvas.drawLine(p1, p2, tick);
    }
    final hour = (time.hour % 12) + time.minute / 60.0;
    final hourAngle = hour * math.pi / 6 - math.pi / 2;
    final hourPaint = Paint()..color = const Color(0xFF0D5C3D)..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    canvas.drawLine(center, Offset(center.dx + (radius * 0.45) * math.cos(hourAngle), center.dy + (radius * 0.45) * math.sin(hourAngle)), hourPaint);
    final minuteAngle = time.minute * math.pi / 30 - math.pi / 2;
    final minPaint = Paint()..color = const Color(0xFF1B8A5A)..strokeWidth = 1.8..strokeCap = StrokeCap.round;
    canvas.drawLine(center, Offset(center.dx + (radius * 0.62) * math.cos(minuteAngle), center.dy + (radius * 0.62) * math.sin(minuteAngle)), minPaint);
    final secAngle = time.second * math.pi / 30 - math.pi / 2;
    final secPaint = Paint()..color = Colors.red.shade600..strokeWidth = 1..strokeCap = StrokeCap.round;
    canvas.drawLine(center, Offset(center.dx + (radius * 0.7) * math.cos(secAngle), center.dy + (radius * 0.7) * math.sin(secAngle)), secPaint);
    canvas.drawCircle(center, 2.5, Paint()..color = const Color(0xFF0D5C3D));
  }

  @override
  bool shouldRepaint(covariant _HomeAnalogPainter oldDelegate) => oldDelegate.time.second != time.second;
}

// ignore: unused_element
class _FeaturedCard extends StatelessWidget {
  final String title, subtitle, badge;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _FeaturedCard({required this.title, required this.subtitle, required this.badge, required this.icon, required this.gradient, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: gradient.first.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: Colors.white, size: 18)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)), child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)))]),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
            Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  final String title, subtitle, count;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _ListCard({required this.title, required this.subtitle, required this.count, required this.icon, required this.gradient, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: gradient.first.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.white, size: 22)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)), const SizedBox(height: 2), Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12))])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)), child: Text(count, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _HomeCard extends StatelessWidget {
  final String title, subtitle, count;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _HomeCard({required this.title, required this.subtitle, required this.count, required this.icon, required this.gradient, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: gradient.first.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
              child: Text(count, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickChip({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: AppTheme.primary), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))]),
      ),
    );
  }
}
