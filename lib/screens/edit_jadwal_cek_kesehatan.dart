import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../core/config/strings/app_text.dart';
import '../core/config/theme/app_colors.dart';
import '../api/api_service.dart';
import '../api/notification_service.dart'; // Tambahkan ini

class EditJadwalCekKesehatanScreen extends StatefulWidget {
  final DateTime initialDate;
  final TimeOfDay initialTime;
  final String initialTitle;
  final String initialNote;
  final int reminderId; // Tambahkan ini untuk menyimpan ID reminder

  EditJadwalCekKesehatanScreen({
    required this.initialDate,
    required this.initialTime,
    required this.initialTitle,
    required this.initialNote,
    required this.reminderId, // Tambahkan ini
  });

  @override
  _EditJadwalCekKesehatanScreenState createState() => _EditJadwalCekKesehatanScreenState();
}

class _EditJadwalCekKesehatanScreenState extends State<EditJadwalCekKesehatanScreen> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService(); // Tambahkan ini

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedTime = widget.initialTime;
    _titleController = TextEditingController(text: widget.initialTitle);
    _noteController = TextEditingController(text: widget.initialNote);
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
          'Edit Jadwal Cek Kesehatan',
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
              child: Column(
                children: [
                  _buildTextFieldSection('Nama Jadwal', _titleController),
                  SizedBox(height: 20),
                  _buildDatePickerSection(),
                  SizedBox(height: 20),
                  _buildTimePickerSection(),
                  SizedBox(height: 20),
                  _buildTextFieldSection('Catatan', _noteController, maxLength: 30),
                ],
              ),
            ),
          ),
        ],
      ),
      persistentFooterButtons: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onPressed: () async {
              _showConfirmationDialog(context);
            },
            child: Text(
              ButtonPengingatText.simpan,
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

  Widget _buildTextFieldSection(String label, TextEditingController controller, {int? maxLength}) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: AppColors.lightGrey,
            width: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          PengingatDetailText.infoTanggal,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 10),
        Container(
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
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Pilih Waktu',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                '${_selectedTime.hour.toString().padLeft(2, '0')}  :  ${_selectedTime.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
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
              hours: _selectedTime.hour,
              minutes: _selectedTime.minute,
            ),
            onTimerDurationChanged: (Duration newDuration) {
              setState(() {
                _selectedTime = TimeOfDay(
                  hour: newDuration.inHours,
                  minute: newDuration.inMinutes % 60,
                );
              });
            },
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context) {
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
          actions: <Widget>[
            TextButton(
              child: Text(
                  'Batal',
                style: TextStyle(
                  color: AppColors.danger,
                ),
              ),
              style: TextButton.styleFrom(
                side: BorderSide(
                  color: AppColors.danger,
                  width: 1.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                  'Simpan',
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
              onPressed: () async {
                Navigator.of(context).pop();

                final updatedData = {
                  'checkup_name': _titleController.text,
                  'checkup_year': _selectedDate.year,
                  'checkup_month': _selectedDate.month,
                  'checkup_date': _selectedDate.day,
                  'checkup_hour': _selectedTime.hour,
                  'checkup_minute': _selectedTime.minute,
                  'checkup_note': _noteController.text,
                  'toggle_value': 1,
                };

                final response = await _apiService.updateHealthCheckupReminder(widget.reminderId, updatedData);

                if (response.success) {
                  final scheduledDateTime = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    _selectedTime.hour,
                    _selectedTime.minute,
                  );

                  if (scheduledDateTime.isBefore(DateTime.now())) {
                    _showPastScheduleWarningDialog(context);
                  } else {
                    await _notificationService.scheduleHealthCheckupNotification(
                      widget.reminderId,
                      _titleController.text,
                      _noteController.text,
                      scheduledDateTime,
                    );

                    _showSuccessDialog(context);
                  }
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

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
              'Berhasil',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
              'Perubahan berhasil disimpan.',
            style: TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                  'OK',
                style: TextStyle(
                  color: Colors.white
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
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

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(
                  'OK',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                )
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPastScheduleWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
              'Cek Lagi Dong!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
              'Jadwal yang lo atur udah lewat. Lo yakin masih mau nyimpen ini?',
            style: TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
          actions: <Widget>[
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
                  'Simpan',
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
                Navigator.of(context).pop();

                final scheduledDateTime = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  _selectedTime.hour,
                  _selectedTime.minute,
                );

                await _notificationService.scheduleHealthCheckupNotification(
                  widget.reminderId,
                  _titleController.text,
                  _noteController.text,
                  scheduledDateTime,
                );

                _showSuccessDialog(context);
              },
            ),
          ],
        );
      },
    );
  }
}