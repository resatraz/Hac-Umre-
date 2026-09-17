import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../theme/app_theme.dart';
import '../../services/quran_api_service.dart';

// Elifba 28 harf
class _ElifbaHarf {
  final String harf;
  final String isim;
  final String okunus;
  final String ornek;
  const _ElifbaHarf(this.harf, this.isim, this.okunus, this.ornek);
}

const _elifba = [
  _ElifbaHarf('ا', 'Elif', 'e', 'أَسَدٌ (esed)'),
  _ElifbaHarf('ب', 'Be', 'be', 'بَيْتٌ (beyt)'),
  _ElifbaHarf('ت', 'Te', 'te', 'تَمْرٌ (temr)'),
  _ElifbaHarf('ث', 'Se', 'se', 'ثَوْبٌ (sevb)'),
  _ElifbaHarf('ج', 'Cim', 'cim', 'جَمَلٌ (cemel)'),
  _ElifbaHarf('ح', 'Ha', 'ha', 'حُبٌّ (hub)'),
  _ElifbaHarf('خ', 'Hı', 'hı', 'خُبْزٌ (hubz)'),
  _ElifbaHarf('د', 'Dal', 'dal', 'دَرْسٌ (ders)'),
  _ElifbaHarf('ذ', 'Zel', 'zel', 'ذَهَبٌ (zeheb)'),
  _ElifbaHarf('ر', 'Ra', 'ra', 'رَأْسٌ (re’s)'),
  _ElifbaHarf('ز', 'Ze', 'ze', 'زَيْتٌ (zeyt)'),
  _ElifbaHarf('س', 'Sin', 'sin', 'سَمَاءٌ (sema)'),
  _ElifbaHarf('ش', 'Şın', 'şın', 'شَمْسٌ (şems)'),
  _ElifbaHarf('ص', 'Sad', 'sad', 'صَبْرٌ (sabr)'),
  _ElifbaHarf('ض', 'Dad', 'dad', 'ضَوْءٌ (dav)'),
  _ElifbaHarf('ط', 'Tı', 'tı', 'طَيْرٌ (tayr)'),
  _ElifbaHarf('ظ', 'Zı', 'zı', 'ظِلٌّ (zıll)'),
  _ElifbaHarf('ع', 'Ayn', 'ayn', 'عِلْمٌ (ilm)'),
  _ElifbaHarf('غ', 'Gayn', 'gayn', 'غَيْمٌ (gaym)'),
  _ElifbaHarf('ف', 'Fe', 'fe', 'فَجْرٌ (fecr)'),
  _ElifbaHarf('ق', 'Kaf', 'kaf', 'قَمَرٌ (kamer)'),
  _ElifbaHarf('ك', 'Kef', 'kef', 'كِتَابٌ (kitab)'),
  _ElifbaHarf('ل', 'Lam', 'lam', 'لَيْلٌ (leyl)'),
  _ElifbaHarf('م', 'Mim', 'mim', 'مَاءٌ (ma)'),
  _ElifbaHarf('ن', 'Nun', 'nun', 'نُورٌ (nur)'),
  _ElifbaHarf('ه', 'He', 'he', 'هَدِيَّةٌ (hediyye)'),
  _ElifbaHarf('و', 'Vav', 'vav', 'وَرْدٌ (verd)'),
  _ElifbaHarf('ي', 'Ye', 'ye', 'يَدٌ (yed)'),
];

class KuranElifbaScreen extends StatefulWidget {
  const KuranElifbaScreen({super.key});
  @override
  State<KuranElifbaScreen> createState() => _KuranElifbaScreenState();
}

