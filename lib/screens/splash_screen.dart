import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'beranda_screen.dart';
import '../api/notification_service.dart';
import '../api/api_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final NotificationService _notificationService = NotificationService();
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> _checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstInstall = prefs.getBool('isFirstInstall') ?? true;

    if (isFirstInstall) {
      // Tandai bahwa aplikasi tidak lagi dalam instalasi pertama
      await prefs.setBool('isFirstInstall', false);

      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => OnboardingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(milliseconds: 1000), // Durasi animasi
          ),
        );
      });
    } else {
      // Jika onboarding sudah selesai, biarkan _checkAuthToken mengatur navigasi
      return;
    }
  }

  Future<void> _checkAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstInstall = prefs.getBool('isFirstInstall') ?? true;

    // Jika onboarding belum selesai, abaikan logika token
    if (isFirstInstall) return;

    String? token = await _storage.read(key: 'auth_token');

    if (token != null) {
      // Verifikasi token jika diperlukan
    }

    Future.delayed(Duration(seconds: 2), () {
      if (token == null) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(milliseconds: 1000), // Durasi animasi
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => BerandaScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(milliseconds: 1500), // Durasi animasi
          ),
        );
      }
    });
  }

  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> _scheduleRepeatingNotifications() async {
    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel_id',
      'Scheduled Notifications',
      channelDescription: 'This channel is for scheduled notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    final List<Map<String, dynamic>> notifications = [
      {'id': 1, 'title': 'Notifikasi Sarapan', 'body': 'Ingatlah untuk sarapan pagi!', 'hour': 7, 'minute': 0},
      {'id': 2, 'title': 'Notifikasi Makan Siang', 'body': 'Sudah waktunya makan siang!', 'hour': 12, 'minute': 0},
      {'id': 3, 'title': 'Notifikasi Minum Penambah Stamina', 'body': 'Minumlah air untuk menambah stamina!', 'hour': 15, 'minute': 0},
      {'id': 4, 'title': 'Notifikasi Makan Malam', 'body': 'Sudah waktunya makan malam!', 'hour': 18, 'minute': 0},
    ];

    final prefs = await SharedPreferences.getInstance();
    final now = tz.TZDateTime.now(tz.local);

    for (var notification in notifications) {
      final scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        notification['hour'],
        notification['minute'],
      );

      final nextTime = scheduledTime.isBefore(now)
          ? scheduledTime.add(const Duration(days: 1))
          : scheduledTime;

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notification['id'],
        notification['title'],
        notification['body'],
        nextTime,
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      await prefs.setInt('notification_${notification['id']}', notification['id']);
    }
  }

  Future<void> _scheduleDefaultSleepWakeNotifications() async {
    final now = tz.TZDateTime.now(tz.local);

    final sleepScheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      22,
      0,
    );

    final wakeScheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + 1,
      6,
      0,
    );

    await _notificationService.scheduleNotification(
      100,
      'Pengingat Tidur',
      'Ayo tidur, jangan forsir dirimu!',
      sleepScheduledTime,
      'Harian',
    );

    await _notificationService.scheduleNotificationWithCustomSound(
      101,
      'Pengingat Bangun',
      'BANGON BANGON SUDAH PAGI!',
      wakeScheduledTime,
      'Harian',
    );
  }

  Future<void> _scheduleDefaultExerciseNotifications() async {
    final now = tz.TZDateTime.now(tz.local);

    final List<Map<String, dynamic>> exerciseNotifications = [
      {'id': 200, 'title': 'Jogging', 'body': 'Ingatlah untuk jogging pagi!', 'hour': 5, 'minute': 0},
      {'id': 201, 'title': 'Peregangan', 'body': 'Ingatlah untuk peregangan siang!', 'hour': 11, 'minute': 0},
      {'id': 202, 'title': 'Gym', 'body': 'Ingatlah untuk gym sore!', 'hour': 19, 'minute': 0},
    ];

    for (var notification in exerciseNotifications) {
      final scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        notification['hour'],
        notification['minute'],
      );

      final nextTime = scheduledTime.isBefore(now)
          ? scheduledTime.add(const Duration(days: 1))
          : scheduledTime;

      await _notificationService.scheduleNotification(
        notification['id'],
        notification['title'],
        notification['body'],
        nextTime,
        'Harian',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    _scheduleRepeatingNotifications();
    _scheduleDefaultSleepWakeNotifications();
    _scheduleDefaultExerciseNotifications();

    // Prioritaskan onboarding status
    _checkOnboardingStatus().then((_) {
      // Periksa token hanya jika onboarding tidak diperlukan
      _checkAuthToken();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1FC29D),
              Color(0xFF0F5C4A),
            ],
            transform: GradientRotation(240 * 3.1415926535 / 180),
          ),
        ),
        child: Center(
          child: Image.asset(
            'assets/images/icon.png',
            width: 100,
            height: 100,
          ),
        ),
      ),
    );
  }
}