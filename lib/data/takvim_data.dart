import 'package:flutter/material.dart';

class DiniGun {
  final String ad;
  final DateTime miladi;
  final String hicri; // örn: 12 Rebiülevvel 1448
  final String kategori; // Kandil, Bayram, Özel
  final String aciklama;
  final IconData icon;
  final bool bildirimVarsayilan;

  const DiniGun({
    required this.ad,
    required this.miladi,
    required this.hicri,
    required this.kategori,
    required this.aciklama,
    required this.icon,
    this.bildirimVarsayilan = true,
  });
}

// Hicri ay isimleri
const hicriAylar = [
  'Muharrem', 'Safer', 'Rebiülevvel', 'Rebiülahir',
  'Cemaziyelevvel', 'Cemaziyelahir', 'Recep', 'Şaban',
  'Ramazan', 'Şevval', 'Zilkade', 'Zilhicce'
];

// Tahmini Hicri dönüşüm (tabular, +-1 gün sapma olabilir)
// Gerçek hicri rasatla belirlenir, bu yaklaşık hesaptır
String miladiToHicri(DateTime date) {
  // Julian Day Number tabanlı yaklaşık dönüşüm
  // Kaynak: Kuwaiti algorithm approx
  int d = date.day;
  int m = date.month;
  int y = date.year;
  // JDN
  int a = (14 - m) ~/ 12;
  int yy = y + 4800 - a;
  int mm = m + 12 * a - 3;
  int jdn = d + (153 * mm + 2) ~/ 5 + 365 * yy + yy ~/ 4 - yy ~/ 100 + yy ~/ 400 - 32045;
  // Islamic epoch JDN = 1948439 (16 Temmuz 622)
  int islamicJdn = jdn - 1948440 + 10632;
  int n = (islamicJdn - 1) ~/ 10631;
  islamicJdn = islamicJdn - 10631 * n + 10632;
  int j = ((islamicJdn - 1) * 4 + 3) ~/ 146097;
  islamicJdn = islamicJdn - (146097 * j) ~/ 4;
  int i = (islamicJdn * 4 + 3) ~/ 1461;
  islamicJdn = islamicJdn - (1461 * i) ~/ 4;
  int k = (islamicJdn * 5 + 2) ~/ 153;
  int day = islamicJdn - (153 * k + 2) ~/ 5 + 1;
  int month = k + 1;
  int year = 30 * n + j * 100 + i;
  // düzeltme
  if (month > 12) { month -= 12; year += 1; }
  if (month < 1) month = 1;
  if (month > 12) month = 12;
  return '$day ${hicriAylar[month - 1]} $year';
}

String hicriAyAdi(int ay) => hicriAylar[ay - 1];

// 2026-2027 dini günler (Diyanet 2026 tahmini, rasata göre +-1 gün değişebilir)
final List<DiniGun> diniGunler2026 = [
  DiniGun(
    ad: 'Mevlid Kandili',
    miladi: DateTime(2026, 8, 26),
    hicri: '12 Rebiülevvel 1448',
    kategori: 'Kandil',
    aciklama: 'Peygamberimiz (s.a.v.)\'in dünyaya teşrifi. Gece ibadet, salavat ve Kur\'an ile ihya edilir.',
    icon: Icons.star_rounded,
  ),
  DiniGun(
    ad: 'Regaip Kandili',
    miladi: DateTime(2026, 12, 18),
    hicri: '1 Recep 1448',
    kategori: 'Kandil',
    aciklama: 'Üç ayların başlangıcı, Recep ayının ilk cuma gecesi.',
    icon: Icons.nights_stay_rounded,
  ),
  DiniGun(
    ad: 'Miraç Kandili',
    miladi: DateTime(2027, 1, 16),
    hicri: '27 Recep 1448',
    kategori: 'Kandil',
    aciklama: 'Peygamberimiz\'in miraca yükselişi. Namazın hediye edildiği gece.',
    icon: Icons.rocket_launch_rounded,
  ),
  DiniGun(
    ad: 'Berat Kandili',
    miladi: DateTime(2027, 2, 3),
    hicri: '15 Şaban 1448',
    kategori: 'Kandil',
    aciklama: 'Günahların affı ve berat gecesi. Nafile namaz ve istiğfar gecesi.',
    icon: Icons.auto_awesome_rounded,
  ),
  DiniGun(
    ad: 'Ramazan Başlangıcı',
    miladi: DateTime(2027, 2, 18),
    hicri: '1 Ramazan 1448',
    kategori: 'Özel',
    aciklama: 'On bir ayın sultanı Ramazan. Oruç, teravih ve Kur\'an ayı.',
    icon: Icons.mosque_rounded,
  ),
  DiniGun(
    ad: 'Kadir Gecesi',
    miladi: DateTime(2027, 3, 15),
    hicri: '27 Ramazan 1448',
    kategori: 'Kandil',
    aciklama: 'Bin aydan hayırlı gece. Kur\'an\'ın inmeye başladığı gece.',
    icon: Icons.auto_awesome_rounded,
  ),
  DiniGun(
    ad: 'Ramazan Bayramı (1. Gün)',
    miladi: DateTime(2027, 3, 20),
    hicri: '1 Şevval 1448',
    kategori: 'Bayram',
    aciklama: 'Fıtır bayramı, 3 gündür. Bayram namazı ve ziyaretler.',
    icon: Icons.celebration_rounded,
  ),
  DiniGun(
    ad: 'Arefe Günü',
    miladi: DateTime(2027, 5, 26),
    hicri: '9 Zilhicce 1448',
    kategori: 'Özel',
    aciklama: 'Hacıların Arafat\'ta vakfeye durduğu gün. Oruç çok faziletlidir.',
    icon: Icons.wb_sunny_rounded,
  ),
  DiniGun(
    ad: 'Kurban Bayramı (1. Gün)',
    miladi: DateTime(2027, 5, 27),
    hicri: '10 Zilhicce 1448',
    kategori: 'Bayram',
    aciklama: 'Kurban kesimi, teşrik tekbirleri, 4 gündür.',
    icon: Icons.celebration_rounded,
  ),
  DiniGun(
    ad: 'Hicri Yılbaşı',
    miladi: DateTime(2027, 6, 17),
    hicri: '1 Muharrem 1449',
    kategori: 'Özel',
    aciklama: '1449 hicri yılbaşı. Muharrem ayı ve Aşure günü yakındır.',
    icon: Icons.calendar_month_rounded,
  ),
  DiniGun(
    ad: 'Aşure Günü',
    miladi: DateTime(2027, 6, 26),
    hicri: '10 Muharrem 1449',
    kategori: 'Özel',
    aciklama: 'Aşure günü, oruç tutulması müstehap, tarihi önemi büyük.',
    icon: Icons.water_drop_rounded,
  ),
  // Geçmiş 2025-2026 için de birkaç
  DiniGun(
    ad: 'Üç Ayların Başlangıcı',
    miladi: DateTime(2025, 12, 20),
    hicri: '1 Recep 1447',
    kategori: 'Özel',
    aciklama: 'Recep, Şaban, Ramazan - üç aylar başlıyor.',
    icon: Icons.calendar_today_rounded,
  ),
];

List<DiniGun> yakinDiniGunler({int limit = 5}) {
  final now = DateTime.now();
  final sorted = [...diniGunler2026]..sort((a, b) => a.miladi.compareTo(b.miladi));
  final upcoming = sorted.where((g) => g.miladi.isAfter(now.subtract(const Duration(days: 1)))).toList();
  if (upcoming.length >= limit) return upcoming.take(limit).toList();
  return sorted.take(limit).toList();
}