class _KuranElifbaScreenState extends State<KuranElifbaScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _api = QuranApiService();
  final _tts = FlutterTts();
  Hafiz _hafiz = hafizlar.first;
  bool _otomatikElifba = false;
  int _elifbaIndex = 0;
  Timer? _elifbaTimer;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    _tts.setLanguage('ar-SA');
    _tts.setSpeechRate(0.35);
  }

  @override
  void dispose() {
    _tab.dispose();
    _elifbaTimer?.cancel();
    _tts.stop();
    super.dispose();
  }

  void _toggleOtomatik() {
    setState(() => _otomatikElifba = !_otomatikElifba);
    _elifbaTimer?.cancel();
    if (_otomatikElifba) {
      _elifbaTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        setState(() => _elifbaIndex = (_elifbaIndex + 1) % _elifba.length);
        _tts.speak(_elifba[_elifbaIndex].harf);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kur\'an-ı Kerim & Elifba'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppTheme.gold,
          tabs: const [
            Tab(icon: Icon(Icons.menu_book_rounded, size: 18), text: 'Kur\'an'),
            Tab(icon: Icon(Icons.text_fields_rounded, size: 18), text: 'Elifba 28'),
            Tab(icon: Icon(Icons.headset_rounded, size: 18), text: 'Dinle'),
            Tab(icon: Icon(Icons.task_alt_rounded, size: 18), text: 'Hatim'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _KuranTab(api: _api, hafiz: _hafiz, onHafiz: (h) => setState(() => _hafiz = h)),
          _ElifbaTab(elifbaIndex: _elifbaIndex, otomatik: _otomatikElifba, onToggle: _toggleOtomatik, onSelect: (i) => setState(() => _elifbaIndex = i), tts: _tts),
          _DinleTab(hafiz: _hafiz, onHafiz: (h) => setState(() => _hafiz = h)),
          const _HatimTab(),
        ],
      ),
    );
  }
}

class _KuranTab extends StatefulWidget {
  final QuranApiService api;
  final Hafiz hafiz;
  final ValueChanged<Hafiz> onHafiz;
  const _KuranTab({required this.api, required this.hafiz, required this.onHafiz});
  @override
  State<_KuranTab> createState() => _KuranTabState();
}

class _KuranTabState extends State<_KuranTab> {
  late Future<List<Map<String, dynamic>>> _future;
  String _search = '';
  bool _mushaf = false;

  @override
  void initState() {
    super.initState();
    _future = widget.api.fetchSurahList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(hintText: 'Sure ara (Türkçe karakterle)', prefixIcon: const Icon(Icons.search_rounded, size: 18), isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                      style: const TextStyle(fontSize: 12),
                      onChanged: (v) => setState(() => _search = v.toLowerCase()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SegmentedButton<bool>(
                    segments: const [ButtonSegment(value: false, label: Text('Sure', style: TextStyle(fontSize: 11))), ButtonSegment(value: true, label: Text('Mushaf', style: TextStyle(fontSize: 11)))],
                    selected: {_mushaf},
                    onSelectionChanged: (s) => setState(() => _mushaf = s.first),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_rounded, size: 14, color: AppTheme.primary),
                  const SizedBox(width: 4),
                  const Text('Hafız', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: widget.hafiz.edition,
                      isDense: true,
                      style: const TextStyle(fontSize: 11, color: AppTheme.primaryDark, fontWeight: FontWeight.w700),
                      items: hafizlar.map((h) => DropdownMenuItem(value: h.edition, child: Text(h.display))).toList(),
                      onChanged: (v) => widget.onHafiz(hafizlar.firstWhere((e) => e.edition == v)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _mushaf
              ? _MushafView(hafiz: widget.hafiz)
              : FutureBuilder<List<Map<String, dynamic>>>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (snap.hasError) return Center(child: Text('Hata: ${snap.error}', style: const TextStyle(fontSize: 12)));
                    var list = snap.data ?? [];
                    if (_search.isNotEmpty) {
                      list = list.where((s) => (s['englishName'] ?? '').toString().toLowerCase().contains(_search) || (s['name'] ?? '').toString().contains(_search) || '${s['number']}'.contains(_search)).toList();
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(10),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final s = list[i];
                        return _SurahTile(surah: s, hafiz: widget.hafiz);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SurahTile extends StatelessWidget {
  final Map<String, dynamic> surah;
  final Hafiz hafiz;
  const _SurahTile({required this.surah, required this.hafiz});
  @override
  Widget build(BuildContext context) {
    final num = surah['number'] as int;
    final name = surah['name'] ?? '';
    final en = surah['englishName'] ?? '';
    final tr = surah['englishNameTranslation'] ?? '';
    final ayahs = surah['numberOfAyahs'] ?? 0;
    final type = surah['revelationType'] ?? '';
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _SurahDetail(surahNumber: num, surahName: '$en ($name)', hafiz: hafiz))),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2))), child: Center(child: Text('$num', style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary, fontSize: 12)))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(en, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), Text('$tr • $ayahs ayet • $type', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)), Text(name, style: const TextStyle(fontSize: 13, color: AppTheme.primaryDark))])),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SurahDetail extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final Hafiz hafiz;
  const _SurahDetail({required this.surahNumber, required this.surahName, required this.hafiz});
  @override
  State<_SurahDetail> createState() => _SurahDetailState();
}

