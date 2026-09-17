import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/zikir_data.dart';
import '../theme/app_theme.dart';
import '../services/audio_service.dart';

class ZikirmatikScreen extends StatefulWidget {
  const ZikirmatikScreen({super.key});
  @override
  State<ZikirmatikScreen> createState() => _ZikirmatikScreenState();
}

class _ZikirmatikScreenState extends State<ZikirmatikScreen> with SingleTickerProviderStateMixin {
  late TabController tab;
  @override
  void initState() { super.initState(); tab = TabController(length: 4, vsync: this); }
  @override
  void dispose() { tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zikirmatik & Tesbihat'),
        bottom: TabBar(
          controller: tab,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppTheme.gold,
          tabs: const [
            Tab(icon: Icon(Icons.touch_app_rounded, size: 18), text: 'Zikirmatik'),
            Tab(icon: Icon(Icons.list_alt_rounded, size: 18), text: 'Tesbihat'),
            Tab(icon: Icon(Icons.explore_rounded, size: 18), text: 'Pusula 3D'),
            Tab(icon: Icon(Icons.menu_book_rounded, size: 18), text: 'Günlük Dualar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tab,
        children: const [
          _ZikirSayacTab(),
          _TesbihatTab(),
          _Pusula3DTab(),
          _GunlukDualarTab(),
        ],
      ),
    );
  }
}

// --- TAB 1: Sayaç ---
class _ZikirSayacTab extends StatefulWidget {
  const _ZikirSayacTab();
  @override
  State<_ZikirSayacTab> createState() => _ZikirSayacTabState();
}

class _ZikirSayacTabState extends State<_ZikirSayacTab> {
  int sayac = 0;
  int toplam = 0;
  String seciliId = 'subhanallah';
  bool titresim = true;

  Zikir get secili => zikirler.firstWhere((z) => z.id == seciliId);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      sayac = p.getInt('zikir_sayac') ?? 0;
      toplam = p.getInt('zikir_toplam') ?? 0;
      seciliId = p.getString('zikir_secili') ?? 'subhanallah';
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('zikir_sayac', sayac);
    await p.setInt('zikir_toplam', toplam);
    await p.setString('zikir_secili', seciliId);
  }

  void _arttir() {
    setState(() {
      sayac++;
      toplam++;
      if (sayac >= secili.hedef) {
        // hedef doldu
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${secili.ad} ${secili.hedef} tamamlandı! Maşallah'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ));
        sayac = 0;
      }
    });
    _save();
  }

  void _sifirla() => setState(() { sayac = 0; _save(); });

  @override
  Widget build(BuildContext context) {
    final progress = sayac / secili.hedef;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Zikir seçici
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: zikirler.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final z = zikirler[i];
                final sel = z.id == seciliId;
                return ChoiceChip(
                  label: Text(z.ad),
                  selected: sel,
                  selectedColor: AppTheme.primaryLight,
                  avatar: Icon(z.icon, size: 16, color: sel ? AppTheme.primary : Colors.grey),
                  onSelected: (v) => setState(() { seciliId = z.id; sayac = 0; _save(); }),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF1B8A5A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(secili.arapca, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text(secili.okunus, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontStyle: FontStyle.italic)),
                const SizedBox(height: 4),
                Text(secili.anlam, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text(secili.fazilet, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Sayaç halka
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey.shade200,
                  color: AppTheme.primary,
                ),
              ),
              GestureDetector(
                onTap: _arttir,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15), width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$sayac', style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w800, color: AppTheme.primaryDark)),
                      Text('/ ${secili.hedef}', style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('DOKUN', style: TextStyle(fontSize: 11, letterSpacing: 1.5, color: Colors.grey.shade500, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(icon: const Icon(Icons.refresh_rounded, size: 16), label: const Text('Sıfırla'), onPressed: _sifirla, style: OutlinedButton.styleFrom(foregroundColor: Colors.grey.shade700)),
              const SizedBox(width: 10),
              ElevatedButton.icon(icon: const Icon(Icons.add_rounded), label: const Text('Zikir Çek'), onPressed: _arttir, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [Text('Toplam', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)), Text('$toplam', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.primary))]),
                Container(width: 1, height: 36, color: Colors.grey.shade200),
                Column(children: [Text('Hedef', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)), Text('${secili.hedef}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18))]),
                Container(width: 1, height: 36, color: Colors.grey.shade200),
                Column(children: [Text('Kalan', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)), Text('${secili.hedef - sayac}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.goldDark))]),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.vibration_rounded, size: 14, color: AppTheme.primary),
              const SizedBox(width: 6),
              const Text('Titreşim', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const Spacer(),
              Switch(value: titresim, activeThumbColor: AppTheme.primary, onChanged: (v) => setState(() => titresim = v)),
            ],
          ),
        ],
      ),
    );
  }
}

// --- TAB 2: Tesbihat ---
class _TesbihatTab extends StatelessWidget {
  const _TesbihatTab();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TesbihatCard(baslik: 'Namaz Tesbihatı', aciklama: 'Her farz namazdan sonra', items: namazTesbihati, color: AppTheme.primary),
        const SizedBox(height: 12),
        _TesbihatCard(baslik: 'Sabah Tesbihatı', aciklama: 'Güne başlarken', items: sabahTesbihati, color: const Color(0xFFE65100)),
        const SizedBox(height: 12),
        _TesbihatCard(baslik: 'Akşam Tesbihatı', aciklama: 'Akşam ezanından sonra', items: aksamTesbihati, color: const Color(0xFF283593)),
      ],
    );
  }
}

