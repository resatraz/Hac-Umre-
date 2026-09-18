import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/bildirim_service.dart';
import 'services/ezan_ses_service.dart';

/// Bildirime dokununca seçili ezan sesini çal.
Future<void> _bildirimSesCal() async {
  try {
    final p = await SharedPreferences.getInstance();
    final id = p.getString('ezan_bildirim_id');
    if (id == null) return;
    final name = p.getString('ezan_bildirim_ad') ?? 'Bildirim';
    await EzanSesService().play(id, name);
  } catch (e) {
    debugPrint('Bildirim sesi hatası: $e');
  }
}

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: ${details.exception}');
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('PlatformError: $error');
      return true;
    };
    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('tr'), Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('tr'),
        startLocale: null,
        saveLocale: false,
        useOnlyLangCode: true,
        child: const HacUmreApp(),
      ),
    );
    // Bildirim servisi ilk kareden SONRA - açılış animasyonunu engellemesin, kesinlikle önce animasyon
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await BildirimService().init(onTap: (_) => _bildirimSesCal());
      } catch (e) {
        debugPrint('Bildirim init hatası: $e');
      }
    });
  }, (error, stack) {
    debugPrint('Uncaught: $error');
  });
}

class HacUmreApp extends StatelessWidget {
  const HacUmreApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hac & Umre Rehberi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const SplashScreen(),
    );
  }
}
