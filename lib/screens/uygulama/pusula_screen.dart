import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PusulaScreen extends StatefulWidget {
  const PusulaScreen({super.key});
  @override
  State<PusulaScreen> createState() => _PusulaScreenState();
}

class _PusulaScreenState extends State<PusulaScreen> with SingleTickerProviderStateMixin {
  late AnimationController ctrl;
  double heading = 0;
  Timer? timer;
  bool kabeModu = true;

  @override
  void initState() {
    super.initState();
    ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      setState(() => heading = (heading + 0.3) % 360);
    });
  }

  @override
  void dispose() {
    ctrl.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const kibleAngle = 147.0;
    final relativeKible = (kibleAngle - heading) % 360;
    return Scaffold(
      appBar: AppBar(title: const Text('Pusula 3D')),
      body: SingleChildScrollView(
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
            AnimatedBuilder(
              animation: ctrl,
              builder: (context, child) {
                final tilt = math.sin(ctrl.value * 2 * math.pi) * 0.08;
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
                    Positioned(top: 18, child: Text('K', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w800, fontSize: 16))),
                    Positioned(bottom: 18, child: Text('G', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700))),
                    Positioned(left: 18, child: Text('B', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700))),
                    Positioned(right: 18, child: Text('D', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700))),
                    Transform.rotate(
                      angle: -heading * math.pi / 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(top: 30, child: Container(width: 4, height: 90, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.red, Colors.redAccent], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(4)))),
                          Positioned(bottom: 30, child: Container(width: 4, height: 80, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(4)))),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(shape: BoxShape.circle, gradient: const RadialGradient(colors: [Color(0xFF0D5C3D), Color(0xFF083826)]), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6)], border: Border.all(color: AppTheme.gold, width: 2)),
                            child: const Icon(Icons.mosque_rounded, color: Colors.white, size: 14),
                          ),
                        ],
                      ),
                    ),
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
                    child: Row(children: [Icon(kabeModu ? Icons.info_rounded : Icons.warning_rounded, size: 16, color: kabeModu ? AppTheme.primary : Colors.grey), const SizedBox(width: 8), Expanded(child: Text(kabeModu ? 'Yeşil “KÂBE” işareti kıble yönünü gösterir. Pusulayı düz tutun.' : 'Kıble modu kapalı, sadece kuzey gösteriliyor.', style: TextStyle(fontSize: 11, color: kabeModu ? AppTheme.primaryDark : Colors.grey.shade700)))]),
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