class _TesbihatCard extends StatefulWidget {
  final String baslik, aciklama;
  final List<TesbihatItem> items;
  final Color color;
  const _TesbihatCard({required this.baslik, required this.aciklama, required this.items, required this.color});
  @override
  State<_TesbihatCard> createState() => _TesbihatCardState();
}

class _TesbihatCardState extends State<_TesbihatCard> {
  final Set<int> done = {};
  @override
  Widget build(BuildContext context) {
    final progress = done.length / widget.items.length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: widget.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.auto_awesome_rounded, color: widget.color, size: 18)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.baslik, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)), Text(widget.aciklama, style: TextStyle(fontSize: 11, color: Colors.grey.shade600))])),
            Text('${done.length}/${widget.items.length}', style: TextStyle(fontWeight: FontWeight.w700, color: widget.color)),
          ]),
          const SizedBox(height: 10),
          ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: Colors.grey.shade200, color: widget.color)),
          const SizedBox(height: 10),
          ...List.generate(widget.items.length, (i) {
            final it = widget.items[i];
            final isDone = done.contains(i);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: isDone ? widget.color.withValues(alpha: 0.08) : Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: isDone ? widget.color.withValues(alpha: 0.3) : Colors.grey.shade200)),
              child: Row(
                children: [
                  Checkbox(value: isDone, activeColor: widget.color, onChanged: (v) => setState(() => v! ? done.add(i) : done.remove(i))),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(it.arapca, style: TextStyle(color: widget.color, fontWeight: FontWeight.w700, fontSize: 13)), Text('${it.ad} • ${it.adet} kez', style: TextStyle(fontSize: 12, color: Colors.grey.shade700, decoration: isDone ? TextDecoration.lineThrough : null))])),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)), child: Text('×${it.adet}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                ],
              ),
            );
          }),
          if (progress == 1)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: widget.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Row(children: [Icon(Icons.check_circle_rounded, color: widget.color, size: 18), const SizedBox(width: 6), Text('Tesbihat tamamlandı, Allah kabul etsin', style: TextStyle(color: widget.color, fontWeight: FontWeight.w600, fontSize: 12))]),
            ),
        ],
      ),
    );
  }
}

// --- TAB 3: 3D Pusula ---
class _Pusula3DTab extends StatefulWidget {
  const _Pusula3DTab();
  @override
  State<_Pusula3DTab> createState() => _Pusula3DTabState();
}

class _Pusula3DTabState extends State<_Pusula3DTab> with SingleTickerProviderStateMixin {
  late AnimationController ctrl;
  double heading = 0; // simulated sensor
  Timer? timer;
  bool kabeModu = true;

