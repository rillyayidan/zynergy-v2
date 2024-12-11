import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tambah_jadwal_tidur.dart';
import 'edit_jadwal_tidur.dart';
import '../core/config/strings/app_text.dart';
import '../core/config/theme/app_colors.dart';
import '../core/config/assets/app_vectors.dart';
import '../api/api_service.dart';
import '../api/notification_service.dart';

class PengingatTidurScreen extends StatefulWidget {
  final bool isPengingatTidurEnabled;

  PengingatTidurScreen({this.isPengingatTidurEnabled = true});

  @override
  _PengingatTidurScreenState createState() => _PengingatTidurScreenState();
}

class _PengingatTidurScreenState extends State<PengingatTidurScreen> {
  bool _isPengingatTidurEnabled = true;
  bool _isJadwalBawaanEnabled = true;
  List<Map<String, dynamic>> _sleepReminders = [];
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _fetchSleepReminders();
    _isPengingatTidurEnabled = widget.isPengingatTidurEnabled;
    _loadToggleValues();
  }

  Future<void> _fetchSleepReminders() async {
    final response = await _apiService.getSleepReminders();
    if (response.success) {
      setState(() {
        _sleepReminders = List<Map<String, dynamic>>.from(response.data);
        // Set toggle_value to 1 for new reminders
        _sleepReminders.forEach((reminder) {
          reminder['toggle_state'] = reminder['toggle_value'] == 1;
        });
      });
    } else {
      // Handle error
      print('Error: ${response.message}');
    }
  }

  Future<void> _updateToggleValueSleepReminder(int id, bool value) async {
    try {
      await _apiService.updateToggleValueSleepReminder(id, value ? 1 : 0);

      if (value) {
        // Jadwalkan ulang notifikasi jika toggle switch diaktifkan kembali
        final reminder = _sleepReminders.firstWhere((reminder) => reminder['id'] == id);
        DateTime sleepScheduledDate = DateTime.now().copyWith(
          hour: reminder['sleep_hour'],
          minute: reminder['sleep_minute'],
          second: 0,
        );
        DateTime wakeScheduledDate = DateTime.now().copyWith(
          hour: reminder['wake_hour'],
          minute: reminder['wake_minute'],
          second: 0,
        );

        await _notificationService.scheduleNotification(
          id,
          'Pengingat Tidur',
          'Ingatlah untuk tidur sesuai jadwal!',
          sleepScheduledDate,
          reminder['sleep_frequency'] == 1 ? 'Harian' : 'Sekali',
        );

        await _notificationService.scheduleNotificationWithCustomSound(
          id + 1,
          'Pengingat Bangun',
          'Ingatlah untuk bangun sesuai jadwal!',
          wakeScheduledDate,
          reminder['sleep_frequency'] == 1 ? 'Harian' : 'Sekali',
        );
      } else {
        // Batalkan notifikasi jika toggle switch dinonaktifkan
        await _notificationService.cancelNotification(id);
        await _notificationService.cancelNotification(id + 1);
      }
    } catch (e) {
      print("Error updating toggle value: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating toggle value: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToAddSleepReminder() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TambahJadwalTidurScreen()),
    ).then((_) => _fetchSleepReminders());
  }

  void _navigateToEditSleepReminder(Map<String, dynamic> reminder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditJadwalTidurScreen(
          id: reminder['id'],
          sleepName: reminder['sleep_name'],
          sleepHour: reminder['sleep_hour'],
          sleepMinute: reminder['sleep_minute'],
          wakeHour: reminder['wake_hour'],
          wakeMinute: reminder['wake_minute'],
          sleepFrequency: reminder['sleep_frequency'] == 0 ? 'Sekali' : 'Harian',
        ),
      ),
    ).then((_) => _fetchSleepReminders());
  }

  Future<void> _loadToggleValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPengingatTidurEnabled = prefs.getBool('isPengingatTidurEnabled') ?? true;
      _isJadwalBawaanEnabled = prefs.getBool('isJadwalBawaanEnabled') ?? true; // Tambahkan ini
    });
  }

  Future<void> _saveToggleValue(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _enableAllSleepReminders() {
    // Aktifkan notifikasi pada semua jadwal bawaan yang saat ini enabled
    if (_isJadwalBawaanEnabled) {
      final sleepScheduledDate = DateTime(0, 0, 0, 22, 0); // Waktu tidur
      final wakeScheduledDate = DateTime(0, 0, 0, 6, 0); // Waktu bangun

      _notificationService.rescheduleNotificationIfNeeded(
        100, // ID notifikasi tidur
        'Pengingat Tidur',
        'Ayo tidur, jangan forsir dirimu!',
        sleepScheduledDate,
      );

      _notificationService.rescheduleNotificationIfNeeded(
        101, // ID notifikasi bangun
        'Pengingat Bangun',
        'BANGON BANGON SUDAH PAGI!',
        wakeScheduledDate,
      );
    }

    // Aktifkan notifikasi untuk jadwal khusus yang enabled
    for (final reminder in _sleepReminders) {
      if (reminder['toggle_state'] == true) {
        final sleepScheduledDate = DateTime.now().copyWith(
          hour: reminder['sleep_hour'],
          minute: reminder['sleep_minute'],
          second: 0,
        );
        final wakeScheduledDate = DateTime.now().copyWith(
          hour: reminder['wake_hour'],
          minute: reminder['wake_minute'],
          second: 0,
        );

        _notificationService.scheduleNotification(
          reminder['id'],
          'Pengingat Tidur',
          'Ayo tidur, jangan forsir dirimu!',
          sleepScheduledDate,
          reminder['sleep_frequency'] == 1 ? 'Harian' : 'Sekali',
        );

        _notificationService.scheduleNotificationWithCustomSound(
          reminder['id'] + 1,
          'Pengingat Bangun',
          'BANGON BANGON SUDAH PAGI!',
          wakeScheduledDate,
          reminder['sleep_frequency'] == 1 ? 'Harian' : 'Sekali',
        );
      }
    }
  }

  void _disableAllSleepReminders() {
    // Nonaktifkan semua notifikasi pada jadwal bawaan
    _notificationService.cancelNotification(100); // Tidur
    _notificationService.cancelNotification(101); // Bangun
    print('Sudah dimatikan semua');

    // Nonaktifkan semua notifikasi pada jadwal khusus
    for (final reminder in _sleepReminders) {
      _notificationService.cancelNotification(reminder['id']); // Tidur
      _notificationService.cancelNotification(reminder['id'] + 1); // Bangun
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Pengingat Tidur',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 16),
              sliver: SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isPengingatTidurEnabled = !_isPengingatTidurEnabled;
                      _saveToggleValue('isPengingatTidurEnabled', _isPengingatTidurEnabled);
                    });

                    if (_isPengingatTidurEnabled) {
                      // Aktifkan semua jadwal yang enabled
                      _enableAllSleepReminders();
                    } else {
                      // Nonaktifkan semua notifikasi
                      _disableAllSleepReminders();
                    }
                  },
                  child: Card(
                    color: AppColors.primary,
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
                              AppVectors.iconMalam,
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
                              onChanged: (value) {
                                setState(() {
                                  _isPengingatTidurEnabled = value;
                                  _saveToggleValue('isPengingatTidurEnabled', value);
                                });

                                if (value) {
                                  // Aktifkan semua jadwal yang enabled
                                  _enableAllSleepReminders();
                                } else {
                                  // Nonaktifkan semua notifikasi
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
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              sliver: SliverToBoxAdapter(
                child: Text(
                  PengingatDetailText.jadwalBawaan,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildScheduleCard(
                [
                  {'time': '06:00', 'description': 'Jam Bangun'},
                  {'time': '22:00', 'description': 'Jam Tidur'},
                ],
                'Direkomendasikan',
                _isJadwalBawaanEnabled, // Gunakan status toggle
                    (value) {
                  setState(() {
                    _isJadwalBawaanEnabled = value;
                    _saveToggleValue('isJadwalBawaanEnabled', value); // Menyimpan status toggle

                    if (value) {
                      // Jika diaktifkan, jadwalkan notifikasi
                      final sleepScheduledDate = DateTime(0, 0, 0, 22, 0); // Waktu tidur
                      final wakeScheduledDate = DateTime(0, 0, 0, 6, 0); // Waktu bangun

                      _notificationService.rescheduleNotificationIfNeeded(
                        1, // ID notifikasi tidur
                        'Notifikasi Tidur',
                        'Ingatlah untuk tidur!',
                        sleepScheduledDate,
                      );

                      _notificationService.rescheduleNotificationIfNeeded(
                        2, // ID notifikasi bangun
                        'Notifikasi Bangun',
                        'Ingatlah untuk bangun!',
                        wakeScheduledDate,
                      );
                    } else {
                      // Jika dinonaktifkan, batalkan notifikasi
                      _notificationService.cancelNotification(1); // Tidur
                      _notificationService.cancelNotification(2); // Bangun
                    }
                  });
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              sliver: SliverToBoxAdapter(
                child: Text(
                  PengingatDetailText.jadwalKhusus,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 10.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final reminder = _sleepReminders[index];
                    return _buildScheduleCardWithEdit(
                      [
                        {'time': '${reminder['sleep_hour'].toString().padLeft(2, '0')}:${reminder['sleep_minute'].toString().padLeft(2, '0')}', 'description': 'Jam Tidur'},
                        {'time': '${reminder['wake_hour'].toString().padLeft(2, '0')}:${reminder['wake_minute'].toString().padLeft(2, '0')}', 'description': 'Jam Bangun'},
                      ],
                      reminder['sleep_name'],
                      reminder['toggle_state'] ?? false, // Provide default value
                          (value) {
                        setState(() {
                          reminder['toggle_state'] = value;
                          _updateToggleValueSleepReminder(reminder['id'], value);
                        });
                      },
                          () {
                        _navigateToEditSleepReminder(reminder);
                      },
                    );
                  },
                  childCount: _sleepReminders.length,
                ),
              ),
            ),
          ],
        ),
      ),
      persistentFooterButtons: [
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton(
            onPressed: _navigateToAddSleepReminder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.scale(
                      scale: 0.7,
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Text(
                        ButtonPengingatText.tambah,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard(List<Map<String, String>> times, String frequency, bool isEnabled, ValueChanged<bool> onChanged) {
    return Card(
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: AppColors.lightGrey,
          width: 1.0,
        ),
      ),
      child: SizedBox(
        height: 120,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 12.0, top: 18.0, bottom: 18.0),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: times.map((time) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        time['time']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        time['description']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      frequency,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              CupertinoSwitch(
                value: isEnabled,
                onChanged: (value) {
                  setState(() {
                    _isJadwalBawaanEnabled = value;
                    _saveToggleValue('isJadwalBawaanEnabled', value); // Menyimpan status toggle

                    if (value) {
                      // Jika diaktifkan, jadwalkan notifikasi
                      final sleepScheduledDate = DateTime(0, 0, 0, 22, 0); // Waktu tidur
                      final wakeScheduledDate = DateTime(0, 0, 0, 6, 0); // Waktu bangun

                      _notificationService.rescheduleNotificationIfNeeded(
                        1, // ID notifikasi tidur
                        'Notifikasi Tidur',
                        'Ingatlah untuk tidur!',
                        sleepScheduledDate,
                      );

                      _notificationService.rescheduleNotificationIfNeeded(
                        2, // ID notifikasi bangun
                        'Notifikasi Bangun',
                        'Ingatlah untuk bangun!',
                        wakeScheduledDate,
                      );
                    } else {
                      // Jika dinonaktifkan, batalkan notifikasi
                      _notificationService.cancelNotification(1); // Tidur
                      _notificationService.cancelNotification(2); // Bangun
                    }
                  });
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCardWithEdit(List<Map<String, String>> times, String frequency, bool isEnabled, ValueChanged<bool> onChanged, VoidCallback onEditPressed) {
    return Card(
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: AppColors.lightGrey,
          width: 1.0,
        ),
      ),
      child: SizedBox(
        height: 120,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 12.0, top: 18.0, bottom: 18.0),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: times.map((time) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        time['time']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        time['description']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      frequency,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: AppColors.primary),
                onPressed: onEditPressed,
              ),
              Transform.scale(
                scale: 0.9,
                child: CupertinoSwitch( // Mengganti Switch dengan CupertinoSwitch
                  value: isEnabled,
                  onChanged: onChanged,
                  activeColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}