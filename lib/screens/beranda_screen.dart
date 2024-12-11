import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'pengingat_screen.dart';
import 'artikel_screen.dart';
import 'profil_screen.dart';
import 'verification_screen.dart';
import 'personalization_screen.dart';
import 'detail_article_screen.dart';
import 'tambah_jadwal_makan.dart';
import 'tambah_jadwal_tidur.dart';
import 'tambah_jadwal_cek_kesehatan.dart';
import 'tambah_jadwal_olahraga.dart';
import '../api/notification_service.dart';
import '../api/api_service.dart';
import '../core/config/theme/app_colors.dart';
import '../core/config/strings/app_text.dart';
import '../core/config/assets/app_vectors.dart';

class BerandaScreen extends StatefulWidget {
  @override
  _BerandaScreenState createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  int _currentIndex = 0;
  final _apiService = ApiService();
  List<Map<String, dynamic>> suggestMenus = [];
  List<Map<String, dynamic>> suggestAvoids = [];
  List<Map<String, dynamic>> suggestedArticles = [];

  final List<Widget> _screens = [
    BerandaContentScreen(),
    PengingatScreen(),
    ArtikelScreen(),
    ProfilScreen(),
  ];

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
    _loadArticles();
    _initializeNotifications();
    _checkEmailVerificationAndPersonalization();
  }

  void startBackgroundService() {
    AndroidAlarmManager.periodic(
      const Duration(hours: 1), // Ulangi setiap 1 jam
      0, // ID alarm
          () async {
        _loadSuggestions();
      },
    );
  }

  // Fungsi untuk mengambil data dari API
  Future<void> _loadSuggestions() async {
    try {
      suggestMenus = await _apiService.getSuggestMenus();
      suggestAvoids = await _apiService.getSuggestAvoids();
      setState(() {
        _notificationService.updateNotificationContent(suggestMenus, suggestAvoids);
      });
    } catch (e) {
      print("Error fetching suggestions: $e");
    }
  }

  // Fungsi untuk mengambil artikel dari API
  Future<void> _loadArticles() async {
    try {
      suggestedArticles = await _apiService.getSuggestedArticles();
      setState(() {});
    } catch (e) {
      print("Error fetching articles: $e");
    }
  }

  // Inisialisasi notifikasi lokal
  void _initializeNotifications() async {
    await _notificationService.initializeNotifications();
  }

  // Fungsi untuk mengecek verifikasi email dan personalisasi
  Future<void> _checkEmailVerificationAndPersonalization() async {
    bool isVerified = await _apiService.isEmailVerified();
    if (!isVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => VerificationScreen()),
      );
    } else {
      bool hasPersonalizationData = await _apiService.hasPersonalizationData();
      if (!hasPersonalizationData) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PersonalizationScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.alarm),
              label: 'Pengingat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article),
              label: 'Artikel',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}

class BerandaContentScreen extends StatefulWidget {
  @override
  _BerandaContentScreenState createState() => _BerandaContentScreenState();
}

class _BerandaContentScreenState extends State<BerandaContentScreen> {
  final _apiService = ApiService();
  String _userName = "John Doe";
  bool _isPengingatMakanEnabled = true;
  bool _isPengingatTidurEnabled = true;
  bool _isPengingatCekKesehatanEnabled = true;
  bool _isPengingatOlahragaEnabled = true;
  bool _isSarapanEnabled = true;
  bool _isMakanSiangEnabled = true;
  bool _isMakanMalamEnabled = true;
  bool _isCamilanEnabled = true;
  bool _isJoggingEnabled = true;
  bool _isPereganganEnabled = true;
  bool _isGymEnabled = true;
  List<Map<String, dynamic>> suggestedArticles = [];
  List<Map<String, dynamic>> _sleepReminders = [];
  List<Map<String, dynamic>> _specialSchedules = [];
  List<Map<String, dynamic>> _healthCheckupReminders = [];
  List<dynamic> _lightActivityReminders = [];

