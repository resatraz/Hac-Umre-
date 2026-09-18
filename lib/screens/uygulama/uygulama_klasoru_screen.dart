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

class UygulamaKlasoruScreen extends StatelessWidget {
  const UygulamaKlasoruScreen({super.key});

  Future<void> _openStore(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Açılamadı: $url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uygulama')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _FolderCard(
            title: 'Zikirmatik',
            subtitle: 'Sayaç • Tesbihat',
            icon: Icons.touch_app_rounded,
            gradient: const [Color(0xFF0D5C3D), Color(0xFF1B8A5A)],
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ZikirmatikScreen())),
          ),
          _FolderCard(
            title: 'Pusula 3D',
            subtitle: 'Kıble • 3D • Kalibre',
            icon: Icons.explore_rounded,
            gradient: const [Color(0xFF0D5C3D), Color(0xFF1B8A5A)],
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PusulaScreen())),
          ),
          _FolderCard(
            title: 'Günlük Dualar',
            subtitle: 'Sabah/Akşam • TTS • Kopyala',
            icon: Icons.menu_book_rounded,
            gradient: const [Color(0xFF0D5C3D), Color(0xFF1B8A5A)],
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GunlukDualarScreen())),
          ),
          _FolderCard(
            title: 'Takvim',
            subtitle: 'Hicri / Miladi • Kandil bildirimleri',
            icon: Icons.calendar_month_rounded,
            gradient: const [Color(0xFF0D5C3D), Color(0xFF1B8A5A)],
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TakvimScreen())),
          ),
          _FolderCard(
            title: 'Ziyaret Yerleri',
            subtitle: 'Mekke & Medine • 14 mekan',
            icon: Icons.place_rounded,
            gradient: const [Color(0xFF0D5C3D), Color(0xFF1B8A5A)],
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ZiyaretListScreen())),
          ),
          _FolderCard(
            title: 'Harita',
            subtitle: 'Offline destekli • OSM • Konum',
            icon: Icons.map_rounded,
            gradient: const [Color(0xFF0D5C3D), Color(0xFF1B8A5A)],
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HaritaScreen())),
          ),
          _FolderCard(
            title: 'Dualar',
            subtitle: 'API (126+1001) • TTS sesli • Offline',
            icon: Icons.menu_book_rounded,
            gradient: const [Color(0xFF0D5C3D), Color(0xFF1B8A5A)],
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DualarScreen())),
          ),
          _FolderCard(
            title: 'Ezan Sesleri',
            subtitle: '9 Drive ses • İndirmeli • Bildirim • Tıklama koruması',
            icon: Icons.music_note_rounded,
            gradient: const [Color(0xFF0D5C3D), Color(0xFF1B8A5A)],
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EzanSesleriScreen())),
          ),
          _FolderCard(
            title: 'Cüz (30 Cüz)',
            subtitle: 'Hafız seç • Kaydet • Kaldığın yer • Play koruması',
            icon: Icons.auto_stories_rounded,
            gradient: const [Color(0xFF0D5C3D), Color(0xFF1B8A5A)],
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CuzScreen())),
          ),
          _FolderCard(
            title: 'Radyo & TV',
            subtitle: 'GitHub • 21 kanal • Uygulama içi player • PRO',
            icon: Icons.radio_rounded,
            gradient: const [Color(0xFF0D5C3D), Color(0xFF1B8A5A)],
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RadyoTvScreen())),
          ),
          _FolderCard(
            title: 'Kur\'an-ı Kerim & Elifba',
            subtitle: 'Play Store • com.kurankerim — Dokun Play Store\'a git',
            icon: Icons.menu_book_rounded,
            gradient: const [Color(0xFF0D5C3D), Color(0xFF1B8A5A)],
            onTap: () => _openStore(context, 'https://play.google.com/store/apps/details?id=com.kurankerim&pcampaignid=web_share'),
          ),
          _FolderCard(
            title: 'Ezan Vakti : Namaz ve Kuran',
            subtitle: 'Play Store • com.nurnamazprogrami — Dokun Play Store\'a git',
            icon: Icons.access_time_rounded,
            gradient: const [Color(0xFF0D5C3D), Color(0xFF1B8A5A)],
            onTap: () => _openStore(context, 'https://play.google.com/store/apps/details?id=com.nurnamazprogrami&pcampaignid=web_share'),
          ),
        ],
      ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _FolderCard({required this.title, required this.subtitle, required this.icon, required this.gradient, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: gradient.first.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.white, size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)), Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11))])),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
