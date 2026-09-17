import 'package:flutter/material.dart';
import '../data/umre_data.dart';
import '../theme/app_theme.dart';
import 'adim_detail_screen.dart';

class UmreRehberiScreen extends StatefulWidget {
  const UmreRehberiScreen({super.key});
  @override
  State<UmreRehberiScreen> createState() => _UmreRehberiScreenState();
}

class _UmreRehberiScreenState extends State<UmreRehberiScreen> {
  final Set<int> done = {};
  @override
  Widget build(BuildContext context) {
    final progress = done.length / umreAdimlari.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Umre Rehberi — 3 Adım'),
        backgroundColor: AppTheme.goldDark,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF8D6E1F), Color(0xFFC5A253)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.spa_rounded, color: Colors.white)),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('Umre Sünnettir • Dilediğiniz zaman yapabilirsiniz', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))),
                ]),
                const SizedBox(height: 12),
                ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: Colors.white.withValues(alpha: 0.3), color: Colors.white)),
                const SizedBox(height: 6),
                Text('${done.length}/${umreAdimlari.length} tamamlandı', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: umreAdimlari.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final a = umreAdimlari[i];
                final isDone = done.contains(a.sira);
                return InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdimDetailScreen(adim: a, ibadet: 'Umre'))),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDone ? AppTheme.goldLight : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDone ? AppTheme.gold.withValues(alpha: 0.4) : Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(color: isDone ? AppTheme.goldDark : AppTheme.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                          child: Icon(a.icon, color: isDone ? Colors.white : AppTheme.goldDark, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${a.sira}. ${a.baslik}', style: Theme.of(context).textTheme.titleMedium?.copyWith(decoration: isDone ? TextDecoration.lineThrough : null)),
                              Text(a.kisaAciklama, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.5)),
                              const SizedBox(height: 4),
                              Text(a.sure, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        Checkbox(value: isDone, activeColor: AppTheme.goldDark, onChanged: (v) => setState(() => v! ? done.add(a.sira) : done.remove(a.sira))),
                        const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
