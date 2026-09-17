import 'package:flutter/material.dart';
import '../data/ziyaret_data.dart';
import '../theme/app_theme.dart';
import 'ziyaret_detail_screen.dart';

class ZiyaretListScreen extends StatefulWidget {
  const ZiyaretListScreen({super.key});
  @override
  State<ZiyaretListScreen> createState() => _ZiyaretListScreenState();
}

class _ZiyaretListScreenState extends State<ZiyaretListScreen> with SingleTickerProviderStateMixin {
  late TabController tab;
  @override
  void initState() { super.initState(); tab = TabController(length: 3, vsync: this); }
  @override
  void dispose() { tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ziyaret Yerleri'),
        bottom: TabBar(
          controller: tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppTheme.gold,
          tabs: const [Tab(text: 'Tümü'), Tab(text: 'Mekke'), Tab(text: 'Medine')],
        ),
      ),
      body: TabBarView(
        controller: tab,
        children: [
          _List(sehir: null),
          _List(sehir: 'Mekke'),
          _List(sehir: 'Medine'),
        ],
      ),
    );
  }
}

class _List extends StatelessWidget {
  final String? sehir;
  const _List({this.sehir});
  @override
  Widget build(BuildContext context) {
    final list = sehir == null ? ziyaretYerleri : ziyaretYerleri.where((z) => z.sehir == sehir).toList();
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final z = list[i];
        return InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ZiyaretDetailScreen(yer: z))),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: z.sehir == 'Mekke' ? AppTheme.primaryLight : AppTheme.goldLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(z.icon, color: z.sehir == 'Mekke' ? AppTheme.primary : AppTheme.goldDark, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: z.sehir == 'Mekke' ? AppTheme.primaryLight : AppTheme.goldLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(z.sehir, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: z.sehir == 'Mekke' ? AppTheme.primary : AppTheme.goldDark)),
                          ),
                          const SizedBox(width: 6),
                          Text(z.kategori, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(z.ad, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(z.aciklama, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }
}
