import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hac_umre_rehberi/main.dart';

void main() {
  testWidgets('Hac Umre app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('tr'), Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('tr'),
        startLocale: const Locale('tr'),
        saveLocale: false,
        useOnlyLangCode: true,
        child: const HacUmreApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Hac'), findsWidgets);
    // Splash 2.2s + geçiş
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();
    expect(find.textContaining('Ana Sayfa'), findsWidgets);
  });
}