class _SurahDetailState extends State<_SurahDetail> {
  late Future<List<QuranAyah>> _future;
  @override
  void initState() { super.initState(); _future = QuranApiService().fetchSurah(widget.surahNumber, widget.hafiz.edition); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.surahName)),
      body: FutureBuilder<List<QuranAyah>>(future: _future, builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snap.hasError) return Center(child: Text('Hata: ${snap.error}'));
        final ayahs = snap.data ?? [];
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: ayahs.length,
          separatorBuilder: (_, _) => const Divider(height: 12),
          itemBuilder: (context, i) {
            final a = ayahs[i];
            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text(a.text, textAlign: TextAlign.right, style: const TextStyle(fontSize: 18, height: 1.8, color: AppTheme.primaryDark)), const SizedBox(height: 4), Text('${a.numberInSurah} • ${a.surahName}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600))]);
          },
        );
      }),
    );
  }
}

class _MushafView extends StatelessWidget {
  final Hafiz hafiz;
  const _MushafView({required this.hafiz});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 340,
              decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_stories_rounded, size: 40, color: AppTheme.goldDark),
                  const SizedBox(height: 8),
                  Text('Mushaf Görünümü', style: Theme.of(context).textTheme.titleMedium),
                  Text('604 sayfa • ${hafiz.display}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 12),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3))), child: const Text('Sayfa 1 • El-Fatiha', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('Mushaf sayfa bazlı okuma — her sayfa orijinal hatla', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

class _ElifbaTab extends StatelessWidget {
  final int elifbaIndex;
  final bool otomatik;
  final VoidCallback onToggle;
  final ValueChanged<int> onSelect;
  final FlutterTts tts;
  const _ElifbaTab({required this.elifbaIndex, required this.otomatik, required this.onToggle, required this.onSelect, required this.tts});

  @override
  Widget build(BuildContext context) {
    final cur = _elifba[elifbaIndex];
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 14, color: AppTheme.primary),
              const SizedBox(width: 6),
              const Expanded(child: Text('28 ders • Otomatik/manuel • Kelime kelime', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
              Switch(value: otomatik, activeThumbColor: AppTheme.primary, onChanged: (_) => onToggle()),
              Text(otomatik ? 'Otomatik' : 'Manuel', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(gradient: AppTheme.proGradient, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10)]),
          child: Column(
            children: [
              Text(cur.harf, style: const TextStyle(fontSize: 56, color: Colors.white, fontWeight: FontWeight.w800)),
              Text(cur.isim, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              Text('Okunuş: ${cur.okunus} • ${cur.ornek}', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
              const SizedBox(height: 10),
              ElevatedButton.icon(icon: const Icon(Icons.volume_up_rounded, size: 16), label: const Text('Dinle', style: TextStyle(fontSize: 12)), onPressed: () => tts.speak(cur.harf), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primary)),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.85),
            itemCount: _elifba.length,
            itemBuilder: (context, i) {
              final h = _elifba[i];
              final sel = i == elifbaIndex;
              return InkWell(
                onTap: () { onSelect(i); tts.speak(h.harf); },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(color: sel ? AppTheme.primary : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? AppTheme.primary : Colors.grey.shade200)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(h.harf, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: sel ? Colors.white : AppTheme.primaryDark)), Text(h.isim, style: TextStyle(fontSize: 10, color: sel ? Colors.white : Colors.grey.shade700)), Text(h.okunus, style: TextStyle(fontSize: 9, color: sel ? Colors.white70 : Colors.grey.shade500))]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DinleTab extends StatelessWidget {
  final Hafiz hafiz;
  final ValueChanged<Hafiz> onHafiz;
  const _DinleTab({required this.hafiz, required this.onHafiz});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15))),
          child: Row(children: [const Icon(Icons.headset_rounded, color: AppTheme.primary, size: 18), const SizedBox(width: 8), const Expanded(child: Text('Radyo • Arka planda çalma • Ses kalitesi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))), DropdownButtonHideUnderline(child: DropdownButton<String>(value: hafiz.edition, isDense: true, style: const TextStyle(fontSize: 11, color: AppTheme.primaryDark, fontWeight: FontWeight.w700), items: hafizlar.map((h) => DropdownMenuItem(value: h.edition, child: Text(h.display))).toList(), onChanged: (v) => onHafiz(hafizlar.firstWhere((e) => e.edition == v))))]),
        ),
        const SizedBox(height: 12),
        ...List.generate(6, (i) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.goldLight, borderRadius: BorderRadius.circular(8)), child: Icon([Icons.play_circle_rounded, Icons.radio_rounded, Icons.queue_music_rounded, Icons.volume_up_rounded, Icons.playlist_play_rounded, Icons.shuffle_rounded][i], color: AppTheme.goldDark, size: 18)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(['Fatiha - Alafasy', 'Quran Radio', 'Cüz 30', 'Yasin', 'Kısa Sureler', 'Otomatik ilerleme'][i], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)), Text(['128 kbps • Diyanet', 'Canlı • Mekke', '30. cüz', '36. sure', 'İhlas-Felak-Nas', 'Sıralı çalma'][i], style: TextStyle(fontSize: 11, color: Colors.grey.shade600))])), const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey)]),
            )),
      ],
    );
  }
}

