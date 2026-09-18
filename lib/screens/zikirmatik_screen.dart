import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/zikir_data.dart';
import '../theme/app_theme.dart';

class ZikirmatikScreen extends StatefulWidget {
  const ZikirmatikScreen({super.key});
  @override
  State<ZikirmatikScreen> createState() => _ZikirmatikScreenState();
}

class _ZikirmatikScreenState extends State<ZikirmatikScreen> with SingleTickerProviderStateMixin {
  late TabController tab;
  @override
  void initState() { super.initState(); tab = TabController(length: 2, vsync: this); }
  @override
  void dispose() { tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zikirmatik & Tesbihat'),
        bottom: TabBar(
          controller: tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppTheme.gold,
          tabs: const [
            Tab(icon: Icon(Icons.touch_app_rounded, size: 18), text: 'Zikirmatik'),
            Tab(icon: Icon(Icons.list_alt_rounded, size: 18), text: 'Tesbihat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tab,
        children: const [
          _ZikirSayacTab(),
          _TesbihatTab(),
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
                Text(secili.arapca, style: const TextStyle(fontFamily: AppTheme.arabicFont, color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700, height: 1.8), textAlign: TextAlign.center),
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
