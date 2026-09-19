import 'package:flutter/material.dart';

class RehberAdim {
  final int sira;
  final String baslik;
  final String kisaAciklama;
  final String detay;
  final String duaArapca;
  final String duaOkunus;
  final String duaAnlam;
  final IconData icon;
  final List<String> maddeler;
  final String sure;
  final String uyari;
  final String? imagePath;

  const RehberAdim({
    required this.sira,
    required this.baslik,
    required this.kisaAciklama,
    required this.detay,
    required this.duaArapca,
    required this.duaOkunus,
    required this.duaAnlam,
    required this.icon,
    required this.maddeler,
    this.sure = '',
    this.uyari = '',
    this.imagePath,
  });
}

class ZiyaretYeri {
  final String id;
  final String ad;
  final String sehir; // Mekke / Medine
  final String kategori;
  final String aciklama;
  final String tarihce;
  final String duaArapca;
  final String duaOkunus;
  final String duaAnlam;
  final IconData icon;
  final double lat;
  final double lng;
  final String ziyaretAdabi;
  final String? imagePath;

  const ZiyaretYeri({
    required this.id,
    required this.ad,
    required this.sehir,
    required this.kategori,
    required this.aciklama,
    required this.tarihce,
    required this.duaArapca,
    required this.duaOkunus,
    required this.duaAnlam,
    required this.icon,
    required this.lat,
    required this.lng,
    required this.ziyaretAdabi,
    this.imagePath,
  });
}

class Dua {
  final String id;
  final String baslik;
  final String kategori; // Tavaf, Sa'y, Arafat, Genel
  final String arapca;
  final String okunus;
  final String anlam;
  final String aciklama;
  final IconData icon;

  const Dua({
    required this.id,
    required this.baslik,
    required this.kategori,
    required this.arapca,
    required this.okunus,
    required this.anlam,
    required this.aciklama,
    required this.icon,
  });
}

class HaritaNokta {
  final String id;
  final String ad;
  final String sehir;
  final double x; // 0..1 relative for our offline canvas
  final double y;
  final IconData icon;
  final Color color;

  const HaritaNokta({
    required this.id,
    required this.ad,
    required this.sehir,
    required this.x,
    required this.y,
    required this.icon,
    required this.color,
  });
}
