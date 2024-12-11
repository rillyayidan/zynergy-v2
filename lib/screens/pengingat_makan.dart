import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'tambah_jadwal_makan.dart';
import 'edit_jadwal_makan.dart';
import '../core/config/strings/app_text.dart';
import '../core/config/theme/app_colors.dart';
import '../core/config/assets/app_vectors.dart';
import '../api/api_service.dart';
import '../api/notification_service.dart';

class PengingatMakanScreen extends StatefulWidget {
  @override
  _PengingatMakanScreenState createState() => _PengingatMakanScreenState();
}

class _PengingatMakanScreenState extends State<PengingatMakanScreen> {
  bool _isPengingatMakanEnabled = true;
  bool _isSarapanEnabled = true;
  bool _isMakanSiangEnabled = true;
  bool _isMakanMalamEnabled = true;
  bool _isCamilanEnabled = true;

  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();
  List<Map<String, dynamic>> _specialSchedules = [];

  @override
  void initState() {
    super.initState();
    _fetchSpecialSchedules();
    _loadToggleValues();
  }

  Future<void> _fetchSpecialSchedules() async {
    try {
      final schedules = await _apiService.getSpecialSchedules();

      setState(() {
        _specialSchedules = schedules;
      });
    } catch (e) {
      print("Error fetching special schedules: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching special schedules: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateToggleValue(int id, int toggleValue, Map<String, dynamic> schedule) async {
    try {
      await _apiService.updateToggleValue(id, toggleValue);

      if (toggleValue == 0) {
        // Batalkan notifikasi jika toggle switch dinonaktifkan
        await _notificationService.cancelNotification(id);
      } else {
        // Jadwalkan ulang notifikasi jika toggle switch diaktifkan kembali
        DateTime scheduledDate = DateTime.now().add(Duration(seconds: 1)); // Set the default time to 1 second later
        scheduledDate = scheduledDate.copyWith(hour: schedule['meal_hour'], minute: schedule['meal_minute'], second: 0);

        await _notificationService.scheduleNotification(
          id, // Gunakan id sebagai notification_id
          'Pengingat Makan',
          'Saatnya makan: ${schedule['meal_name']}',
          scheduledDate,
          schedule['meal_frequency'] == 1 ? 'Harian' : 'Sekali',
        );
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

  Future<void> _loadToggleValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPengingatMakanEnabled = prefs.getBool('isPengingatMakanEnabled') ?? true;
      _isSarapanEnabled = prefs.getBool('isSarapanEnabled') ?? true;
      _isMakanSiangEnabled = prefs.getBool('isMakanSiangEnabled') ?? true;
      _isMakanMalamEnabled = prefs.getBool('isMakanMalamEnabled') ?? true;
      _isCamilanEnabled = prefs.getBool('isCamilanEnabled') ?? true;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Pengingat Makan',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 16),
              sliver: SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isPengingatMakanEnabled = !_isPengingatMakanEnabled;
                      _saveToggleValue('isPengingatMakanEnabled', _isPengingatMakanEnabled);
                    });

                    if (_isPengingatMakanEnabled) {
                      // Aktifkan semua jadwal yang enabled
                      _enableAllMealSchedules();
                    } else {
                      // Nonaktifkan semua notifikasi
                      _disableAllMealNotifications();
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
                                  // Aktifkan semua jadwal yang enabled
                                  _enableAllMealSchedules();
                                } else {
                                  // Nonaktifkan semua notifikasi
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
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: Text(
                      PengingatDetailText.jadwalBawaan,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // 4 Card dengan backgroundColor white, Outline #1FC29D dan height: 70
                  _buildScheduleCard(
                    'Sarapan',
                    '07:00',
                    'Harian',
                    _isSarapanEnabled,
                        (value) {
                      setState(() {
                        _isSarapanEnabled = value;
                        _saveToggleValue('isSarapanEnabled', value); // Menyimpan status toggle

                        if (value) {
                          // Jika diaktifkan, jadwalkan notifikasi
                          final scheduledDate = DateTime(0, 0, 0, 7, 0); // Waktu yang dijadwalkan
                          _notificationService.rescheduleNotificationIfNeeded(
                            1, // ID notifikasi
                            'Notifikasi Sarapan',
                            'Ingatlah untuk sarapan pagi!',
                            scheduledDate,
                          );
                        } else {
                          // Jika dinonaktifkan, batalkan notifikasi
                          _notificationService.cancelNotification(1);
                        }
                      });
                    },
                  ),
                  SizedBox(height: 4),
                  _buildScheduleCard(
                    'Makan Siang',
                    '12:00',
                    'Harian',
                    _isMakanSiangEnabled,
                        (value) {
                      setState(() {
                        _isMakanSiangEnabled = value;
                        _saveToggleValue('isMakanSiangEnabled', value); // Menyimpan status toggle

                        if (value) {
                          // Jika diaktifkan, jadwalkan notifikasi
                          final scheduledDate = DateTime(0, 0, 0, 12, 0); // Waktu yang dijadwalkan
                          _notificationService.rescheduleNotificationIfNeeded(
                            2, // ID notifikasi
                            'Notifikasi Makan Siang',
                            'Ingatlah untuk Makan Siang!',
                            scheduledDate,
                          );
                        } else {
                          // Jika dinonaktifkan, batalkan notifikasi
                          _notificationService.cancelNotification(2);
                        }
                      });
                    },
                  ),
                  SizedBox(height: 4),
                  _buildScheduleCard(
                    'Makan Malam',
                    '18:00',
                    'Harian',
                    _isMakanMalamEnabled,
                        (value) {
                      setState(() {
                        _isMakanMalamEnabled = value;
                        _saveToggleValue('isMakanMalamEnabled', value); // Menyimpan status toggle

                        if (value) {
                          // Jika diaktifkan, jadwalkan notifikasi
                          final scheduledDate = DateTime(0, 0, 0, 18, 0); // Waktu yang dijadwalkan
                          _notificationService.rescheduleNotificationIfNeeded(
                            3, // ID notifikasi
                            'Notifikasi Makan Malam',
                            'Ingatlah untuk Makan Malam!',
                            scheduledDate,
                          );
                        } else {
                          // Jika dinonaktifkan, batalkan notifikasi
                          _notificationService.cancelNotification(3);
                        }
                      });
                    },
                  ),
                  SizedBox(height: 4),
                  _buildScheduleCard(
                    'Camilan',
                    '15:00',
                    'Harian',
                    _isCamilanEnabled,
                        (value) {
                      setState(() {
                        _isCamilanEnabled = value;
                        _saveToggleValue('isCamilanEnabled', value); // Menyimpan status toggle

                        if (value) {
                          // Jika diaktifkan, jadwalkan notifikasi
                          final scheduledDate = DateTime(0, 0, 0, 15, 0); // Waktu yang dijadwalkan
                          _notificationService.rescheduleNotificationIfNeeded(
                            4, // ID notifikasi
                            'Notifikasi Makan Malam',
                            'Ingatlah untuk Makan Malam!',
                            scheduledDate,
                          );
                        } else {
                          // Jika dinonaktifkan, batalkan notifikasi
                          _notificationService.cancelNotification(4);
                        }
                      });
                    },
                  ),
                  const SizedBox(height:20,)
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: SliverMainAxisGroup(slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 8.0),
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
                SliverList.builder(
                  itemCount: _specialSchedules.length,
                  itemBuilder: (context, index) {
                    final schedule = _specialSchedules[index];
                    return _buildScheduleCardWithEdit(
                      schedule['meal_name'],
                      '${schedule['meal_hour']}:${schedule['meal_minute']}',
                      schedule['meal_frequency'] == 1 ? 'Harian' : 'Sekali',
                      schedule['toggle_value'] == 1, // Tambahkan ini
                          (value) {
                        setState(() {
                          schedule['toggle_value'] = value ? 1 : 0;
                          _updateToggleValue(schedule['id'], schedule['toggle_value'], schedule);
                        });
                      },
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditJadwalMakanScreen(mealSchedule: schedule)),
                        );
                      },
                      schedule['id'],
                      schedule,
                    );
                  },
                )
              ]),
            )
          ],
        ),
      ),
      persistentFooterButtons: [
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TambahJadwalMakanScreen()),
              ).then((_) {
                _fetchSpecialSchedules(); // Refresh data after adding new schedule
              });
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
                        ButtonPengingatText.tambahJadwalMakanButtonText,
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
              CupertinoSwitch( // Mengganti Switch dengan CupertinoSwitch
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

  Widget _buildScheduleCardWithEdit(String title, String time, String frequency, bool isEnabled, ValueChanged<bool> onChanged, VoidCallback onEditPressed, int id, Map<String, dynamic> schedule) {
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
                onPressed: () {
                  // Tambahkan log di sini
                  log('Opening edit screen for schedule id: $id, notification_id: ${schedule['notification_id']}');
                  onEditPressed();
                },
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