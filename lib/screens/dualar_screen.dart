import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_theme.dart';
import '../services/dua_api_service.dart';
import '../services/diyanet_service.dart';

class DualarScreen extends StatefulWidget {
  final String? initialKategori;
  const DualarScreen({super.key, this.initialKategori});
  @override
  State<DualarScreen> createState() => _DualarScreenState();
}

class _DualarScreenState extends State<DualarScreen> {
  bool showArapca = true;
  String filter = 'Tümü';
  String search = '';
  String? playingId;
  final _api = DuaApiService();
  final _diyanet = DiyanetService();
  late Future<List<ApiDua>> _future;
  List<String> apiKategoriler = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialKategori != null) filter = widget.initialKategori!;
    _future = _loadApi();
    _loadCategories();
    _testApis();
  }

  Future<void> _testApis() async {
    // Gerekli ise Diyanet test — sonucu logla, UI engelleme
    try {
      final list = await _diyanet.fetchSureList().timeout(const Duration(seconds: 8));
      debugPrint('Diyanet sure list ok ${list.length}');
    } catch (e) {
      debugPrint('Diyanet test failed $e');
    }
  }

  Future<List<ApiDua>> _loadApi() async {
    return _api.fetchAllWithFallback();
  }

  Future<void> _loadCategories() async {
    final cats = await _api.fetchCategories();
    if (mounted) setState(() => apiKategoriler = ['Tümü', ...cats]);
  }

  Future<void> _refresh() async {
    setState(() => _future = _loadApi());
    await _future;
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dualar güncellendi (API)')));
  }

  final _apiPlayer = AudioPlayer();

  Future<void> _togglePlayApi(ApiDua d) async {
    final id = d.id;
    if (playingId == id) {
      await _apiPlayer.stop();
      setState(() { playingId = null; });
      return;
    }
    final url = d.audioUrl;
    if (url == null || url.isEmpty || !url.startsWith('http')) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bu dua için orijinal ses API\'de henüz yok • İndirilip asset yapılacak')));
      return;
    }
    setState(() { playingId = id; });
    try {
      await _apiPlayer.stop();
      await _apiPlayer.setReleaseMode(ReleaseMode.stop);
      await _apiPlayer.play(UrlSource(url));
      _apiPlayer.onPlayerComplete.first.then((_) {
        if (mounted) setState(() { playingId = null; });
      });
    } catch (e) {
      if (mounted) {
        setState(() { playingId = null; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ses çalınamadı: $e')));
      }
    }
  }

  @override
  void dispose() {
    _apiPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kategoriler = apiKategoriler.isEmpty ? ['Tümü', 'hajj', 'morning', 'evening', 'travel'] : apiKategoriler;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dualar & Sesli Rehber'),
        actions: [IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _refresh, tooltip: 'API yenile')],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    SegmentedButton<bool>(
                      segments: const [ButtonSegment(value: true, label: Text('Arapça', style: TextStyle(fontSize: 11))), ButtonSegment(value: false, label: Text('Anlam', style: TextStyle(fontSize: 11)))],
                      selected: {showArapca},
                      onSelectionChanged: (s) => setState(() => showArapca = s.first),
                      style: const ButtonStyle(visualDensity: VisualDensity.compact),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Dua ara',
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  style: const TextStyle(fontSize: 12),
                  onChanged: (v) => setState(() => search = v.toLowerCase()),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.goldLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.gold.withValues(alpha: 0.25)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(gradient: AppTheme.goldGradient, borderRadius: BorderRadius.circular(20)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.workspace_premium_rounded, size: 10, color: Colors.white), const SizedBox(width: 3), Text('pro.badge'.tr(), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))]),
                          ),
                          const SizedBox(width: 6),
                          const Text('Kategori', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.goldDark)),
                          const Spacer(),
                          if (filter != 'Tümü') TextButton(onPressed: () => setState(() => filter = 'Tümü'), child: const Text('Temizle', style: TextStyle(fontSize: 11))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: kategoriler.map((k) {
                            final sel = filter == k;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(kategoriTr(k), style: TextStyle(fontSize: 11, color: sel ? Colors.white : Colors.black87)),
                                selected: sel,
                                selectedColor: AppTheme.gold,
                                backgroundColor: Colors.white,
                                side: BorderSide(color: sel ? AppTheme.gold : Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                onSelected: (v) => setState(() => filter = v ? k : 'Tümü'),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildApiList()),
        ],
      ),
    );
  }

  Widget _buildApiList() {
    return FutureBuilder<List<ApiDua>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 8), Text('API\'den dualar yükleniyor...', style: TextStyle(fontSize: 12))]));
        }
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 32, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text('API hatası: ${snap.error}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(icon: const Icon(Icons.refresh_rounded, size: 16), label: const Text('Tekrar Dene'), onPressed: _refresh, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white)),
                ],
              ),
            ),
          );
        }
        var list = snap.data ?? [];
        if (filter != 'Tümü') {
          list = list.where((d) => d.category.toLowerCase() == filter.toLowerCase()).toList();
        }
        if (search.isNotEmpty) {
          list = list.where((d) => d.title.toLowerCase().contains(search) || d.titleTr.toLowerCase().contains(search) || d.arabic.contains(search) || d.translation.toLowerCase().contains(search) || d.translationTr.toLowerCase().contains(search)).toList();
        }
        if (list.isEmpty) {
          return Center(child: Text('Sonuç yok: $filter / "$search"', style: const TextStyle(fontSize: 12)));
        }
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final d = list[i];
              final isPlaying = playingId == d.id;
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isPlaying ? AppTheme.primary.withValues(alpha: 0.4) : Colors.grey.shade200),
                  boxShadow: isPlaying ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.1), blurRadius: 10)] : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.menu_book_rounded, color: AppTheme.primary, size: 16)),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(d.titleTr.isNotEmpty ? d.titleTr : d.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), Text('${kategoriTr(d.category)} • ${d.source}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600))])),
                        IconButton(icon: Icon(isPlaying ? Icons.pause_circle_rounded : Icons.play_circle_rounded, color: AppTheme.primary, size: 30), onPressed: () => _togglePlayApi(d)),
                      ],
                    ),
                    if (isPlaying)
                      Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [const Icon(Icons.graphic_eq_rounded, size: 16, color: AppTheme.primary), const SizedBox(width: 8), const Expanded(child: Text('Orijinal ses çalınıyor • API', style: TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w700))), TextButton(onPressed: () => _togglePlayApi(d), child: const Text('Durdur', style: TextStyle(fontSize: 11)))]),
                      ),
                    const SizedBox(height: 8),
                    // PRO kart: Arapça her zaman üstte (Amiri font), altında TR/EN okunuş + anlam
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppTheme.primaryLight, Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              d.arabic.isEmpty ? '(Arapça metin API\'de yok)' : d.arabic,
                              textAlign: TextAlign.center,
                              style: AppTheme.arabic(size: 22, height: 2.0),
                            ),
                          ),
                          if (d.transliteration.isNotEmpty) ...[
                            const Divider(height: 16),
                            const Text('OKUNUŞ (TR)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.primary, letterSpacing: 1)),
                            const SizedBox(height: 4),
                            Text(trOkunus(d.transliteration), style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12, height: 1.5)),
                            const SizedBox(height: 6),
                            const Text('TRANSLITERATION (EN)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 1)),
                            const SizedBox(height: 4),
                            Text(d.transliteration, style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, height: 1.5, color: Colors.grey.shade800)),
                          ],
                          if (!showArapca) ...[
                            const Divider(height: 16),
                            const Text('TÜRKÇE ANLAM', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.primary, letterSpacing: 1)),
                            const SizedBox(height: 4),
                            if (d.translationTr.isNotEmpty && d.translationTr != d.translation)
                              Text(d.translationTr, style: const TextStyle(fontSize: 12, height: 1.5))
                            else
                              Text('(Türkçe çevirisi hazırlanıyor — İngilizce anlamı aşağıda)', style: TextStyle(fontSize: 11, height: 1.5, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                            const SizedBox(height: 8),
                            const Text('ENGLISH MEANING', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 1)),
                            const SizedBox(height: 4),
                            Text(d.translation, style: TextStyle(fontSize: 12, height: 1.5, color: Colors.grey.shade800)),
                          ] else ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppTheme.goldLight, borderRadius: BorderRadius.circular(20)),
                              child: Text('Anlam için Anlam sekmesine geç • TR + EN', style: TextStyle(fontSize: 10, color: Colors.grey.shade700)),
                            ),
                          ],
                          if (d.source.isNotEmpty) ...[const SizedBox(height: 6), Text('Kaynak: ${d.source}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontStyle: FontStyle.italic))],
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(icon: Icon(isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 14), label: Text(isPlaying ? 'Durdur' : 'Dinle', style: const TextStyle(fontSize: 11)), onPressed: () => _togglePlayApi(d), style: ElevatedButton.styleFrom(backgroundColor: isPlaying ? Colors.red.shade600 : AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), visualDensity: VisualDensity.compact)),
                        const SizedBox(width: 6),
                        OutlinedButton.icon(icon: const Icon(Icons.copy_rounded, size: 12), label: const Text('Kopyala', style: TextStyle(fontSize: 11)), onPressed: () async { await Clipboard.setData(ClipboardData(text: '${d.title}\n${d.arabic}\n${d.transliteration}\nTR: ${d.translationTr}\nEN: ${d.translation}')); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kopyalandı'))); }, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), visualDensity: VisualDensity.compact)),
                        const Spacer(),
                        if (d.audioUrl != null && d.audioUrl!.isNotEmpty)
                          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(20)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.headset_rounded, size: 10, color: AppTheme.primary), SizedBox(width: 3), Text('API', style: TextStyle(fontSize: 9, color: AppTheme.primary, fontWeight: FontWeight.w700))])),
                        const SizedBox(width: 4),
                        Text('id:${d.id}', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
