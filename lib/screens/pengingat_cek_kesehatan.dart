import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Tambahkan ini
import 'package:shared_preferences/shared_preferences.dart'; // Tambahkan ini
import 'tambah_jadwal_cek_kesehatan.dart';
import 'edit_jadwal_cek_kesehatan.dart';
import '../core/config/assets/app_vectors.dart';
import '../core/config/strings/app_text.dart';
import '../core/config/theme/app_colors.dart';
import '../api/api_service.dart';
import '../api/notification_service.dart'; // Tambahkan ini

class PengingatCekKesehatanScreen extends StatefulWidget {
  @override
  _PengingatCekKesehatanScreenState createState() => _PengingatCekKesehatanScreenState();
}

class _PengingatCekKesehatanScreenState extends State<PengingatCekKesehatanScreen> {
  bool _isPengingatCekKesehatanEnabled = true;
  List<Map<String, dynamic>> _healthCheckupReminders = [];
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService(); // Tambahkan ini
  late SharedPreferences _prefs; // Tambahkan ini
  DateTime _selectedDate = DateTime.now(); // Tambahkan ini
  bool _hasSelectedDate = false; // Tambahkan ini
  Key _calendarKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id', null); // Inisialisasi locale ke bahasa Indonesia
    _initSharedPreferences(); // Tambahkan ini
    _fetchHealthCheckupReminders();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    bool? isEnabled = _prefs.getBool('isPengingatCekKesehatanEnabled');
    if (isEnabled != null) {
      setState(() {
        _isPengingatCekKesehatanEnabled = isEnabled;
      });
    }
  }

  Future<void> _fetchHealthCheckupReminders() async {
    try {
      final response = await _apiService.getHealthCheckupReminders();
      if (response.success) {
        setState(() {
          _healthCheckupReminders = List<Map<String, dynamic>>.from(response.data);
        });
        if (_isPengingatCekKesehatanEnabled) {
          _scheduleAllNotifications();
        } else {
          _cancelAllNotifications();
        }
      } else {
        _showErrorDialog(context, response.message);
      }
    } catch (e) {
      _showErrorDialog(context, 'Failed to fetch health checkup reminders');
    }
  }

  Future<void> _scheduleAllNotifications() async {
    final now = DateTime.now();
    for (var reminder in _healthCheckupReminders) {
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
  }

  Future<void> _cancelAllNotifications() async {
    for (var reminder in _healthCheckupReminders) {
      await _notificationService.cancelNotification(reminder['id']);
    }
  }

  void _clearFilter() {
    setState(() {
      _hasSelectedDate = false;
      _selectedDate = DateTime.now();
      _calendarKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Pengingat Cek Kesehatan',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(Icons.filter_alt_off_rounded, color: AppColors.black),
              onPressed: _clearFilter,
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  // Switch Pengingat Cek Kesehatan
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
                                setState(() {
                                  _isPengingatCekKesehatanEnabled = value;
                                });
                                await _prefs.setBool('isPengingatCekKesehatanEnabled', value);
                                if (value) {
                                  _scheduleAllNotifications();
                                } else {
                                  _cancelAllNotifications();
                                }
                              },
                              activeColor: AppColors.lightGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Kalender
                  Container(
                    key: _calendarKey,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightGrey, width: 1.0),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: CalendarDatePicker(
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2050),
                      onDateChanged: (date) {
                        setState(() {
                          _selectedDate = date;
                          _hasSelectedDate = true;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 20),

                  // Teks "Tidak ada jadwal"
                  if (_hasSelectedDate &&
                      _healthCheckupReminders.where((reminder) {
                        final reminderDate = DateTime(
                          reminder['checkup_year'],
                          reminder['checkup_month'],
                          reminder['checkup_date'],
                        );
                        return reminderDate.year == _selectedDate.year &&
                            reminderDate.month == _selectedDate.month &&
                            reminderDate.day == _selectedDate.day;
                      }).isEmpty)
                    Center(
                      child: Text(
                        'Tanggal ini, kamu tidak memiliki jadwal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Event Cards
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final filteredReminders = _hasSelectedDate
                    ? _healthCheckupReminders.where((reminder) {
                  final reminderDate = DateTime(
                    reminder['checkup_year'],
                    reminder['checkup_month'],
                    reminder['checkup_date'],
                  );
                  return reminderDate.year == _selectedDate.year &&
                      reminderDate.month == _selectedDate.month &&
                      reminderDate.day == _selectedDate.day;
                }).toList()
                    : _healthCheckupReminders;

                if (index >= filteredReminders.length) {
                  return null;
                }

                final reminder = filteredReminders[index];
                final date = DateTime(
                  reminder['checkup_year'],
                  reminder['checkup_month'],
                  reminder['checkup_date'],
                );
                final formattedDate = DateFormat('EEEE, d MMM y', 'id').format(date);
                final time = TimeOfDay(hour: reminder['checkup_hour'], minute: reminder['checkup_minute']);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      _buildEventCard(
                        formattedDate,
                        reminder['checkup_name'],
                            () {
                          _showInfoDialog(context, reminder, formattedDate, time);
                        },
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditJadwalCekKesehatanScreen(
                                initialDate: date,
                                initialTime: time,
                                initialTitle: reminder['checkup_name'],
                                initialNote: reminder['checkup_note'],
                                reminderId: reminder['id'],
                              ),
                            ),
                          );
                        },
                            () {
                          _showDeleteConfirmationDialog(context, reminder['id']);
                        },
                      ),
                      if (index == filteredReminders.length - 1) // Jika ini adalah card terakhir
                        SizedBox(height: 10),
                    ],
                  ),
                );
              },
              childCount: _hasSelectedDate
                  ? _healthCheckupReminders.where((reminder) {
                final reminderDate = DateTime(
                  reminder['checkup_year'],
                  reminder['checkup_month'],
                  reminder['checkup_date'],
                );
                return reminderDate.year == _selectedDate.year &&
                    reminderDate.month == _selectedDate.month &&
                    reminderDate.day == _selectedDate.day;
              }).length
                  : _healthCheckupReminders.length,
            ),
          ),
        ],
      ),
      persistentFooterButtons: [
        SizedBox(
          width: 320,
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TambahJadwalCekKesehatanScreen()),
              );
            },
            child: Text(
              ButtonPengingatText.tambah,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(String date, String title, VoidCallback onInfoPressed, VoidCallback onEditPressed, VoidCallback onDeletePressed) {
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
          padding: const EdgeInsets.only(left: 6.0, right: 4.0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.info_outline_rounded, color: AppColors.primary),
                onPressed: onInfoPressed,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: AppColors.primary,
                    ),
                    onPressed: onEditPressed,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.danger,
                    ),
                    onPressed: onDeletePressed,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Konfirmasi Hapus',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus jadwal ini?',
            style: TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Batal',
                style: TextStyle(
                  color: AppColors.primary,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                side: BorderSide(
                  color: AppColors.primary,
                  width: 1.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            TextButton(
              child: Text(
                  'Hapus',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.danger,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final response = await _apiService.deleteHealthCheckupReminder(id);
                if (response.success) {
                  // Batalkan notifikasi yang sudah dijadwalkan
                  await _notificationService.cancelNotification(id);

                  _fetchHealthCheckupReminders();
                  Navigator.of(context).pop();
                } else {
                  _showErrorDialog(context, response.message);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context, Map<String, dynamic> reminder, String formattedDate, TimeOfDay time) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            reminder['checkup_name'],
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hari: ${formattedDate.split(',')[0]}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Text(
                'Tanggal: ${formattedDate.split(',')[1].trim()}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Text(
                'Jam: ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Text(
                'Catatan: ${reminder['checkup_note']}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Tutup',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          actionsPadding: EdgeInsets.only(right: 8.0, bottom: 8.0),
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}