import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Servicio centralizado único en Core para la gestión de notificaciones locales.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Inicializa la configuración de notificaciones y permisos.
  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Europe/Madrid'));
    } catch (_) {}

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    _isInitialized = true;
  }

  /// Imprime y devuelve la lista de notificaciones programadas en el dispositivo.
  Future<List<PendingNotificationRequest>> checkPendingNotifications() async {
    await init();
    final pending = await _notificationsPlugin.pendingNotificationRequests();
    print("\n--------------------------------------------------");
    print(
      "=== NOTIFICACIONES PROGRAMADAS EN EL DISPOSITIVO (${pending.length}) ===",
    );
    for (var p in pending) {
      print("ID: ${p.id} | Título: ${p.title} | Cuerpo: ${p.body}");
    }
    print("--------------------------------------------------\n");
    return pending;
  }

  /// Programa/Actualiza las 4 notificaciones diarias fijadas a las 9:00, 14:00, 18:00 y 22:00.
  Future<void> scheduleDailyNotifications(int pendingCount) async {
    await init();

    // Cancelamos notificaciones previas para refrescar el conteo de misiones pendientes
    await _notificationsPlugin.cancel(101);
    await _notificationsPlugin.cancel(102);
    await _notificationsPlugin.cancel(103);
    await _notificationsPlugin.cancel(104);

    const androidDetails = AndroidNotificationDetails(
      'daily_misiones_channel',
      'Misiones Diarias',
      channelDescription: 'Canal para recordatorios de misiones diarias',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    final String countText = pendingCount == 1
        ? "1 misión"
        : "$pendingCount misiones";

    final String afternoonBody = pendingCount > 0
        ? "Te quedan $countText por cumplir"
        : "¡No tienes misiones pendientes por cumplir!";

    // 1. 09:00 AM
    await _scheduleDaily(
      id: 101,
      hour: 9,
      minute: 0,
      title: 'RPG Habits',
      body: '¡Buenos días! ¿Listo para empezar a cumplir tus misiones?',
      notificationDetails: notificationDetails,
    );

    // 2. 14:00 PM
    await _scheduleDaily(
      id: 102,
      hour: 14,
      minute: 0,
      title: 'RPG Habits',
      body: afternoonBody,
      notificationDetails: notificationDetails,
    );

    // 3. 18:00 PM
    await _scheduleDaily(
      id: 103,
      hour: 18,
      minute: 0,
      title: 'RPG Habits',
      body: afternoonBody,
      notificationDetails: notificationDetails,
    );

    // 4. 22:00 PM
    await _scheduleDaily(
      id: 104,
      hour: 22,
      minute: 0,
      title: 'RPG Habits',
      body:
          '¡Acuérdate de marcar tus misiones como hechas! Queda muy poco para cambiar de día',
      notificationDetails: notificationDetails,
    );

    await checkPendingNotifications();
  }

  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required NotificationDetails notificationDetails,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
