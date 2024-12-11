import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/config/strings/app_text.dart';
import '../core/config/theme/app_colors.dart';
import '../core/config/assets/app_vectors.dart';
import '../api/api_service.dart';
import '../api/notification_service.dart';

class TambahJadwalTidurScreen extends StatefulWidget {
  @override
  _TambahJadwalTidurScreenState createState() => _TambahJadwalTidurScreenState();
}

class _TambahJadwalTidurScreenState extends State<TambahJadwalTidurScreen> {
  int _selectedSleepHour = 0;
  int _selectedSleepMinute = 0;
  int _selectedWakeHour = 0;
  int _selectedWakeMinute = 0;
  String _selectedFrequency = 'Sekali';
  TextEditingController _namaJadwalController = TextEditingController();
  bool _isDurasiTidurTerbaikEnabled = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi waktu awal dengan waktu saat ini
    final now = DateTime.now();
    _selectedSleepHour = now.hour;
    _selectedSleepMinute = now.minute;
    _selectedWakeHour = now.hour;
    _selectedWakeMinute = now.minute;
  }

  void _showTimePicker(BuildContext context, bool isSleepTime) {
    // Ambil waktu saat ini
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          child: CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.hm,
            initialTimerDuration: Duration(
              hours: isSleepTime ? _selectedSleepHour : _selectedWakeHour,
              minutes: isSleepTime ? _selectedSleepMinute : _selectedWakeMinute,
            ),
            onTimerDurationChanged: (Duration newDuration) {
              setState(() {
                if (isSleepTime) {
                  _selectedSleepHour = newDuration.inHours;
                  _selectedSleepMinute = newDuration.inMinutes % 60;
                  _calculateWakeTime();
                } else {
                  _selectedWakeHour = newDuration.inHours;
                  _selectedWakeMinute = newDuration.inMinutes % 60;
                }
              });
            },
          ),
        );
      },
    );
  }

  void _calculateWakeTime() {
    if (_isDurasiTidurTerbaikEnabled) {
      DateTime sleepTime = DateTime(0, 0, 0, _selectedSleepHour, _selectedSleepMinute);
      DateTime wakeTime = sleepTime.add(Duration(hours: 8));
      setState(() {
        _selectedWakeHour = wakeTime.hour;
        _selectedWakeMinute = wakeTime.minute;
      });
    }
  }

  void _showFrequencyModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Pilih Frekuensi',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _selectedFrequency = 'Sekali';
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary, // Warna outline
                      width: 1.0, // Ketebalan outline
                    ),
                    borderRadius: BorderRadius.circular(8.0), // Border radius
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sekali',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.check,
                        color: _selectedFrequency == 'Sekali' ? AppColors.primary : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              InkWell(
                onTap: () {
                  setState(() {
                    _selectedFrequency = 'Harian';
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary, // Warna outline
                      width: 1.0, // Ketebalan outline
                    ),
                    borderRadius: BorderRadius.circular(8.0), // Border radius
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Harian',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.check,
                        color: _selectedFrequency == 'Harian' ? AppColors.primary : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Batal',
                style: TextStyle(
                  color: AppColors.danger,
                ),
              ),
              style: TextButton.styleFrom(
                side: BorderSide(
                  color: AppColors.danger,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveSleepReminder() async {
    // Check if the sleep schedule name is empty
    if (_namaJadwalController.text.isEmpty) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Nama jadwal tidur tidak boleh kosong.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return; // Exit the function early
    }

    try {
      final apiService = ApiService();
      final sleepFrequency = _selectedFrequency == 'Sekali' ? 0 : 1;

      // Hitung jam bangun jika "Durasi Tidur Terbaik" diaktifkan
      if (_isDurasiTidurTerbaikEnabled) {
        DateTime sleepTime = DateTime(0, 0, 0, _selectedSleepHour, _selectedSleepMinute);
        DateTime wakeTime = sleepTime.add(Duration(hours: 8));
        _selectedWakeHour = wakeTime.hour;
        _selectedWakeMinute = wakeTime.minute;
      }

      final response = await apiService.saveSleepReminder({
        'sleep_name': _namaJadwalController.text,
        'sleep_hour': _selectedSleepHour,
        'sleep_minute': _selectedSleepMinute,
        'wake_hour': _selectedWakeHour,
        'wake_minute': _selectedWakeMinute,
        'sleep_frequency': sleepFrequency,
        'toggle_value': 1,
      });

      if (response.success) {
        final int id = response.data['id']; // Ambil id dari respons API

        // Schedule notification after successfully saving sleep reminder
        final now = DateTime.now();
        final sleepHour = _selectedSleepHour;
        final sleepMinute = _selectedSleepMinute;
        final wakeHour = _selectedWakeHour;
        final wakeMinute = _selectedWakeMinute;
        final sleepFrequency = _selectedFrequency;

        DateTime sleepScheduledDate = DateTime(now.year, now.month, now.day, sleepHour, sleepMinute);
        DateTime wakeScheduledDate = DateTime(now.year, now.month, now.day, wakeHour, wakeMinute);

        if (sleepScheduledDate.isBefore(now)) {
          if (sleepFrequency == 'Sekali') {
            sleepScheduledDate = sleepScheduledDate.add(Duration(days: 1));
          }
        }

        if (wakeScheduledDate.isBefore(now)) {
          if (sleepFrequency == 'Sekali') {
            wakeScheduledDate = wakeScheduledDate.add(Duration(days: 1));
          }
        }

        final NotificationService notificationService = NotificationService();

        print('Scheduling sleep notification: id=$id, frequency=$sleepFrequency');
        notificationService.scheduleNotification(
          id, // Gunakan id sebagai notification_id
          'Pengingat Tidur',
          'Ingatlah untuk tidur sesuai jadwal!',
          sleepScheduledDate,
          sleepFrequency,
        );

        print('Scheduling wake notification: id=$id, frequency=$sleepFrequency');
        notificationService.scheduleNotificationWithCustomSound(
          id + 1, // Gunakan id + 1 sebagai notification_id untuk alarm bangun
          'Pengingat Bangun',
          'Ingatlah untuk bangun sesuai jadwal!',
          wakeScheduledDate,
          sleepFrequency,
        );

        Navigator.of(context).pop();
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan jadwal tidur')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Tambah Jadwal Tidur',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    TextField(
                      controller: _namaJadwalController,
                      decoration: InputDecoration(
                        labelText: TambahJadwalTidurText.namaJadwalLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: AppColors.lightGrey,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Jam Tidur',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 5),
                    GestureDetector(
                      onTap: () => _showTimePicker(context, true),
                      child: Container(
                        width: 136,
                        height: 60,
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: AppColors.lightGrey,
                            width: 1.0,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${_selectedSleepHour.toString().padLeft(2, '0')}  :  ${_selectedSleepMinute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      PengingatDetailText.infoPilihWaktu,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Jam Bangun',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 5),
                    GestureDetector(
                      onTap: _isDurasiTidurTerbaikEnabled ? null : () => _showTimePicker(context, false),
                      child: Container(
                        width: 136,
                        height: 60,
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: AppColors.lightGrey,
                            width: 1.0,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${_selectedWakeHour.toString().padLeft(2, '0')}  :  ${_selectedWakeMinute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      PengingatDetailText.infoPilihWaktu,
                    ),
                    SizedBox(height: 20),
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
                                AppVectors.iconTidur,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text(
                                'Durasi Tidur Terbaik',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(
                                Icons.info_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Text(
                                        'Mengaktifkan mode ini akan otomatis membuat alarm bangun 8 jam dari jadwal alarm tidur dan menonaktifkan alarm bangun yang telah diatur.',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'Tutup',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          style: TextButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            Transform.scale(
                              scale: 0.9,
                              child: CupertinoSwitch(
                                value: _isDurasiTidurTerbaikEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _isDurasiTidurTerbaikEnabled = value;
                                    if (value) {
                                      _calculateWakeTime();
                                    }
                                  });
                                },
                                activeColor: AppColors.lightGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      color: Colors.white,
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: BorderSide(
                          color: AppColors.lightGrey,
                          width: 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0, right: 0.0, top: 4.0, bottom: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 60,
                              child: ListTile(
                                leading: SvgPicture.asset(
                                  AppVectors.iconFreq,
                                  width: 24,
                                  height: 24,
                                ),
                                title: Text(
                                  CardSettingTambahEditJadwalText.frekuensi,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedFrequency,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.chevron_right,
                                      size: 18,
                                      color: AppColors.darkGrey,
                                    ),
                                  ],
                                ),
                                onTap: () => _showFrequencyModal(context),
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
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: _saveSleepReminder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  ButtonPengingatText.tambah,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}