import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'timezone_helper.dart';
import 'screens/splash_screen.dart';
import 'api/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi timezone
  TimezoneHelper.initializeTimezone();

  // Inisialisasi notifikasi
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const androidInitialization = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettings = InitializationSettings(android: androidInitialization);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Inisialisasi layanan notifikasi
  await NotificationService().initializeNotifications();

  // Meminta izin SCHEDULE_EXACT_ALARM saat aplikasi pertama kali dijalankan
  await requestExactAlarmPermission();

  // Jalankan aplikasi
  runApp(const MyApp());
}

Future<void> requestExactAlarmPermission() async {
  PermissionStatus status = await Permission.scheduleExactAlarm.request();
  if (status.isGranted) {
    print('Izin SCHEDULE_EXACT_ALARM diberikan');
  } else {
    print('Izin SCHEDULE_EXACT_ALARM ditolak');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zynergy',
      theme: ThemeData(
          fontFamily: 'Geist'
      ),
      home: SplashScreen(),
    );
  }
}