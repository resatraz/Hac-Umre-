import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../screens/home_screen.dart';
import '../screens/hac_rehberi_screen.dart';
import '../screens/umre_rehberi_screen.dart';
import '../screens/uygulama/uygulama_klasoru_screen.dart';
import '../theme/app_theme.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 0;

  final screens = const [
    HomeScreen(),
    HacRehberiScreen(),
    UmreRehberiScreen(),
    UygulamaKlasoruScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primaryLight,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_rounded), label: 'nav.home'.tr()),
          NavigationDestination(icon: const Icon(Icons.mosque_rounded), label: 'nav.hajj'.tr()),
          NavigationDestination(icon: const Icon(Icons.spa_rounded), label: 'nav.umrah'.tr()),
          NavigationDestination(icon: const Icon(Icons.apps_rounded), label: 'nav.app'.tr()),
        ],
      ),
    );
  }
}
