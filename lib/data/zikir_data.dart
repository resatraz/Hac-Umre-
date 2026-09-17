import 'package:flutter/material.dart';

class Zikir {
  final String id;
  final String ad;
  final String arapca;
  final String okunus;
  final String anlam;
  final int hedef; // 33, 99 vs
  final IconData icon;
  final String fazilet;

  const Zikir({
    required this.id,
    required this.ad,
    required this.arapca,
    required this.okunus,
    required this.anlam,
    required this.hedef,
    required this.icon,
    required this.fazilet,
  });
}

class TesbihatItem {
  final String ad;
  final int adet;
  final String arapca;
  const TesbihatItem({required this.ad, required this.adet, required this.arapca});
}

const List<Zikir> zikirler = [
  Zikir(
    id: 'subhanallah',
    ad: 'Sübhânallah',
    arapca: 'سُبْحَانَ اللَّهِ',
    okunus: 'Sübhânallah',
    anlam: 'Allah noksan sıfatlardan münezzehtir',
    hedef: 33,
    icon: Icons.spa_rounded,
    fazilet: '33 kez okuyan deniz köpüğü kadar günahı olsa affedilir.',
  ),
  Zikir(
    id: 'elhamdulillah',
    ad: 'Elhamdülillah',
    arapca: 'الْحَمْدُ لِلَّهِ',
    okunus: 'Elhamdülillâh',
    anlam: 'Hamd Allah\'a mahsustur',
    hedef: 33,
    icon: Icons.favorite_rounded,
    fazilet: 'Şükrün başı hamddir, nimeti artırır.',
  ),
  Zikir(
    id: 'allahu_akbar',
    ad: 'Allahu Ekber',
    arapca: 'اللَّهُ أَكْبَرُ',
    okunus: 'Allahu ekber',
    anlam: 'Allah en büyüktür',
    hedef: 33,
    icon: Icons.star_rounded,
    fazilet: 'Tekbir, kalbi yüceltir, şeytanı uzaklaştırır.',
  ),
  Zikir(
    id: 'la_ilahe',
    ad: 'Lâ ilâhe illallah',
    arapca: 'لَا إِلَهَ إِلَّا اللَّهُ',
    okunus: 'Lâ ilâhe illallah',
    anlam: 'Allah\'tan başka ilah yoktur',
    hedef: 100,
    icon: Icons.light_mode_rounded,
    fazilet: 'En faziletli zikir, imanı tazeler.',
  ),
  Zikir(
    id: 'estagfirullah',
    ad: 'Estağfirullah',
    arapca: 'أَسْتَغْفِرُ اللَّهَ',
    okunus: 'Estağfirullah',
    anlam: 'Allah\'tan bağışlanma dilerim',
    hedef: 100,
    icon: Icons.water_drop_rounded,
    fazilet: 'Rızkı artırır, sıkıntıyı giderir.',
  ),
  Zikir(
    id: 'salavat',
    ad: 'Salavat',
    arapca: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
    okunus: 'Allahümme salli alâ Muhammed',
    anlam: 'Allahım Muhammed\'e salat eyle',
    hedef: 100,
    icon: Icons.mosque_rounded,
    fazilet: 'Bir salavata 10 rahmet, 10 derece.',
  ),
  Zikir(
    id: 'hasbunallah',
    ad: 'Hasbünallah',
    arapca: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
    okunus: 'Hasbünallahu ve ni\'mel vekil',
    anlam: 'Allah bize yeter, O ne güzel vekildir',
    hedef: 33,
    icon: Icons.shield_rounded,
    fazilet: 'Zorluk anında koruyan zikir.',
  ),
  Zikir(
    id: 'la_havle',
    ad: 'Lâ havle',
    arapca: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    okunus: 'Lâ havle velâ kuvvete illâ billâh',
    anlam: 'Güç ve kuvvet ancak Allah\'tandır',
    hedef: 33,
    icon: Icons.bolt_rounded,
    fazilet: 'Cennet hazinelerinden bir hazinedir.',
  ),
];

const List<TesbihatItem> namazTesbihati = [
  TesbihatItem(ad: 'Sübhânallah', adet: 33, arapca: 'سُبْحَانَ اللَّهِ'),
  TesbihatItem(ad: 'Elhamdülillah', adet: 33, arapca: 'الْحَمْدُ لِلَّهِ'),
  TesbihatItem(ad: 'Allahu Ekber', adet: 33, arapca: 'اللَّهُ أَكْبَرُ'),
  TesbihatItem(ad: 'Lâ ilâhe illallah...', adet: 1, arapca: 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ'),
  TesbihatItem(ad: 'Ayete\'l-Kürsî', adet: 1, arapca: 'آيَةُ الْكُرْسِيِّ'),
];

const List<TesbihatItem> sabahTesbihati = [
  TesbihatItem(ad: 'Sübhânallah ve bihamdihi', adet: 100, arapca: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ'),
  TesbihatItem(ad: 'Lâ ilâhe illallah vahdehû...', adet: 100, arapca: 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ'),
  TesbihatItem(ad: 'Hasbiyallah', adet: 7, arapca: 'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ'),
];

const List<TesbihatItem> aksamTesbihati = [
  TesbihatItem(ad: 'Eûzü bi kelimâtillâh...', adet: 3, arapca: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ'),
  TesbihatItem(ad: 'Bismillahillezi...', adet: 3, arapca: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ'),
  TesbihatItem(ad: 'Sübhânallah ve bihamdihi', adet: 100, arapca: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ'),
];

// Günlük dualar genişletme
const List<Map<String, String>> gunlukDualar = [
  {
    'baslik': 'Sabah Duası',
    'arapca': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ',
    'okunus': 'Asbahnâ ve asbahal mülkü lillâh',
    'anlam': 'Sabaha erdik, mülk Allah\'ındır.',
    'kategori': 'Sabah',
  },
  {
    'baslik': 'Akşam Duası',
    'arapca': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ',
    'okunus': 'Emseynâ ve emsal mülkü lillâh',
    'anlam': 'Akşama erdik, mülk Allah\'ındır.',
    'kategori': 'Akşam',
  },
  {
    'baslik': 'Yemek Duası',
    'arapca': 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا',
    'okunus': 'Elhamdülillahillezî et\'amenâ ve sekânâ',
    'anlam': 'Bizi yedirip içiren Allah\'a hamdolsun.',
    'kategori': 'Genel',
  },
  {
    'baslik': 'Yolculuk Duası',
    'arapca': 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا',
    'okunus': 'Sübhânellezî sehhara lenâ hâzâ',
    'anlam': 'Bunu bizim hizmetimize vereni tesbih ederiz (Zuhruf 13).',
    'kategori': 'Yolculuk',
  },
  {
    'baslik': 'Uyku Duası',
    'arapca': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
    'okunus': 'Bismike Allahümme emûtü ve ahyâ',
    'anlam': 'Allahım senin adınla ölür, senin adınla dirilirim.',
    'kategori': 'Genel',
  },
  {
    'baslik': 'Sıkıntı Duası',
    'arapca': 'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
    'okunus': 'Lâ ilâhe illâ ente sübhâneke innî küntü minez-zâlimîn',
    'anlam': 'Senden başka ilah yok, seni tenzih ederim, ben zalimlerden oldum.',
    'kategori': 'Genel',
  },
];
