import 'package:flutter/material.dart';
import '../core/config/theme/app_colors.dart';
import '../core/config/strings/app_text.dart';
import '../api/api_service.dart'; // Import ApiService
import 'beranda_screen.dart'; // Import BerandaScreen
import 'personalization_screen.dart'; // Import PersonalizationScreen

class VerificationScreen extends StatefulWidget {
  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(5, (_) => TextEditingController());
  final _apiService = ApiService();

  Future<void> _verifyOTP() async {
    String otp = _otpControllers.map((controller) => controller.text).join('');
    print('OTP: $otp'); // Tambahkan log untuk memastikan OTP yang dikirimkan benar

    final response = await _apiService.verifyEmail(otp);

    if (response.success) {
      // Memeriksa apakah pengguna sudah mengisi data personalisasi
      bool hasPersonalizationData = await _apiService.hasPersonalizationData();

      if (hasPersonalizationData) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BerandaScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PersonalizationScreen()),
        );
      }
    } else {
      _showErrorDialog(response.message);
    }
  }

  Future<void> _resendOTP() async {
    final response = await _apiService.resendOTP();

    if (response.success) {
      _showSuccessDialog('Kode OTP berhasil dikirim ulang!');
    } else {
      _showErrorDialog(response.message);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Verifikasi Gagal'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sukses'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent sheet from resizing with keyboard
      body: SafeArea(
        child: Stack(
          children: [
            // Background dan logo yang tidak bergeser
            Container(
              width: screenWidth,
              height: screenHeight,
              decoration: BoxDecoration(
                color: AppColors.primary,
              ),
              child: Stack(
                children: [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 50),
                          Image.asset(
                            'assets/images/Logo 1.png',
                            width: 250,
                          ),
                          SizedBox(height: 20),
                          Text(
                            RegisterText.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Elemen abu-abu di belakang elemen putih
            AnimatedPositioned(
              duration: Duration(milliseconds: 900),
              curve: Curves.easeInOutCubic,
              top: keyboardHeight > 0 ? 50 : 190,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.0),
                width: screenWidth,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[300], // Warna abu-abu
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32.0),
                    topRight: Radius.circular(32.0),
                  ),
                ),
              ),
            ),

            // Bagian bawah yang bisa discroll
            AnimatedPositioned(
              duration: Duration(milliseconds: 900),
              curve: Curves.easeInOutCubic,
              top: keyboardHeight > 0 ? 50 : 210,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: screenWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Container(
                    width: screenWidth,
                    padding: EdgeInsets.only(top: 32.0, bottom: 0.0, left: 20.0, right: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Verikasi Akun Anda',
                          style: TextStyle(
                            color: AppColors.darkGrey,
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(height: 30),
                        Text(
                          'Masukkan Kode OTP dari Email Anda!',
                          style: TextStyle(
                            color: AppColors.darkGrey,
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 20),

                        // OTP Input Fields
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (index) {
                            return SizedBox(
                              width: 50,
                              height: 50,
                              child: TextField(
                                controller: _otpControllers[index],
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  counterText: '',
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.primary),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.primary),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.length == 1 && index < 4) {
                                    FocusScope.of(context).nextFocus();
                                  }
                                },
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 40),

                        // Button 'Verifikasi'
                        ElevatedButton(
                          onPressed: _verifyOTP,
                          child: Text(
                            'Verifikasi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: Size(320, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),

                        // Button 'Kirim Ulang Kode OTP'
                        ElevatedButton(
                          onPressed: _resendOTP,
                          child: Text(
                            'Kirim Ulang Kode OTP',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            minimumSize: Size(320, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
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