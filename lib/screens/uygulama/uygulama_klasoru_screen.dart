import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../zikirmatik_screen.dart';
import '../takvim_screen.dart';
import '../ziyaret_list_screen.dart';
import '../harita_screen.dart';
import '../dualar_screen.dart';
import 'ezan_sesleri_screen.dart';
import 'cuz_screen.dart';
import 'pusula_screen.dart';
import 'gunluk_dualar_screen.dart';
import 'radyo_tv_screen.dart';

class UygulamaKlasoruScreen extends StatefulWidget {
  const UygulamaKlasoruScreen({super.key});
  @override
  State<UygulamaKlasoruScreen> createState() => _UygulamaKlasoruScreenState();
}

class _UygulamaKlasoruScreenState extends State<UygulamaKlasoruScreen> {
  bool _isGrid = false;

  Future<void> _openStore(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Açılamadı: $url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uygulama'),
        actions: [
          IconButton(
            icon: Icon(_isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded),
            tooltip: _isGrid ? 'Liste' : 'Grid',
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _KategoriBaslik(icon: Icons.spa_rounded, title: 'İbadet', subtitle: 'Zikir, dua ve kıraat'),
          _buildSection(_ibadetKartlari, isGrid: _isGrid),
          const SizedBox(height: 12),
          _KategoriBaslik(icon: Icons.mosque_rounded, title: 'Hac & Umre', subtitle: 'Bilgi, ziyaret ve harita'),
          _buildSection(_hacUmreKartlari, isGrid: _isGrid),
          const SizedBox(height: 12),
          _KategoriBaslik(icon: Icons.play_circle_rounded, title: 'Medya', subtitle: 'Ses, radyo ve TV'),
          _buildSection(_medyaKartlari, isGrid: _isGrid),
        ],
      ),
    );
  }

  Widget _buildSection(List<_KartVeri> kartlar, {required bool isGrid}) {
    if (isGrid) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1),
        itemCount: kartlar.length,
        itemBuilder: (context, i) => _GridCard(data: kartlar[i], onTap: () => _onTap(kartlar[i])),
      );
    }
    return Column(children: kartlar.map((k) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _FolderCard(data: k, onTap: () => _onTap(k)))).toList());
  }

  void _onTap(_KartVeri k) {
    if (k.storeUrl != null) {
      _openStore(k.storeUrl!);
    } else if (k.screen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => k.screen!));
    }
  }

  List<_KartVeri> get _ibadetKartlari => [
        _KartVeri(title: 'Zikirmatik', subtitle: 'Sayaç • Tesbihat', icon: Icons.touch_app_rounded, screen: const ZikirmatikScreen()),
        _KartVeri(title: 'Pusula 3D', subtitle: 'Kıble • 3D • Kalibre', icon: Icons.explore_rounded, screen: const PusulaScreen()),
        _KartVeri(title: 'Günlük Dualar', subtitle: 'Sabah/Akşam • Orijinal ses', icon: Icons.menu_book_rounded, screen: const GunlukDualarScreen()),
        _KartVeri(title: 'Cüz (30 Cüz)', subtitle: 'Hafız • Kaldığın yer', icon: Icons.auto_stories_rounded, screen: const CuzScreen()),
        _KartVeri(title: 'Dualar', subtitle: 'API • Orijinal ses • Offline', icon: Icons.menu_book_rounded, screen: const DualarScreen()),
      ];

  List<_KartVeri> get _hacUmreKartlari => [
        _KartVeri(title: 'Takvim', subtitle: 'Hicri / Miladi', icon: Icons.calendar_month_rounded, screen: const TakvimScreen()),
        _KartVeri(title: 'Ziyaret Yerleri', subtitle: '14 mekan', icon: Icons.place_rounded, screen: const ZiyaretListScreen()),
        _KartVeri(title: 'Harita', subtitle: 'Offline • OSM', icon: Icons.map_rounded, screen: const HaritaScreen()),
      ];

  List<_KartVeri> get _medyaKartlari => [
        _KartVeri(title: 'Ezan Sesleri', subtitle: '9 ses • Bildirim sesi', icon: Icons.music_note_rounded, screen: const EzanSesleriScreen()),
        _KartVeri(title: 'Radyo & TV', subtitle: '21 kanal • Uygulama içi', icon: Icons.radio_rounded, screen: const RadyoTvScreen()),
        _KartVeri(title: 'Kur\'an-ı Kerim & Elifba', subtitle: 'Play Store', icon: Icons.menu_book_rounded, storeUrl: 'https://play.google.com/store/apps/details?id=com.kurankerim&pcampaignid=web_share'),
        _KartVeri(title: 'Ezan Vakti', subtitle: 'Play Store', icon: Icons.access_time_rounded, storeUrl: 'https://play.google.com/store/apps/details?id=com.nurnamazprogrami&pcampaignid=web_share'),
      ];
}

class _KartVeri {
  final String title, subtitle;
  final IconData icon;
  final Widget? screen;
  final String? storeUrl;
  const _KartVeri({required this.title, required this.subtitle, required this.icon, this.screen, this.storeUrl});
}

class _KategoriBaslik extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _KategoriBaslik({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(children: [Icon(icon, size: 16, color: const Color(0xFF0D5C3D)), const SizedBox(width: 6), Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0D5C3D))), const SizedBox(width: 6), Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600))]),
    );
  }
}

class _FolderCard extends StatelessWidget {
  final _KartVeri data;
  final VoidCallback onTap;
  const _FolderCard({required this.data, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF0D5C3D), Color(0xFF1B8A5A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFF0D5C3D).withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)), child: Icon(data.icon, color: Colors.white, size: 22)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(data.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)), Text(data.subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11))])),
            const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  final _KartVeri data;
  final VoidCallback onTap;
  const _GridCard({required this.data, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF0D5C3D), Color(0xFF1B8A5A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFF0D5C3D).withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)), child: Icon(data.icon, color: Colors.white, size: 20)),
            const Spacer(),
            Text(data.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            Text(data.subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
