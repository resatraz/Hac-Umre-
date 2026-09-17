import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/dua_data.dart';
import '../theme/app_theme.dart';
import '../services/audio_service.dart';
import '../services/dua_api_service.dart';

class DualarScreen extends StatefulWidget {
  final String? initialKategori;
  const DualarScreen({super.key, this.initialKategori});
  @override
  State<DualarScreen> createState() => _DualarScreenState();
}

class _DualarScreenState extends State<DualarScreen> {
  bool showArapca = true;
  bool apiModu = true;
  String filter = 'Tümü';
  String search = '';
  String? playingId;
  final _audio = AppAudioService();
  final _api = DuaApiService();
  late Future<List<ApiDua>> _future;
  List<String> apiKategoriler = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialKategori != null) filter = widget.initialKategori!;
    _audio.init();
    _future = _loadApi();
    _loadCategories();
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

  Future<void> _togglePlayApi(ApiDua d) async {
    final id = d.id;
    if (playingId == id) {
      await _audio.stop();
      setState(() => playingId = null);
      return;
    }
    setState(() => playingId = id);
    final ok = await _audio.speak(
      id: id,
      arapca: d.arabic,
      okunus: d.transliteration,
      onDone: () {
        if (mounted) setState(() => playingId = null);
      },
    );
    if (!ok && mounted) {
      setState(() => playingId = null);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ses çalınamadı')));
    }
  }

  Future<void> _togglePlayLocal(dynamic d) async {
    final id = d.id as String;
    if (playingId == id) {
      await _audio.stop();
      setState(() => playingId = null);
      return;
    }
    setState(() => playingId = id);
    final ok = await _audio.speak(
      id: id,
      arapca: d.arapca as String,
      okunus: d.okunus as String,
      onDone: () {
        if (mounted) setState(() => playingId = null);
      },
    );
    if (!ok && mounted) {
      setState(() => playingId = null);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ses çalınamadı')));
    }
  }

  @override
  void dispose() {
    _audio.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final yerelKategoriler = ['Tümü', 'İhram', 'Tavaf', "Sa'y", 'Arafat', 'Genel', 'Medine'];
    final kategoriler = apiModu ? (apiKategoriler.isEmpty ? ['Tümü', 'hajj', 'morning', 'evening', 'travel'] : apiKategoriler) : yerelKategoriler;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dualar & Sesli Rehber'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: apiModu ? _refresh : null, tooltip: 'API yenile'),
        ],
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
                    Expanded(
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: false, icon: Icon(Icons.offline_pin_rounded, size: 14), label: Text('Yerel', style: TextStyle(fontSize: 11))),
                          ButtonSegment(value: true, icon: Icon(Icons.cloud_rounded, size: 14), label: Text('İnternetten (API)', style: TextStyle(fontSize: 11))),
                        ],
                        selected: {apiModu},
                        onSelectionChanged: (s) => setState(() => apiModu = s.first),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: true, label: Text('Arapça', style: TextStyle(fontSize: 11))),
                        ButtonSegment(value: false, label: Text('Anlam', style: TextStyle(fontSize: 11))),
                      ],
                      selected: {showArapca},
                      onSelectionChanged: (s) => setState(() => showArapca = s.first),
                      style: const ButtonStyle(visualDensity: VisualDensity.compact),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: apiModu ? 'API dualarında ara (örn: hac, sabah)' : 'Yerel dualarda ara',
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  style: const TextStyle(fontSize: 12),
                  onChanged: (v) => setState(() => search = v.toLowerCase()),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: kategoriler.map((k) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(k, style: const TextStyle(fontSize: 11)),
                            selected: filter == k,
                            selectedColor: AppTheme.primaryLight,
                            onSelected: (v) => setState(() => filter = v ? k : 'Tümü'),
                          ),
                        )).toList(),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(apiModu ? Icons.cloud_done_rounded : Icons.offline_pin_rounded, size: 12, color: AppTheme.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        apiModu ? 'UmmahAPI (126 dua) + Masnun Dua TR (1001) + Hisn al-Muslim — ücretsiz, offline önbellekli' : 'Yerel 8 dua • offline • TTS ile sesli',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: apiModu ? _buildApiList() : _buildLocalList(),
          ),
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
                  const SizedBox(height: 8),
                  OutlinedButton.icon(icon: const Icon(Icons.offline_pin_rounded, size: 16), label: const Text('Yerel duaları göster'), onPressed: () => setState(() => apiModu = false)),
                  const SizedBox(height: 8),
                  Text('İnternet yoksa yerel 8 dua offline kullanılabilir', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
          );
        }
        var list = snap.data ?? [];
        // filtre
        if (filter != 'Tümü') {
          list = list.where((d) => d.category.toLowerCase() == filter.toLowerCase()).toList();
        }
        if (search.isNotEmpty) {
          list = list.where((d) => d.title.toLowerCase().contains(search) || d.arabic.contains(search) || d.translation.toLowerCase().contains(search) || d.translationTr.toLowerCase().contains(search)).toList();
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
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(d.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), Text('${d.category} • ${d.source}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600))])),
                        IconButton(icon: Icon(isPlaying ? Icons.pause_circle_rounded : Icons.play_circle_rounded, color: AppTheme.primary, size: 30), onPressed: () => _togglePlayApi(d)),
                      ],
                    ),
                    if (isPlaying)
                      Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [const Icon(Icons.graphic_eq_rounded, size: 16, color: AppTheme.primary), const SizedBox(width: 8), const Expanded(child: Text('TTS ile okunuyor...', style: TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w700))), TextButton(onPressed: () => _togglePlayApi(d), child: const Text('Durdur', style: TextStyle(fontSize: 11)))]),
                      ),
                    const SizedBox(height: 8),
                    if (showArapca)
                      Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)), child: Text(d.arabic.isEmpty ? '(Arapça metin API\'de yok)' : d.arabic, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.8, color: AppTheme.primaryDark, fontWeight: FontWeight.w600)))
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (d.transliteration.isNotEmpty) ...[const Text('OKUNUŞ', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 1)), const SizedBox(height: 4), Text(d.transliteration, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12, height: 1.5)), const SizedBox(height: 8)],
                            const Text('ANLAM', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.primary, letterSpacing: 1)),
                            const SizedBox(height: 4),
                            Text(d.translationTr.isNotEmpty ? d.translationTr : d.translation, style: const TextStyle(fontSize: 12, height: 1.5)),
                            if (d.source.isNotEmpty) ...[const SizedBox(height: 6), Text('Kaynak: ${d.source}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontStyle: FontStyle.italic))],
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(icon: Icon(isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded, size: 14), label: Text(isPlaying ? 'Durdur' : 'Dinle (TTS)', style: const TextStyle(fontSize: 11)), onPressed: () => _togglePlayApi(d), style: ElevatedButton.styleFrom(backgroundColor: isPlaying ? Colors.red.shade600 : AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), visualDensity: VisualDensity.compact)),
                        const SizedBox(width: 6),
                        OutlinedButton.icon(icon: const Icon(Icons.copy_rounded, size: 12), label: const Text('Kopyala', style: TextStyle(fontSize: 11)), onPressed: () async { await Clipboard.setData(ClipboardData(text: '${d.title}\n${d.arabic}\n${d.transliteration}\n${d.translationTr}')); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kopyalandı'))); }, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), visualDensity: VisualDensity.compact)),
                        const Spacer(),
                        if (d.audioUrl != null && d.audioUrl!.isNotEmpty) IconButton(icon: const Icon(Icons.headset_rounded, size: 16, color: AppTheme.goldDark), tooltip: 'API audio', onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Audio: ${d.audioUrl}')))),
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

  Widget _buildLocalList() {
    var list = filter == 'Tümü' ? dualar : dualar.where((d) => d.kategori == filter).toList();
    if (search.isNotEmpty) {
      list = list.where((d) => d.baslik.toLowerCase().contains(search) || d.arapca.contains(search) || d.anlam.toLowerCase().contains(search)).toList();
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final d = list[i];
        final isPlaying = playingId == d.id;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: isPlaying ? AppTheme.primary.withValues(alpha: 0.4) : Colors.grey.shade200)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)), child: Icon(d.icon, color: AppTheme.primary, size: 16)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(d.baslik, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)), Text(d.kategori, style: TextStyle(fontSize: 11, color: Colors.grey.shade600))])), IconButton(icon: Icon(isPlaying ? Icons.pause_circle_rounded : Icons.play_circle_rounded, color: AppTheme.primary, size: 30), onPressed: () => _togglePlayLocal(d))]),
              if (isPlaying) Container(margin: const EdgeInsets.only(top: 8, bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)), child: Row(children: [const Icon(Icons.graphic_eq_rounded, size: 16, color: AppTheme.primary), const SizedBox(width: 8), const Expanded(child: Text('TTS ile okunuyor...', style: TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w700))), TextButton(onPressed: () => _togglePlayLocal(d), child: const Text('Durdur', style: TextStyle(fontSize: 11)))])),
              const SizedBox(height: 8),
              if (showArapca) Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)), child: Text(d.arapca, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.8, color: AppTheme.primaryDark, fontWeight: FontWeight.w600))) else Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(d.okunus, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12, height: 1.5)), const SizedBox(height: 8), Text(d.anlam, style: const TextStyle(fontSize: 12, height: 1.5))])),
              const SizedBox(height: 8),
              Row(children: [ElevatedButton.icon(icon: Icon(isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded, size: 14), label: Text(isPlaying ? 'Durdur' : 'Dinle'), onPressed: () => _togglePlayLocal(d), style: ElevatedButton.styleFrom(backgroundColor: isPlaying ? Colors.red.shade600 : AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), visualDensity: VisualDensity.compact)), const SizedBox(width: 6), OutlinedButton.icon(icon: const Icon(Icons.copy_rounded, size: 12), label: const Text('Kopyala', style: TextStyle(fontSize: 11)), onPressed: () async { await Clipboard.setData(ClipboardData(text: '${d.baslik}\n${d.arapca}\n${d.okunus}\n${d.anlam}')); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kopyalandı'))); })]),
            ],
          ),
        );
      },
    );
  }
}
