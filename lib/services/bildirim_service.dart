import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'ezan_vakti_service.dart';

class BildirimService {
  static final BildirimService _i = BildirimService._();
  factory BildirimService() => _i;
  BildirimService._();
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init({void Function(String? payload)? onTap}) async {
    tzdata.initializeTimeZones();
    // Default to Asia/Riyadh for Mekke/Medine, fallback to local
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const init = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(
      init,
      onDidReceiveNotificationResponse: (r) => onTap?.call(r.payload),
    );
    // Android 13+ permission
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    _ready = true;
    debugPrint('BildirimService ready');
  }

  Future<bool> _titresimAcik() async {
    try {
      final p = await SharedPreferences.getInstance();
      return p.getBool('bildirim_titresim') ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<NotificationDetails> _details(String channelId, String channelName) async {
    final titresim = await _titresimAcik();
    final android = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Ezan vakitleri',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: titresim,
    );
    return NotificationDetails(android: android, iOS: const DarwinNotificationDetails());
  }

  Future<void> showTestBildirim({required String sehir}) async {
    if (!_ready) await init();
    await _plugin.show(0, 'Ezan Vakti', '$sehir için bildirim testi — Ezan sesi hazır', await _details('ezan_vakti', 'Ezan Vakti'), payload: 'ezan_vakti');
  }

  Future<void> scheduleDaily({required int id, required String title, required String body, required int hour, required int minute}) async {
    if (!_ready) await init();
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
    final details = await _details('ezan_vakti_daily', 'Ezan Vakti Günlük');
    try {
      await _plugin.zonedSchedule(id, title, body, scheduled, details, androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, matchDateTimeComponents: DateTimeComponents.time, payload: 'ezan_vakti');
    } catch (e) {
      // Tam zamanlı alarm izni yoksa yaklaşık moda düş (Android 12+)
      debugPrint('exact schedule failed, inexact fallback: $e');
      await _plugin.zonedSchedule(id, title, body, scheduled, details, androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, matchDateTimeComponents: DateTimeComponents.time, payload: 'ezan_vakti');
    }
  }

  Future<void> scheduleVakitBildirimleri(VakitGun vakit, String sehir) async {
    if (!_ready) await init();
    await cancelAll();
    final times = {'İmsak': vakit.imsak, 'Güneş': vakit.gunes, 'Öğle': vakit.ogle, 'İkindi': vakit.ikindi, 'Akşam': vakit.aksam, 'Yatsı': vakit.yatsi};
    int id = 100;
    for (final e in times.entries) {
      final parts = e.value.split(':');
      if (parts.length != 2) continue;
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      await scheduleDaily(id: id, title: '$sehir ${e.key} • Ezan vakti', body: '$sehir ${e.key} ezanı ${e.value} — Hac & Umre Rehberi', hour: hour, minute: minute);
      id++;
    }
    debugPrint('Vakit bildirimleri planlandı $sehir ${vakit.miladiUzun}');
  }

  Future<void> cancelAll() async => _plugin.cancelAll();
  Future<void> cancel(int id) async => _plugin.cancel(id);
}
