import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/bildirim_service.dart';

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
        await BildirimService().init();
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
