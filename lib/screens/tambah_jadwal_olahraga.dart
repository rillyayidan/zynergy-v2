import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';
import '../api/notification_service.dart';
import '../api/api_response.dart'; // Impor kelas ApiResponse
import '../core/config/strings/app_text.dart';
import '../core/config/assets/app_vectors.dart';
import '../core/config/theme/app_colors.dart'; // Impor app_colors.dart

class TambahJadwalOlahragaScreen extends StatefulWidget {
  @override
  _TambahJadwalOlahragaScreenState createState() => _TambahJadwalOlahragaScreenState();
}

class _TambahJadwalOlahragaScreenState extends State<TambahJadwalOlahragaScreen> {
  int _selectedHour = 0;
  int _selectedMinute = 0;
  String _selectedFrequency = 'Sekali';
  TextEditingController _namaJadwalController = TextEditingController();

  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    // Inisialisasi waktu saat ini
    final now = DateTime.now();
    _selectedHour = now.hour;
    _selectedMinute = now.minute;
  }

  void _showTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          child: CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.hm,
            initialTimerDuration: Duration(
              hours: _selectedHour,
              minutes: _selectedMinute,
            ),
            onTimerDurationChanged: (Duration newDuration) {
              setState(() {
                _selectedHour = newDuration.inHours;
                _selectedMinute = newDuration.inMinutes % 60;
              });
            },
          ),
        );
      },
    );
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

  Future<void> _saveLightActivityReminder() async {
    // Check if the activity name is empty
    if (_namaJadwalController.text.isEmpty) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Nama jadwal olahraga tidak boleh kosong.'),
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

    int frequencyValue = _selectedFrequency == 'Sekali' ? 0 : 1;

    final lightActivityReminder = {
      'activity_name': _namaJadwalController.text,
      'activity_hour': _selectedHour,
      'activity_minute': _selectedMinute,
      'activity_frequency': frequencyValue,
      'toggle_value': 1, // Set toggle_value to 1 by default
    };

    try {
      // Menyimpan pengingat ke database
      final ApiResponse response = await _apiService.saveLightActivityReminder(lightActivityReminder);

      if (response.success) {
        // Menentukan waktu notifikasi
        DateTime scheduledDate = DateTime.now().add(Duration(seconds: 1)); // Set the default time to 1 second later
        scheduledDate = scheduledDate.copyWith(hour: _selectedHour, minute: _selectedMinute, second: 0);

        // Menjadwalkan notifikasi berdasarkan frekuensi
        await NotificationService().scheduleNotification(
          response.data['id'], // Gunakan id sebagai notification_id
          'Pengingat Olahraga',
          'Saatnya olahraga: ${_namaJadwalController.text}',
          scheduledDate,
          _selectedFrequency,  // Meneruskan nilai frekuensi
        );

        // Save notification_id to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('notification_id_${response.data['id']}', response.data['id']); // Simpan id sebagai notification_id

        // Kirim data kembali ke pengingat_olahraga.dart
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving light activity reminder: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error saving light activity reminder: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving light activity reminder: $e'),
          backgroundColor: Colors.red,
        ),
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
          icon: Icon(Icons.arrow_back, color: AppColors.black), // Menggunakan AppColors.black
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Tambah Jadwal Olahraga',
          style: TextStyle(
            color: AppColors.black, // Menggunakan AppColors.black
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
                        labelText: TambahJadwalOlahragaText.namaJadwalLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: AppColors.lightGrey, // Menggunakan AppColors.lightGrey
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      PengingatDetailText.infoPilihWaktu,
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _showTimePicker(context),
                      child: Container(
                        width: 136,
                        height: 60,
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: AppColors.lightGrey, // Menggunakan AppColors.lightGrey
                            width: 1.0,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${_selectedHour.toString().padLeft(2, '0')}  :  ${_selectedMinute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Card(
                      color: Colors.white,
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: BorderSide(
                          color: AppColors.lightGrey, // Menggunakan AppColors.lightGrey
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
                                      color: AppColors.darkGrey, // Menggunakan AppColors.darkGrey
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
                onPressed: _saveLightActivityReminder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // Menggunakan AppColors.primary
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