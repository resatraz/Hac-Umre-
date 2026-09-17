import 'package:flutter/material.dart';
import '../data/hac_data.dart';
import '../theme/app_theme.dart';
import 'adim_detail_screen.dart';

class HacRehberiScreen extends StatefulWidget {
  const HacRehberiScreen({super.key});
  @override
  State<HacRehberiScreen> createState() => _HacRehberiScreenState();
}

class _HacRehberiScreenState extends State<HacRehberiScreen> {
  final Set<int> done = {};

  @override
  Widget build(BuildContext context) {
    final progress = done.length / hacAdimlari.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Hac Rehberi — 7 Adım')),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('İlerlemen', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13)),
                  Text('${done.length}/${hacAdimlari.length}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary)),
                ]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: Colors.grey.shade200, color: AppTheme.primary),
                ),
                const SizedBox(height: 6),
                Text(progress == 1 ? 'Mükemmel! Haccı tamamladınız 🕋' : 'Adımları tamamladıkça işaretleyin',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: hacAdimlari.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final a = hacAdimlari[i];
                final isDone = done.contains(a.sira);
                return InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdimDetailScreen(adim: a, ibadet: 'Hac'))),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDone ? AppTheme.primaryLight : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDone ? AppTheme.primary.withValues(alpha: 0.3) : Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isDone ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(a.icon, color: isDone ? Colors.white : AppTheme.primary, size: 26),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: isDone ? Colors.green : AppTheme.gold, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                child: Text('${a.sira}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.baslik, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15, decoration: isDone ? TextDecoration.lineThrough : null)),
                              const SizedBox(height: 2),
                              Text(a.kisaAciklama, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.5)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                                    child: Row(children: [const Icon(Icons.schedule_rounded, size: 11, color: Colors.grey), const SizedBox(width: 3), Text(a.sure, style: const TextStyle(fontSize: 10))]),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.menu_book_rounded, size: 12, color: AppTheme.goldDark),
                                  const SizedBox(width: 3),
                                  const Text('Dua', style: TextStyle(fontSize: 10, color: AppTheme.goldDark, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Checkbox(
                              value: isDone,
                              activeColor: AppTheme.primary,
                              onChanged: (v) => setState(() => v! ? done.add(a.sira) : done.remove(a.sira)),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                          ],
                        ),
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