  // Deklarasi notification_id dari Jadwal Bawaan Pengingat Olahraga
  final Map<String, int> _notificationIds = {
    'Jogging': 200,
    'Peregangan': 201,
    'Gym': 202,
  };

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadToggleValues();
    _loadArticles();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('user_name');
    if (userName != null) {
      setState(() {
        _userName = userName;
      });
    }
  }

  Future<void> _saveUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', userName);
  }

  Future<void> _loadToggleValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPengingatMakanEnabled = prefs.getBool('isPengingatMakanEnabled') ?? true;
      _isPengingatTidurEnabled = prefs.getBool('isPengingatTidurEnabled') ?? true;
      _isPengingatOlahragaEnabled = prefs.getBool('isPengingatOlahragaEnabled') ?? true;
      _isPengingatCekKesehatanEnabled = prefs.getBool('isPengingatCekKesehatanEnabled') ?? true;
    });
  }

  Future<void> _saveToggleValue(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<List<Map<String, dynamic>>> _fetchSuggestMenus() async {
    try {
      return await _apiService.getSuggestMenus();
    } catch (e) {
      print("Error fetching suggest menus: $e");
      return []; // Kembalikan daftar kosong jika terjadi error
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSuggestAvoids() async {
    try {
      return await _apiService.getSuggestAvoids();
    } catch (e) {
      print("Error fetching suggest avoids: $e");
      return []; // Kembalikan daftar kosong jika terjadi error
    }
  }

  // Menyalakan semua notifikasi Pengingat Makan
  void _enableAllMealSchedules() async {
    // Aktifkan notifikasi pada semua jadwal bawaan yang saat ini enabled
    if (_isSarapanEnabled) {
      _notificationService.updateNotificationContent(await _fetchSuggestMenus(), await _fetchSuggestAvoids());
    }
    if (_isMakanSiangEnabled) {
      _notificationService.updateNotificationContent(await _fetchSuggestMenus(), await _fetchSuggestAvoids());
    }
    if (_isMakanMalamEnabled) {
      _notificationService.updateNotificationContent(await _fetchSuggestMenus(), await _fetchSuggestAvoids());
    }
    if (_isCamilanEnabled) {
      _notificationService.updateNotificationContent(await _fetchSuggestMenus(), await _fetchSuggestAvoids());
    }

    // Aktifkan notifikasi untuk jadwal khusus yang enabled
    for (final schedule in _specialSchedules) {
      if (schedule['toggle_value'] == 1 && schedule['meal_frequency'] == 1) { // Periksa frekuensi harian
        final scheduledDate = DateTime.now().copyWith(
          hour: schedule['meal_hour'],
          minute: schedule['meal_minute'],
          second: 0,
        );
        await _notificationService.scheduleNotification(
          schedule['id'],
          'Pengingat Makan Khusus',
          'Saatnya makan: ${schedule['meal_name']}',
          scheduledDate,
          'Harian', // Hanya jadwalkan ulang untuk harian
        );
      }
    }

    // Panggil fungsi untuk memperbarui konten notifikasi dinamis
    List<Map<String, dynamic>> suggestMenus = await _apiService.getSuggestMenus();
    List<Map<String, dynamic>> suggestAvoids = await _apiService.getSuggestAvoids();
    _notificationService.updateNotificationContent(suggestMenus, suggestAvoids);
  }

  // Mematikan semua notifikasi Pengingat Makan
  void _disableAllMealNotifications() async {
    // Nonaktifkan semua notifikasi pada jadwal bawaan
    _notificationService.cancelNotification(1); // Sarapan
    _notificationService.cancelNotification(2); // Makan Siang
    _notificationService.cancelNotification(3); // Makan Malam
    _notificationService.cancelNotification(4); // Camilan

    // Nonaktifkan semua notifikasi pada jadwal khusus
    for (final schedule in _specialSchedules) {
      await _notificationService.cancelNotification(schedule['id']);
    }
  }

  // Menyalakan semua notifikasi Pengingat Tidur
  void _enableAllSleepReminders() {
    if (_isPengingatTidurEnabled) {
      // Aktifkan notifikasi jadwal tidur bawaan
      _notificationService.rescheduleNotificationIfNeeded(
        100,
        'Pengingat Tidur',
        'Ayo tidur, jangan forsir dirimu!',
        DateTime(0, 0, 0, 22, 0),
      );

      _notificationService.rescheduleNotificationIfNeeded(
        101,
        'Pengingat Bangun',
        'BANGON BANGON SUDAH PAGI!',
        DateTime(0, 0, 0, 6, 0),
      );

      // Aktifkan jadwal tambahan
      for (final reminder in _sleepReminders) {
        if (reminder['toggle_state'] == true) {
          final sleepTime = DateTime.now().copyWith(
            hour: reminder['sleep_hour'],
            minute: reminder['sleep_minute'],
            second: 0,
          );
          final wakeTime = DateTime.now().copyWith(
            hour: reminder['wake_hour'],
            minute: reminder['wake_minute'],
            second: 0,
          );

          _notificationService.scheduleNotification(
            reminder['id'],
            'Pengingat Tidur',
            'Ayo tidur, jangan forsir dirimu!',
            sleepTime,
            reminder['sleep_frequency'] == 1 ? 'Harian' : 'Sekali',
          );

          _notificationService.scheduleNotificationWithCustomSound(
            reminder['id'] + 1,
            'Pengingat Bangun',
            'BANGON BANGON SUDAH PAGI!',
            wakeTime,
            reminder['sleep_frequency'] == 1 ? 'Harian' : 'Sekali',
          );
        }
      }
    }
  }

  // Mematikan semua notifikasi Pengingat Tidur
  void _disableAllSleepReminders() {
    // Nonaktifkan semua notifikasi pada jadwal bawaan
    try {
      _notificationService.cancelNotification(100); // Notifikasi tidur bawaan
      _notificationService.cancelNotification(101); // Notifikasi bangun bawaan

      // Nonaktifkan semua notifikasi pada jadwal khusus
      for (final reminder in _sleepReminders) {
        final sleepId = reminder['id'];
        final wakeId = sleepId + 1;

        _notificationService.cancelNotification(sleepId);
        _notificationService.cancelNotification(wakeId);
      }
      print("Semua notifikasi pengingat tidur berhasil dibatalkan.");
    } catch (e) {
      print("Error membatalkan semua pengingat tidur: $e");
    }
  }

  // Toggle Switch Pengingat Olahraga
  void _toggleNotification(String activityName, bool isEnabled, DateTime scheduledDate, String frequency, String title, String body) {
    final notificationId = _notificationIds[activityName];
    if (notificationId != null) {
      if (isEnabled) {
        _notificationService.scheduleNotification(
          notificationId,
          title,
          body,
          scheduledDate,
          frequency,
        );
      } else {
        _notificationService.cancelNotification(notificationId);
      }
    }
  }

  void _enableAllExerciseReminders() {
    // Reschedule notifications for default schedules
    _toggleNotification(
        'Jogging', _isJoggingEnabled,
        DateTime.now().add(Duration(hours: 5)),
        'Harian',
        'Jogging',
        'Ingatlah untuk jogging pagi!'
    );
    _toggleNotification(
        'Peregangan', _isPereganganEnabled,
        DateTime.now().add(Duration(hours: 11)),
        'Harian',
        'Peregangan',
        'Ingatlah untuk peregangan otot!'
    );
    _toggleNotification(
        'Gym', _isGymEnabled,
        DateTime.now().add(Duration(hours: 19)),
        'Harian',
        'Gym',
        'Ingatlah untuk gym!'
    );

    // Reschedule notifications for custom schedules
    for (var reminder in _lightActivityReminders) {
      final scheduledDate = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        reminder['activity_hour'],
        reminder['activity_minute'],
      );
      _toggleNotification(reminder['activity_name'],
          reminder['toggle_value'] == 1, scheduledDate,
          reminder['activity_frequency'] == 1 ? 'Harian' : 'Sekali',
          reminder['activity_name'], 'Ingatlah untuk ${reminder['activity_name'].toLowerCase()}!');
    }
  }

  // Mematikan semua notifikasi Pengingat Olahraga
  void _disableAllExerciseReminders() {
    // Cancel notifications for default schedules
    _notificationService.cancelNotification(_notificationIds['Jogging']!);
    _notificationService.cancelNotification(_notificationIds['Peregangan']!);
    _notificationService.cancelNotification(_notificationIds['Gym']!);

    // Cancel notifications for custom schedules
    for (var reminder in _lightActivityReminders) {
      final notificationId = _notificationIds[reminder['activity_name']];
      if (notificationId != null) {
        _notificationService.cancelNotification(notificationId);
      }
    }
  }

  Future<void> _enableAllCheckupReminders() async {
    if (_healthCheckupReminders == null || _healthCheckupReminders.isEmpty) {
      return; // Pastikan daftar tidak kosong atau null
    }

    final now = DateTime.now();
    for (var reminder in _healthCheckupReminders) {
      try {
        // Validasi bahwa reminder memiliki kunci yang dibutuhkan
        if (reminder.containsKey('checkup_year') &&
            reminder.containsKey('checkup_month') &&
            reminder.containsKey('checkup_date') &&
            reminder.containsKey('checkup_hour') &&
            reminder.containsKey('checkup_minute')) {
          final date = DateTime(
            reminder['checkup_year'],
            reminder['checkup_month'],
            reminder['checkup_date'],
            reminder['checkup_hour'],
            reminder['checkup_minute'],
          );
          if (date.isAfter(now)) {
            await _notificationService.scheduleHealthCheckupNotification(
              reminder['id'],
              reminder['checkup_name'],
              reminder['checkup_note'],
              date,
            );
          }
        }
      } catch (e) {
        print('Error scheduling reminder: $e');
      }
    }
  }

  Future<void> _disableAllCheckupReminders() async {
    try {
      final notificationService = NotificationService();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? checkupReminderIds = prefs.getStringList('checkupReminderIds');

      if (checkupReminderIds != null) {
        for (String id in checkupReminderIds) {
          try {
            await notificationService.cancelNotification(int.parse(id));
          } catch (e) {
            print('Error cancelling notification with ID $id: $e');
          }
        }
        await prefs.remove('checkupReminderIds');
      }
    } catch (e) {
      print('Error disabling all checkup reminders: $e');
    }
  }

  // Fungsi untuk mengambil artikel dari API
  Future<void> _loadArticles() async {
    try {
      suggestedArticles = await ApiService().getSuggestedArticles();
      print("Articles fetched successfully");
      setState(() {});
    } catch (e) {
      print("Error fetching articles: $e");
    }
  }

  void _showInfoDialog(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          content: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.darkGrey,
            ),
          ),
          actions: [
            Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                width: 76.0,
                height: 34.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    "Tutup",
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String displayName = _userName.split(' ')[0];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
          ),
          Positioned(
            top: -90,
            right: -180,
            child: Container(
              width: 500,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment.center,
                  colors: [
                    Color(0xFF2CE4BB),
                    AppColors.primary,
                  ],
                  stops: [0.4, 1.0],
                  radius: 0.3,
                ),
              ),
            ),
          ),
          ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hai, $displayName",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  BerandaText.rekomendasiHariIni, // Menggunakan BerandaText.rekomendasiHariIni
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              _buildCard(
                icon: Icons.info_outline_rounded,
                title: BerandaText.minumAir,
                infoContent: BerandaText.contentMinumAir,
              ),
              _buildCard(
                icon: Icons.info_outline_rounded,
                title: BerandaText.peregangan,
                infoContent: BerandaText.contentPeregangan,
              ),
              _buildCard(
                icon: Icons.info_outline_rounded,
                title: BerandaText.tidurSiang,
                infoContent: BerandaText.contentTidurSiang,
              ),
              SizedBox(height: 40.0),

              Stack(
                children: [
                  SizedBox(
                    height: 100,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300], // Warna abu-abu
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 0.0),
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.0),
                          topRight: Radius.circular(24.0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0, top: 16.0),
                            child: Text(
                              BerandaText.pengingatmu,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.darkGrey),
                            ),
                          ),
                          _buildReminderCard(context),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 46.0, bottom: 4.0),
                            child: Text(
                              BerandaText.rekomendasiArtikel,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.darkGrey),
                            ),
                          ),
                          if (suggestedArticles.isNotEmpty)
                            ...suggestedArticles.map((article) {
                              return _buildArticleCard(
                                imagePath: article['image_url'],
                                title: article['title'],
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailArticleScreen(article: article),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String infoContent, // Tambahkan parameter untuk konten info
    bool showCloseButton = false,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      elevation: (0.0),
      child: Padding(
        padding: const EdgeInsets.only(left: 6.0, right: 10.0, top: 8.0, bottom: 8.0),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                icon,
                color: AppColors.primary, // Menggunakan AppColors.primary
              ),
              onPressed: () {
                // Panggil fungsi untuk menampilkan modal dialog dengan konten yang sesuai
                _showInfoDialog(context, infoContent);
              },
            ),
            SizedBox(width: 4.0), // Jarak antara icon dan title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary, // Menggunakan AppColors.primary
                ),
              ),
            ),
            if (showCloseButton)
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: AppColors.primary, // Menggunakan AppColors.primary
                ),
                onPressed: () {
                  // Logika untuk menutup card
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 0.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColors.lightGrey),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10.0, bottom: 10.0),
            child: Column(
              children: [
                Card(
                  color: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 6.0, top: 6.0, bottom: 6.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: SvgPicture.asset(
                            AppVectors.iconMakan,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text(
                            'Pengingat Makan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Spacer(),
                        Transform.scale(
                          scale: 0.9,
                          child: CupertinoSwitch(
                            value: _isPengingatMakanEnabled,
                            onChanged: (value) async {
                              setState(() {
                                _isPengingatMakanEnabled = value;
                                _saveToggleValue('isPengingatMakanEnabled', value);
                              });

                              if (value) {
                                _enableAllMealSchedules();
                              } else {
                                _disableAllMealNotifications();
                              }
                            },
                            activeColor: AppColors.lightGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TambahJadwalMakanScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: AppColors.primary),
                        SizedBox(width: 4.0),
                        Text(
                          ButtonBerandaText.tambahJadwalMakan,
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.0),
        Card(
          elevation: (0.0),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColors.lightGrey), // Menggunakan AppColors.lightGrey
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10.0, bottom: 10.0),
            child: Column(
              children: [
                Card(
                  color: AppColors.primary, // Menggunakan AppColors.primary
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 6.0, top: 6.0, bottom: 6.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: SvgPicture.asset(
                            AppVectors.iconTidur, // Menggunakan AppVectors.iconTidur
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text(
                            'Pengingat Tidur',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Spacer(),
                        Transform.scale(
                          scale: 0.9,
                          child: CupertinoSwitch(
                            value: _isPengingatTidurEnabled,
                            onChanged: (value) async {
                              setState(() {
                                _isPengingatTidurEnabled = value;
                                _saveToggleValue('isPengingatTidurEnabled', value);
                              });

                              if (value) {
                                // Aktifkan semua notifikasi jadwal tidur
                                _enableAllSleepReminders();
                              } else {
                                // Nonaktifkan semua notifikasi jadwal tidur
                                _disableAllSleepReminders();
                              }
                            },
                            activeColor: AppColors.lightGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TambahJadwalTidurScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary, // Menggunakan AppColors.primary
                      elevation: (0.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(color: AppColors.primary), // Menggunakan AppColors.primary
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: AppColors.primary), // Menggunakan AppColors.primary
                        SizedBox(width: 4.0),
                        Text(
                          ButtonBerandaText.tambahJadwalTidur, // Menggunakan BerandaText.tambahJadwalTidur
                          style: TextStyle(color: AppColors.primary), // Menggunakan AppColors.primary
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.0),
        Card(
          elevation: (0.0),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColors.lightGrey), // Menggunakan AppColors.lightGrey
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10.0, bottom: 10.0),
            child: Column(
              children: [
                Card(
                  color: AppColors.primary, // Menggunakan AppColors.primary
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 6.0, top: 6.0, bottom: 6.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: SvgPicture.asset(
                            AppVectors.iconOlahraga, // Menggunakan AppVectors.iconOlahraga
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text(
                            'Pengingat Olahraga',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Spacer(),
                        Transform.scale(
                          scale: 0.9,
                          child: CupertinoSwitch(
                            value: _isPengingatOlahragaEnabled,
                            onChanged: (value) async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              setState(() {
                                _isPengingatOlahragaEnabled = value;
                                _saveToggleValue('isPengingatOlahragaEnabled', value);
                              });

                              if (!value) {
                                _disableAllExerciseReminders();
                              } else {
                                _enableAllExerciseReminders();
                              }
                            },
                            activeColor: AppColors.lightGrey, // Menggunakan AppColors.lightGrey
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TambahJadwalOlahragaScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary, // Menggunakan AppColors.primary
                      elevation: (0.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(color: AppColors.primary), // Menggunakan AppColors.primary
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: AppColors.primary),
                        SizedBox(width: 4.0),
                        Text(
                          ButtonBerandaText.tambahJadwalOlahraga,
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        Card(
          elevation: (0.0),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColors.lightGrey), // Menggunakan AppColors.lightGrey
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10.0, bottom: 10.0),
            child: Column(
              children: [
                Card(
                  color: AppColors.primary, // Menggunakan AppColors.primary
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 6.0, top: 6.0, bottom: 6.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: SvgPicture.asset(
                            AppVectors.iconCheckup,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text(
                            'Pengingat Cek Kesehatan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Spacer(),
                        Transform.scale(
                          scale: 0.9,
                          child: CupertinoSwitch(
                            value: _isPengingatCekKesehatanEnabled,
                            onChanged: (value) async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              setState(() {
                                _isPengingatCekKesehatanEnabled = value;
                                _saveToggleValue('isPengingatCekKesehatanEnabled', value);
                              });

                              if (!value) {
                                _disableAllCheckupReminders();
                              } else {
                                _enableAllCheckupReminders();
                              }
                            },
                            activeColor: AppColors.lightGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TambahJadwalCekKesehatanScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary, // Menggunakan AppColors.primary
                      elevation: (0.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(color: AppColors.primary), // Menggunakan AppColors.primary
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: AppColors.primary),
                        SizedBox(width: 4.0),
                        Text(
                          ButtonBerandaText.tambahJadwalCheckup,
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArticleCard({
    required String imagePath,
    required String title,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: (0.0),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.lightGrey),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          height: 130,
          child: Row(
            children: [
              Container(
                width: 110,
                height: 110,
                margin: EdgeInsets.only(left: 10.0, right: 4.0, bottom: 8.0, top: 8.0),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: Offset(0, 0)
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: SizedBox(
                          width: 130,
                          height: 34,
                          child: ElevatedButton(
                            onPressed: onPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary, // Menggunakan AppColors.primary
                              foregroundColor: Colors.white,
                              elevation: (0.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              ButtonBerandaText.selengkapnya,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}