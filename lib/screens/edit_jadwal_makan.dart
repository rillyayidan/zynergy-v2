import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/theme/app_colors.dart'; // Import app_colors.dart
import '../core/config/strings/app_text.dart'; // Import app_text.dart
import '../core/config/assets/app_vectors.dart'; // Import app_vectors.dart
import '../api/api_service.dart'; // Import ApiService
import '../api/notification_service.dart'; // Import NotificationService

class EditJadwalMakanScreen extends StatefulWidget {
  final Map<String, dynamic> mealSchedule;

  EditJadwalMakanScreen({required this.mealSchedule});

  @override
  _EditJadwalMakanScreenState createState() => _EditJadwalMakanScreenState();
}

class _EditJadwalMakanScreenState extends State<EditJadwalMakanScreen> {
  int _selectedHour = 0;
  int _selectedMinute = 0;
  String _selectedFrequency = 'Sekali';
  int _toggleValue = 1;
  TextEditingController _namaJadwalController = TextEditingController();

  List<int> _hours = List.generate(24, (index) => index);
  List<int> _minutes = List.generate(60, (index) => index);

  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _selectedHour = widget.mealSchedule['meal_hour'];
    _selectedMinute = widget.mealSchedule['meal_minute'];
    _selectedFrequency = widget.mealSchedule['meal_frequency'] == 1 ? 'Harian' : 'Sekali';
    _namaJadwalController.text = widget.mealSchedule['meal_name'];
  }

  void _showTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: Row(
            children: [
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedHour = _hours[index];
                    });
                  },
                  children: _hours.map((hour) {
                    return Center(
                      child: Text(
                        hour.toString().padLeft(2, '0'),
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Text(':', style: TextStyle(fontSize: 18)),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedMinute = _minutes[index];
                    });
                  },
                  children: _minutes.map((minute) {
                    return Center(
                      child: Text(
                        minute.toString().padLeft(2, '0'),
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
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

  Future<void> _saveEditedMealReminder() async {
    int frequencyValue = _selectedFrequency == 'Sekali' ? 0 : 1;
    int toggleValue = _toggleValue; // Tambahkan ini

    final editedMealReminder = {
      'meal_name': _namaJadwalController.text,
      'meal_hour': _selectedHour,
      'meal_minute': _selectedMinute,
      'meal_frequency': frequencyValue,
      'toggle_value': toggleValue, // Tambahkan ini
    };

    try {
      // Memperbarui jadwal makan yang sudah ada di database
      await _apiService.updateMealReminder(widget.mealSchedule['id'], editedMealReminder);

      // Batalkan notifikasi lama
      await _notificationService.cancelNotification(widget.mealSchedule['id']);

      // Jadwalkan ulang notifikasi baru jika toggle switch diaktifkan
      if (toggleValue == 1) {
        DateTime scheduledDate = DateTime.now().add(Duration(seconds: 1)); // Set the default time to 1 second later
        scheduledDate = scheduledDate.copyWith(hour: _selectedHour, minute: _selectedMinute, second: 0);

        // Cetak notification_id ke console
        print('Scheduling notification with id: ${widget.mealSchedule['id']}');

        await _notificationService.scheduleNotification(
          widget.mealSchedule['id'], // Gunakan id sebagai notification_id
          'Pengingat Makan',
          'Saatnya makan: ${_namaJadwalController.text}',
          scheduledDate,
          _selectedFrequency,
        );
      }

      Navigator.of(context).pop();
    } catch (e) {
      print("Error saving edited meal reminder: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving edited meal reminder: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteMealReminder() async {
    try {
      // Batalkan notifikasi
      await _notificationService.cancelNotification(widget.mealSchedule['id']);

      // Jika jadwal juga perlu dihapus dari database
      await _apiService.deleteMealReminder(widget.mealSchedule['id']);

      // Beri notifikasi kepada pengguna
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jadwal berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );

      // Kembali ke layar sebelumnya
      Navigator.of(context).pop();
    } catch (e) {
      print("Error deleting meal reminder: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting meal reminder: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
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
            'Lo yakin mau hapus jadwal ini?',
            style: TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Batal',
                style: TextStyle(
                  color: AppColors.darkGrey,
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
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMealReminder();
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.danger,
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

  void _showSaveConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Konfirmasi Edit',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Lo yakin mau nyimpen editan jadwal ini?',
            style: TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Batal',
                style: TextStyle(
                  color: AppColors.danger,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                side: BorderSide(
                  color: AppColors.danger,
                  width: 1.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                )
              ),
            ),
            TextButton(
              child: Text(
                'Simpan',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _saveEditedMealReminder();
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Sunting Jadwal Makan',
          style: TextStyle(
            color: Colors.black,
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
                        labelText: EditJadwalMakanText.namaJadwalLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: AppColors.lightGrey,
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
                            color: AppColors.lightGrey,
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
                onPressed: () => _showDeleteConfirmationDialog(context), // Fungsi untuk menampilkan dialog konfirmasi
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  'Hapus Jadwal', // Teks untuk tombol hapus
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () => _showSaveConfirmationDialog(context), // Fungsi untuk menampilkan dialog konfirmasi
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  ButtonPengingatText.simpan,
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