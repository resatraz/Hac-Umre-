import 'package:flutter/material.dart';
import 'models.dart';

const List<RehberAdim> umreAdimlari = [
  RehberAdim(
    sira: 1,
    baslik: 'İhram & Niyet',
    kisaAciklama: 'Mikât\'ta ihrama gir ve niyet et',
    detay:
        'Umre için de ihram farzdır. Mikât sınırını ihramsız geçmek caiz değildir. Gusül, ihram elbisesi, niyet ve telbiye umrenin başlangıcıdır. Niyet: "Allahım senin rızan için umre yapmak istiyorum, kolaylaştır ve kabul eyle" denir.',
    duaArapca: 'لَبَّيْكَ اللَّهُمَّ عُمْرَةً',
    duaOkunus: 'Lebbeyk Allahümme umraten',
    duaAnlam: 'Buyur Allahım, umre için geldim',
    icon: Icons.checkroom_rounded,
    sure: '30 dk',
    maddeler: [
      'Mikât\'ta gusül al, ihram giy',
      'Niyet et ve telbiye getir',
      'Harem\'e kadar telbiyeyi sürdür',
      'İhram yasaklarına dikkat et',
    ],
    uyari: 'Uçakla gelenler havada mikât hizasını geçmeden ihrama girmelidir.',
  ),
  RehberAdim(
    sira: 2,
    baslik: 'Tavaf',
    kisaAciklama: 'Kâbe etrafında 7 şavt',
    detay:
        'Umre tavafı rükündür. Abdestsiz tavaf geçersizdir. Hacerülesved\'den başlayıp 7 şavt yapılır. Kadınlar tavafta ızdıba ve remel yapmaz. Tavaf sonrası 2 rekat namaz ve zemzem.',
    duaArapca: 'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ',
    duaOkunus: 'Sübhânallahi ve\'l-hamdü lillâh',
    duaAnlam: 'Allah\'ı tesbih eder, O\'na hamd ederim',
    icon: Icons.mosque_rounded,
    sure: '1-1.5 saat',
    maddeler: [
      'Abdestli olarak Hacerülesved hizasında niyet',
      '7 şavt, her şavtta dua',
      'Makam-ı İbrahim arkasında 2 rekat',
      'Zemzem iç ve Mültezem\'de dua et',
    ],
  ),
  RehberAdim(
    sira: 3,
    baslik: 'Sa\'y & Tıraş',
    kisaAciklama: 'Safa-Merve ve saç kısaltma',
    detay:
        'Safa-Merve arasında 7 şavt yapılır. Ardından erkekler tıraş olur veya saçlarını kısaltır (en az 1 cm), kadınlar saç ucundan bir miktar keser. Bununla umre tamamlanır ve ihram yasakları kalkar.',
    duaArapca: 'رَبِّ اغْفِرْ وَارْحَمْ',
    duaOkunus: 'Rabbiğfir verham',
    duaAnlam: 'Rabbim bağışla ve merhamet et',
    icon: Icons.content_cut_rounded,
    sure: '1 saat',
    maddeler: [
      'Safa\'dan başla, Merve\'de bitir (7 şavt)',
      'Yeşil ışıklarda hervele (erkekler)',
      'Saç tıraşı / kısaltma ile ihramdan çık',
      'Şükür duası',
    ],
  ),
];
