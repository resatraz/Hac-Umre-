import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

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

  Future<void> cancelAll() async => _plugin.cancelAll();
  Future<void> cancel(int id) async => _plugin.cancel(id);
}
