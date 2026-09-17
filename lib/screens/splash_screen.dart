import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/app_theme.dart';
import '../widgets/main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale;
  late Animation<double> _fade;
  late Animation<double> _shine;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _c, curve: const Interval(0, 0.6, curve: Curves.easeIn)));
    _shine = Tween<double>(begin: -1, end: 2).animate(CurvedAnimation(parent: _c, curve: const Interval(0.4, 1, curve: Curves.easeInOut)));
    _c.forward();
    Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(pageBuilder: (_, _, _) => const MainNavigation(), transitionDuration: const Duration(milliseconds: 400), transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child)));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Stack(
          children: [
            // dekoratif hilal
            Positioned(top: -60, right: -40, child: Container(width: 180, height: 180, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), shape: BoxShape.circle))),
            Positioned(bottom: -40, left: -30, child: Container(width: 140, height: 140, decoration: BoxDecoration(color: AppTheme.gold.withValues(alpha: 0.08), shape: BoxShape.circle))),
            Center(
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, _) {
                  return Opacity(
                    opacity: _fade.value,
                    child: Transform.scale(
                      scale: _scale.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.30), blurRadius: 18, offset: const Offset(0, 6))]),
                                clipBehavior: Clip.antiAlias,
                                child: Image.asset('assets/images/app_logo.png', fit: BoxFit.cover),
                              ),
                              Positioned.fill(
                                child: ClipOval(
                                  child: Transform.translate(
                                    offset: Offset(140 * _shine.value - 70, 0),
                                    child: Container(width: 40, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.white.withValues(alpha: 0.35), Colors.transparent]))),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('app.title'.tr(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, height: 1.1, fontSize: 26)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(gradient: AppTheme.goldGradient, borderRadius: BorderRadius.circular(20)),
                                child: Text('pro.badge'.tr(), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('app.subtitle'.tr(), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: 120,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(value: _c.value, backgroundColor: Colors.white.withValues(alpha: 0.2), color: AppTheme.gold, minHeight: 3),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('common.loading'.tr(), style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10, letterSpacing: 1)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(child: Text('© Hac & Umre Rehberi • PRO', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, letterSpacing: 0.5))),
            ),
          ],
        ),
      ),
    );
  }
}