  @override
  void initState() {
    super.initState();
    ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    // simulate slow heading change
    timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      setState(() => heading = (heading + 0.3) % 360);
    });
  }

  @override
  void dispose() { ctrl.dispose(); timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    // Kıble açısı (Mekke'ye göre yaklaşık, İstanbul için 147°)
    const kibleAngle = 147.0;
    final relativeKible = (kibleAngle - heading) % 360;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.goldLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3))),
            child: Row(children: [
              const Icon(Icons.explore_rounded, color: AppTheme.goldDark, size: 18),
              const SizedBox(width: 8),
              const Expanded(child: Text('3D Pusula • Kıble yönünü gösterir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.goldDark))),
              Switch(value: kabeModu, activeThumbColor: AppTheme.primary, onChanged: (v) => setState(() => kabeModu = v)),
              Text(kabeModu ? 'Kıble' : 'Kuzey', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(height: 16),
          // 3D compass
          AnimatedBuilder(
            animation: ctrl,
            builder: (context, child) {
              final tilt = math.sin(ctrl.value * 2 * math.pi) * 0.08; // subtle 3D tilt
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(tilt)
                  ..rotateY(tilt * 0.5),
                child: child,
              );
            },
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)], center: Alignment.center),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5), width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 8))],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // tick marks
                  ...List.generate(36, (i) {
                    final angle = i * 10 * math.pi / 180;
                    final isMain = i % 9 == 0;
                    return Transform.rotate(
                      angle: angle,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          width: isMain ? 3 : 1,
                          height: isMain ? 14 : 8,
                          color: isMain ? AppTheme.primary : Colors.grey.shade400,
                        ),
                      ),
                    );
                  }),
                  // N E S W labels
                  Positioned(top: 18, child: Text('K', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w800, fontSize: 16))),
                  Positioned(bottom: 18, child: Text('G', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700))),
                  Positioned(left: 18, child: Text('B', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700))),
                  Positioned(right: 18, child: Text('D', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700))),
                  // heading needle (rotates with sensor)
                  Transform.rotate(
                    angle: -heading * math.pi / 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // north needle
                        Positioned(
                          top: 30,
                          child: Container(
                            width: 4,
                            height: 90,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Colors.red, Colors.redAccent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        // south
                        Positioned(
                          bottom: 30,
                          child: Container(width: 4, height: 80, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(4))),
                        ),
                        // center pivot with 3D
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(colors: [Color(0xFF0D5C3D), Color(0xFF083826)]),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6)],
                            border: Border.all(color: AppTheme.gold, width: 2),
                          ),
                          child: const Icon(Icons.mosque_rounded, color: Colors.white, size: 14),
                        ),
                      ],
                    ),
                  ),
                  // Kabe indicator
                  if (kabeModu)
                    Transform.rotate(
                      angle: relativeKible * math.pi / 180,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)]),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.mosque_rounded, color: Colors.white, size: 12), SizedBox(width: 4), Text('KÂBE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _PusulaStat(label: 'Yön', value: '${heading.toStringAsFixed(0)}°', icon: Icons.explore_rounded),
                  Container(width: 1, height: 40, color: Colors.grey.shade200),
                  _PusulaStat(label: 'Kıble', value: '${relativeKible.toStringAsFixed(0)}°', icon: Icons.mosque_rounded),
                  Container(width: 1, height: 40, color: Colors.grey.shade200),
                  _PusulaStat(label: 'Durum', value: kabeModu ? 'Aktif' : 'Kapalı', icon: Icons.check_circle_rounded),
                ]),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: kabeModu ? AppTheme.primaryLight : Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    Icon(kabeModu ? Icons.info_rounded : Icons.warning_rounded, size: 16, color: kabeModu ? AppTheme.primary : Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(child: Text(kabeModu ? 'Yeşil “KÂBE” işareti kıble yönünü gösterir. Pusulayı düz tutun.' : 'Kıble modu kapalı, sadece kuzey gösteriliyor.', style: TextStyle(fontSize: 11, color: kabeModu ? AppTheme.primaryDark : Colors.grey.shade700))),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(icon: const Icon(Icons.compass_calibration_rounded, size: 18), label: const Text('Pusula Kalibre Et'), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kalibrasyon için telefonu 8 çizin'))), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary)),
          ),
        ],
      ),
    );
  }
}

class _PusulaStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _PusulaStat({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Column(children: [Icon(icon, size: 16, color: AppTheme.primary), const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)), Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14))]);
}

// --- TAB 4: Günlük Dualar ---
class _GunlukDualarTab extends StatefulWidget {
  const _GunlukDualarTab();
  @override
  State<_GunlukDualarTab> createState() => _GunlukDualarTabState();
}

class _GunlukDualarTabState extends State<_GunlukDualarTab> {
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
    return ListView.separated(
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
                if (isPlaying)
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.graphic_eq_rounded, size: 12, color: AppTheme.primary), SizedBox(width: 4), Text('Çalıyor', style: TextStyle(fontSize: 10, color: AppTheme.primary))])),
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
    );
  }
}
