import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tambah_jadwal_olahraga.dart';
import 'edit_jadwal_olahraga.dart';
import '../core/config/strings/app_text.dart';
import '../core/config/theme/app_colors.dart'; // Impor app_colors.dart
import '../core/config/assets/app_vectors.dart';
import '../api/api_service.dart'; // Impor ApiService
import '../api/notification_service.dart'; // Impor NotificationService

class PengingatOlahragaScreen extends StatefulWidget {
  @override
  _PengingatOlahragaScreenState createState() => _PengingatOlahragaScreenState();
}

class _PengingatOlahragaScreenState extends State<PengingatOlahragaScreen> {
  bool _isPengingatOlahragaEnabled = true;
  bool _isJoggingEnabled = true;
  bool _isPereganganEnabled = true;
  bool _isGymEnabled = true;
  List<dynamic> _lightActivityReminders = [];
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();

  // Tambahkan ID notifikasi untuk setiap jadwal bawaan
  final Map<String, int> _notificationIds = {
    'Jogging': 200,
    'Peregangan': 201,
    'Gym': 202,
  };

  @override
  void initState() {
    super.initState();
    _loadToggleValues();
    fetchLightActivityReminders();
  }

  Future<void> _loadToggleValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPengingatOlahragaEnabled = prefs.getBool('isPengingatOlahragaEnabled') ?? true;
      _isJoggingEnabled = prefs.getBool('isJoggingEnabled') ?? true;
      _isPereganganEnabled = prefs.getBool('isPereganganEnabled') ?? true;
      _isGymEnabled = prefs.getBool('isGymEnabled') ?? true;
    });
  }

  Future<void> _saveToggleValue(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> fetchLightActivityReminders() async {
    try {
      final reminders = await _apiService.fetchLightActivityReminders();
      setState(() {
        _lightActivityReminders = reminders;
      });
    } catch (e) {
      print("Error fetching light activity reminders: $e");
    }
  }

  Future<void> updateToggleValueLightActivityReminder(int id, int toggleValue) async {
    try {
      await _apiService.updateToggleValueLightActivityReminder(id, toggleValue);
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

  void _cancelAllNotifications() {
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

  void _rescheduleAllNotifications() {
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
          'Pengingat Olahraga',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
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
                        width: 24,
                        height: 24,
                        child: SvgPicture.asset(
                          AppVectors.iconOlahraga,
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
                            });
                            prefs.setBool('isPengingatOlahragaEnabled', value);
                            if (!value) {
                              _cancelAllNotifications();
                            } else {
                              _rescheduleAllNotifications();
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
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),

                  // Teks "Jadwal Bawaan"
                  Text(
                    PengingatDetailText.jadwalBawaan,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10),

                  // 4 Card dengan backgroundColor white, Outline #1FC29D dan height: 70
                  _buildScheduleCard('Jogging', '05:00', 'Harian', _isJoggingEnabled, (value) {
                    setState(() {
                      _isJoggingEnabled = value;
                      _saveToggleValue('isJoggingEnabled', value);
                      _toggleNotification('Jogging', value, DateTime.now().add(Duration(hours: 5)), 'Harian', 'Jogging', 'Ingatlah untuk jogging pagi!');
                    });
                  }),
                  SizedBox(height: 4),
                  _buildScheduleCard('Peregangan', '11:00', 'Harian', _isPereganganEnabled, (value) {
                    setState(() {
                      _isPereganganEnabled = value;
                      _saveToggleValue('isPereganganEnabled', value);
                      _toggleNotification('Peregangan', value, DateTime.now().add(Duration(hours: 11)), 'Harian', 'Peregangan', 'Ingatlah untuk peregangan siang!');
                    });
                  }),
                  SizedBox(height: 4),
                  _buildScheduleCard('Gym', '19:00', 'Sekali', _isGymEnabled, (value) {
                    setState(() {
                      _isGymEnabled = value;
                      _saveToggleValue('isGymEnabled', value);
                      _toggleNotification('Gym', value, DateTime.now().add(Duration(hours: 19)), 'Sekali', 'Gym', 'Ingatlah untuk gym sore!');
                    });
                  }),
                  SizedBox(height: 20),

                  // Teks "Jadwal Khusus"
                  Text(
                    PengingatDetailText.jadwalKhusus,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 10.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final reminder = _lightActivityReminders[index];
                  final scheduledDate = DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                    reminder['activity_hour'],
                    reminder['activity_minute'],
                  );
                  return _buildScheduleCardWithEdit(
                    reminder['activity_name'],
                    '${reminder['activity_hour'].toString().padLeft(2, '0')}:${reminder['activity_minute'].toString().padLeft(2, '0')}',
                    reminder['activity_frequency'] == 1 ? 'Harian' : 'Sekali',
                    reminder['toggle_value'] == 1,
                        (value) {
                      setState(() {
                        reminder['toggle_value'] = value ? 1 : 0;
                        updateToggleValueLightActivityReminder(reminder['id'], reminder['toggle_value']);
                        _toggleNotification(reminder['activity_name'], value, scheduledDate, reminder['activity_frequency'] == 1 ? 'Harian' : 'Sekali', reminder['activity_name'], 'Ingatlah untuk ${reminder['activity_name'].toLowerCase()}!');
                      });
                    },
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditJadwalOlahragaScreen(initialData: reminder),
                        ),
                      ).then((result) {
                        if (result == true) {
                          fetchLightActivityReminders();
                        }
                      });
                    },
                  );
                },
                childCount: _lightActivityReminders.length,
              ),
            ),
          ),
        ],
      ),
      persistentFooterButtons: [
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TambahJadwalOlahragaScreen()),
              );
            },
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

  Widget _buildScheduleCard(String title, String time, String frequency, bool isEnabled, ValueChanged<bool> onChanged) {
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
        height: 70,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 12.0),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    frequency,
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
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
                onChanged: onChanged,
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCardWithEdit(String title, String time, String frequency, bool isEnabled, ValueChanged<bool> onChanged, VoidCallback onEditPressed) {
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
        height: 70,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 12.0),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    frequency,
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
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
                child: CupertinoSwitch(
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