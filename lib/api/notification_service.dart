import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal() {
    initializeNotifications();
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    // Android Initialization Settings
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    // Initialize Plugin
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Initialize Timezones
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); // Ganti dengan zona waktu Anda
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> scheduleNotification(
      int id,
      String title,
      String body,
      DateTime scheduledDate,
      String frequency,
      ) async {
    tz.TZDateTime scheduledTime;

    if (frequency == 'Harian') {
      scheduledTime = _nextInstanceOfDailyTime(scheduledDate);
    } else {
      scheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);
      if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
        // Jika waktu yang dijadwalkan sudah lewat, jadwalkan untuk hari berikutnya
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title.isEmpty ? 'No Title' : title, // Pastikan title tidak null atau kosong
      body.isEmpty ? 'No Body' : body,   // Pastikan body tidak null atau kosong
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'custom_channel_id', // Sama dengan channel ID yang dibuat
          'Custom Notifications',
          channelDescription: 'Channel for custom notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: frequency == 'Harian' ? DateTimeComponents.time : null,
      payload: jsonEncode({
        'id': id,
        'frequency': frequency,
      }),
    );
  }

  Future<void> scheduleHealthCheckupNotification(
      int id,
      String title,
      String body,
      DateTime scheduledDate,
      ) async {
    // Konversi waktu ke zona waktu lokal dengan detik dan milidetik dinormalkan
    tz.TZDateTime scheduledTime = tz.TZDateTime(
      tz.local,
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      scheduledDate.hour,
      scheduledDate.minute,
    );

    // Periksa apakah waktu yang dijadwalkan sudah berlalu hari ini
    final currentTime = tz.TZDateTime.now(tz.local);

    // Validasi jika waktu yang dijadwalkan sudah lewat
    if (scheduledTime.isBefore(currentTime)) {
      throw Exception(
          "Waktu yang dijadwalkan sudah berlalu. Harap pilih waktu di masa depan."
      );
    }

    const AndroidNotificationDetails healthCheckupChannel = AndroidNotificationDetails(
      'health_checkup_channel_id',
      'Health Checkup Notifications',
      channelDescription: 'Channel for health checkup notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    // Jadwalkan notifikasi
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      const NotificationDetails(
        android: healthCheckupChannel,
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: jsonEncode({
        'id': id,
        'title': title,
        'body': body,
        'scheduledDate': scheduledDate.toIso8601String(),
      }),
    );
  }

  Future<void> scheduleNotificationWithCustomSound(
      int id,
      String title,
      String body,
      DateTime scheduledDate,
      String frequency,
      ) async {
    tz.TZDateTime scheduledTime;

    if (frequency == 'Harian') {
      scheduledTime = _nextInstanceOfDailyTime(scheduledDate);
    } else {
      scheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);
      if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
        // Jika waktu yang dijadwalkan sudah lewat, jadwalkan untuk hari berikutnya
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'wake_channel_id',
      'Wake Notifications',
      channelDescription: 'Channel for wake notifications',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('alarm'), // Use custom sound
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      const NotificationDetails(
        android: androidPlatformChannelSpecifics,
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: frequency == 'Harian' ? DateTimeComponents.time : null,
      payload: jsonEncode({
        'id': id,
        'frequency': frequency,
      }),
    );
  }

  Future<void> scheduleDynamicNotifications(
      int id,
      String title,
      String body,
      DateTime scheduledDate,
      String frequency,
      ) async {
    tz.TZDateTime scheduledTime;

    if (frequency == 'Harian') {
      scheduledTime = _nextInstanceOfDailyTime(scheduledDate);
    } else {
      scheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);
      if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
        // Jika waktu yang dijadwalkan sudah lewat, jadwalkan untuk hari berikutnya
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'custom_channel_id',
          'Custom Notifications',
          channelDescription: 'Channel for custom notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: frequency == 'Harian' ? DateTimeComponents.time : null,
      payload: jsonEncode({
        'id': id,
        'frequency': frequency,
      }),
    );
  }

  // Fungsi untuk mendapatkan waktu notifikasi harian berikutnya
  tz.TZDateTime _nextInstanceOfDailyTime(DateTime scheduledDate) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      scheduledDate.hour,
      scheduledDate.minute,
    );

    // Jika waktu yang dijadwalkan sudah lewat untuk hari ini, jadwalkan untuk besok
    return scheduledTime.isBefore(now)
        ? scheduledTime.add(const Duration(days: 1))
        : scheduledTime;
  }

  Future<void> rescheduleNotificationIfNeeded(
      int id, String title, String body, DateTime scheduledDate) async {
    final now = tz.TZDateTime.now(tz.local);

    // Waktu penjadwalan berikutnya
    final nextTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      scheduledDate.hour,
      scheduledDate.minute,
    ).isBefore(now)
        ? tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + 1,
      scheduledDate.hour,
      scheduledDate.minute,
    )
        : tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      scheduledDate.hour,
      scheduledDate.minute,
    );

    // Jadwalkan ulang
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      nextTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'custom_channel_id',
          'Custom Notifications',
          channelDescription: 'Channel for custom notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Fungsi untuk memperbarui konten notifikasi dinamis
  void updateNotificationContent(List<Map<String, dynamic>> suggestMenus, List<Map<String, dynamic>> suggestAvoids) {
    final random = Random();

    // Pilih menu secara acak
    final menuSarapan = suggestMenus.isNotEmpty ? suggestMenus[random.nextInt(suggestMenus.length)] : {};
    final menuMakanSiang = suggestMenus.isNotEmpty ? suggestMenus[random.nextInt(suggestMenus.length)] : {};
    final menuMakanMalam = suggestMenus.isNotEmpty ? suggestMenus[random.nextInt(suggestMenus.length)] : {};

    // Pilih makanan yang harus dihindari secara acak
    final avoidSarapan = suggestAvoids.isNotEmpty ? suggestAvoids[random.nextInt(suggestAvoids.length)] : {};
    final avoidMakanSiang = suggestAvoids.isNotEmpty ? suggestAvoids[random.nextInt(suggestAvoids.length)] : {};
    final avoidMakanMalam = suggestAvoids.isNotEmpty ? suggestAvoids[random.nextInt(suggestAvoids.length)] : {};

    // Format judul dan deskripsi notifikasi
    String titleSarapan = "Ayo Sarapan dengan ${menuSarapan['name']}";
    String descriptionSarapan = "Hindari konsumsi ${avoidSarapan['name']}";

    String titleMakanSiang = "Ayo Makan Siang dengan ${menuMakanSiang['name']}";
    String descriptionMakanSiang = "Hindari konsumsi ${avoidMakanSiang['name']}";

    String titleMakanMalam = "Ayo Makan Malam dengan ${menuMakanMalam['name']}";
    String descriptionMakanMalam = "Hindari konsumsi ${avoidMakanMalam['name']}";

    // Jadwalkan notifikasi
    scheduleDynamicNotifications(
      1,
      titleSarapan,
      descriptionSarapan,
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 0),
      'Harian',
    );

    scheduleDynamicNotifications(
      2,
      titleMakanSiang,
      descriptionMakanSiang,
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 12, 0),
      'Harian',
    );

    scheduleDynamicNotifications(
      4,
      titleMakanMalam,
      descriptionMakanMalam,
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 18, 0),
      'Harian',
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}