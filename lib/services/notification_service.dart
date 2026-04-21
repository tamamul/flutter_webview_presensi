import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Inisialisasi notifikasi
  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Handle tap pada notifikasi
  }

  /// Kirim notifikasi lokal biasa
  static Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'presensi_marsa_channel',
      'Presensi MARSA',
      channelDescription: 'Notifikasi sistem presensi SMK Ma\'arif 9 Kebumen',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }

  /// Jadwalkan notifikasi pengingat presensi (periodik sederhana)
  static Future<void> showReminderNotification() async {
    await showNotification(
      id: 1,
      title: '🏫 Pengingat Presensi',
      body: 'Jangan lupa absen hari ini! Tap untuk membuka.',
    );
  }

  /// Batalkan semua notifikasi
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
