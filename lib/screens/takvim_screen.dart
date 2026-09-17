import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/takvim_data.dart';
import '../theme/app_theme.dart';

class TakvimScreen extends StatefulWidget {
  const TakvimScreen({super.key});
  @override
  State<TakvimScreen> createState() => _TakvimScreenState();
}

class _TakvimScreenState extends State<TakvimScreen> {
  DateTime secili = DateTime.now();
  int ay = DateTime.now().month;
  int yil = DateTime.now().year;
  Set<String> bildirimAcik = {};

  @override
  void initState() {
    super.initState();
    ay = secili.month;
    yil = secili.year;
    _loadBildirim();
  }

  Future<void> _loadBildirim() async {
    final p = await SharedPreferences.getInstance();
    setState(() => bildirimAcik = p.getStringList('takvim_bildirim')?.toSet() ?? diniGunler2026.where((g) => g.bildirimVarsayilan).map((g) => g.ad).toSet());
  }

  Future<void> _toggleBildirim(String ad) async {
    final p = await SharedPreferences.getInstance();
    setState(() => bildirimAcik.contains(ad) ? bildirimAcik.remove(ad) : bildirimAcik.add(ad));
    await p.setStringList('takvim_bildirim', bildirimAcik.toList());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(bildirimAcik.contains(ad) ? '$ad bildirimi açıldı' : '$ad bildirimi kapatıldı'), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final hicriStr = miladiToHicri(secili);
    final yakin = yakinDiniGunler(limit: 5);
    final ayGunler = _ayGunleri(yil, ay);
    final ayDiniGunler = diniGunler2026.where((g) => g.miladi.month == ay && g.miladi.year == yil).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('İslami Takvim')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hicri/Gregoryen kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF1B8A5A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('MİLADİ', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('${secili.day} ${_ayAdi(secili.month)} ${secili.year}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                            Text(_haftaGunu(secili.weekday), style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                        child: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 20),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('HİCRİ', style: TextStyle(color: AppTheme.gold.withValues(alpha: 0.9), fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(hicriStr, style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w800, fontSize: 15), textAlign: TextAlign.end),
                            Text('Hicri takvim', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                    child: Text('Seçili gün: ${secili.day}.${secili.month}.${secili.year}  •  Hicri: $hicriStr', style: const TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Hicri -> Miladi çevirici
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppTheme.goldLight, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.transform_rounded, size: 16, color: AppTheme.goldDark)), const SizedBox(width: 8), const Text('Tarih Dönüştürücü', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))]),
                  const SizedBox(height: 10),
                  Text('Bir güne dokunun, Hicri karşılığını yukarıda görün. Hicri aylar yaklaşık hesaptır, gerçek rasata göre ±1 gün değişebilir.', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Text('Dönüşüm: Miladi → Hicri algoritması (tabular, Kuwaiti). Diyanet takvimine yakındır.', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Ay seçici + takvim grid
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(icon: const Icon(Icons.chevron_left_rounded), onPressed: () => setState(() { if (ay == 1) { ay = 12; yil--; } else { ay--; } })),
                      Text('${_ayAdi(ay)} $yil', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.primaryDark)),
                      IconButton(icon: const Icon(Icons.chevron_right_rounded), onPressed: () => setState(() { if (ay == 12) { ay = 1; yil++; } else { ay++; } })),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [Text('Pt', style: _haftaStyle), Text('Sa', style: _haftaStyle), Text('Ça', style: _haftaStyle), Text('Pe', style: _haftaStyle), Text('Cu', style: _haftaStyle), Text('Ct', style: _haftaStyleRed), Text('Pz', style: _haftaStyleRed)]),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.1, crossAxisSpacing: 4, mainAxisSpacing: 4),
                    itemCount: ayGunler.length,
                    itemBuilder: (context, i) {
                      final d = ayGunler[i];
                      if (d == null) return const SizedBox();
                      final isSelected = d.day == secili.day && d.month == ay && d.year == yil;
                      final isToday = d.day == DateTime.now().day && d.month == DateTime.now().month && d.year == DateTime.now().year;
                      final dini = diniGunler2026.any((g) => g.miladi.day == d.day && g.miladi.month == d.month && g.miladi.year == d.year);
                      final isKandil = diniGunler2026.any((g) => g.miladi.day == d.day && g.miladi.month == d.month && g.miladi.year == d.year && g.kategori == 'Kandil');
                      return InkWell(
                        onTap: () => setState(() => secili = d),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primary : (isKandil ? AppTheme.goldLight : (isToday ? AppTheme.primaryLight : Colors.grey.shade50)),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isSelected ? AppTheme.primary : (dini ? AppTheme.gold.withValues(alpha: 0.4) : Colors.transparent)),
                          ),
                          child: Stack(
                            children: [
                              Center(child: Text('${d.day}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isSelected ? Colors.white : (isKandil ? AppTheme.goldDark : Colors.black87)))),
                              if (dini)
                                Positioned(
                                  bottom: 3,
                                  left: 0,
                                  right: 0,
                                  child: Center(child: Container(width: 6, height: 6, decoration: BoxDecoration(color: isSelected ? Colors.white : (isKandil ? AppTheme.gold : AppTheme.primary), shape: BoxShape.circle))),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  if (ayDiniGunler.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Align(alignment: Alignment.centerLeft, child: Text('Bu ay: ${ayDiniGunler.map((e) => e.ad).join(', ')}', style: const TextStyle(fontSize: 11, color: AppTheme.goldDark, fontWeight: FontWeight.w600))),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Yaklaşan Dini Günler', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...yakin.map((g) => _DiniGunCard(gun: g, bildirimAcik: bildirimAcik.contains(g.ad), onToggle: () => _toggleBildirim(g.ad))),
            const SizedBox(height: 16),
            Text('Tüm Dini Günler (2026-2027)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
            const SizedBox(height: 8),
            ...diniGunler2026.map((g) => _DiniGunCard(gun: g, bildirimAcik: bildirimAcik.contains(g.ad), onToggle: () => _toggleBildirim(g.ad), compact: true)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.goldLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_rounded, size: 18, color: AppTheme.goldDark),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Bildirimler: Kandil gecesinden 1 gün önce saat 19:00’da hatırlatma gönderilir. Hicri tarihler gözleme dayalı olduğundan Diyanet duyurusunu takip edin.', style: TextStyle(fontSize: 11, color: Colors.grey.shade800, height: 1.4))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DateTime?> _ayGunleri(int yil, int ay) {
    final first = DateTime(yil, ay, 1);
    final startWeekday = first.weekday; // 1=Mon
    final daysInMonth = DateTime(yil, ay + 1, 0).day;
    final list = <DateTime?>[];
    for (int i = 1; i < startWeekday; i++) {
      list.add(null);
    }
    for (int d = 1; d <= daysInMonth; d++) {
      list.add(DateTime(yil, ay, d));
    }
    while (list.length % 7 != 0) {
      list.add(null);
    }
    return list;
  }

  String _ayAdi(int m) => const ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'][m - 1];
  String _haftaGunu(int w) => const ['', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'][w];
}

const TextStyle _haftaStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey);
const TextStyle _haftaStyleRed = TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.red);

class _DiniGunCard extends StatelessWidget {
  final DiniGun gun;
  final bool bildirimAcik;
  final VoidCallback onToggle;
  final bool compact;
  const _DiniGunCard({required this.gun, required this.bildirimAcik, required this.onToggle, this.compact = false});

  Color get kategoriRenk {
    switch (gun.kategori) {
      case 'Kandil':
        return const Color(0xFF8D6E1F);
      case 'Bayram':
        return const Color(0xFF0D5C3D);
      default:
        return const Color(0xFF1565C0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = gun.miladi.difference(now).inDays;
    final yakin = diff >= 0 && diff <= 30;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(compact ? 10 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: yakin ? kategoriRenk.withValues(alpha: 0.4) : Colors.grey.shade200),
        boxShadow: yakin ? [BoxShadow(color: kategoriRenk.withValues(alpha: 0.08), blurRadius: 8)] : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: kategoriRenk.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(gun.icon, color: kategoriRenk, size: compact ? 18 : 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: kategoriRenk.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)), child: Text(gun.kategori, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: kategoriRenk))),
                  const SizedBox(width: 6),
                  Text('${gun.miladi.day} ${_ayAdi(gun.miladi.month)} ${gun.miladi.year}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                  if (yakin) ...[const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20)), child: Text(diff == 0 ? 'Bugün' : '$diff gün', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.red.shade700)))],
                ]),
                const SizedBox(height: 4),
                Text(gun.ad, style: TextStyle(fontWeight: FontWeight.w700, fontSize: compact ? 13 : 14)),
                Text(gun.hicri, style: TextStyle(fontSize: 11, color: kategoriRenk, fontWeight: FontWeight.w600)),
                if (!compact) ...[const SizedBox(height: 4), Text(gun.aciklama, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4))],
              ],
            ),
          ),
          Column(children: [
            Switch(value: bildirimAcik, activeThumbColor: kategoriRenk, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, onChanged: (_) => onToggle()),
            Text(bildirimAcik ? 'Açık' : 'Kapalı', style: TextStyle(fontSize: 10, color: bildirimAcik ? kategoriRenk : Colors.grey, fontWeight: FontWeight.w600)),
          ]),
        ],
      ),
    );
  }

  String _ayAdi(int m) => const ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'][m - 1];
}
