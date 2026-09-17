import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'ezan_vakti_service.dart';

class BildirimService {
  static final BildirimService _i = BildirimService._();
  factory BildirimService() => _i;
  BildirimService._();
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
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
    await _plugin.initialize(init);
    // Android 13+ permission
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    _ready = true;
    debugPrint('BildirimService ready');
  }

  Future<void> showTestBildirim({required String sehir}) async {
    if (!_ready) await init();
    const android = AndroidNotificationDetails('ezan_vakti', 'Ezan Vakti', channelDescription: 'Ezan vakitleri', importance: Importance.high, priority: Priority.high);
    const details = NotificationDetails(android: android, iOS: DarwinNotificationDetails());
    await _plugin.show(0, 'Ezan Vakti', '$sehir için bildirim testi — Ezan sesi hazır', details);
  }

  Future<void> scheduleDaily({required int id, required String title, required String body, required int hour, required int minute}) async {
    if (!_ready) await init();
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
    const android = AndroidNotificationDetails('ezan_vakti_daily', 'Ezan Vakti Günlük', importance: Importance.high, priority: Priority.high);
    const details = NotificationDetails(android: android);
    await _plugin.zonedSchedule(id, title, body, scheduled, details, androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, matchDateTimeComponents: DateTimeComponents.time);
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