class _HatimTab extends StatefulWidget {
  const _HatimTab();
  @override
  State<_HatimTab> createState() => _HatimTabState();
}

class _HatimTabState extends State<_HatimTab> {
  double _progress = 0.35;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() => _progress = p.getDouble('hatim_progress') ?? 0.35);
  }

  Future<void> _save(double v) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble('hatim_progress', v);
    setState(() => _progress = v);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(gradient: AppTheme.proGradient, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [const Icon(Icons.task_alt_rounded, color: Colors.white, size: 18), const SizedBox(width: 6), const Text('Hatim Takibi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)), const Spacer(), Text('%${(_progress * 100).toInt()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18))]),
              const SizedBox(height: 10),
              ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: _progress, minHeight: 8, backgroundColor: Colors.white.withValues(alpha: 0.3), color: Colors.white)),
              const SizedBox(height: 8),
              Text('${(604 * _progress).toInt()} / 604 sayfa', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Slider(value: _progress, onChanged: _save, activeColor: AppTheme.primary),
        ...[
          _HatimRow(icon: Icons.bookmark_rounded, title: 'Son okunan: Bakara 255', subtitle: 'Ayetel Kürsi • 2:255', trailing: 'Bugün'),
          _HatimRow(icon: Icons.notifications_rounded, title: 'Günlük hatırlatma', subtitle: 'Her gün 20:00', trailing: 'Açık', onTap: () {}),
          _HatimRow(icon: Icons.share_rounded, title: 'Paylaş', subtitle: 'Ayet metin/görsel', trailing: '>'),
        ],
      ],
    );
  }
}

class _HatimRow extends StatelessWidget {
  final IconData icon;
  final String title, subtitle, trailing;
  final VoidCallback? onTap;
  const _HatimRow({required this.icon, required this.title, required this.subtitle, required this.trailing, this.onTap});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 16, color: AppTheme.primary)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)), Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600))])), Text(trailing, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600))]),
          ),
        ),
      );
}
