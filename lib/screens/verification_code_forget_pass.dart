import 'package:flutter/material.dart';
import 'new_password.dart';
import '../core/config/theme/app_colors.dart';
import '../core/config/strings/app_text.dart';
import '../api/api_service.dart'; // Pastikan path ini benar

class VerificationCodeForgetPassScreen extends StatefulWidget {
  final String email; // Tambahkan parameter email

  VerificationCodeForgetPassScreen({required this.email}); // Tambahkan parameter email ke konstruktor

  @override
  _VerificationCodeForgetPassScreenState createState() => _VerificationCodeForgetPassScreenState();
}

class _VerificationCodeForgetPassScreenState extends State<VerificationCodeForgetPassScreen> {
  final List<TextEditingController> _otpControllers = List.generate(5, (index) => TextEditingController());
  final ApiService _apiService = ApiService(); // Inisialisasi ApiService

  // Fungsi untuk menggabungkan nilai OTP dari semua controller
  String get otp => _otpControllers.map((controller) => controller.text).join();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                            LoginText.subtitle,
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
                          'Lupa Kata Sandi',
                          style: TextStyle(
                            color: AppColors.darkGrey,
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Masukkan Kode OTP dari Email Anda!',
                          style: TextStyle(
                            color: AppColors.darkGrey,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (index) {
                            return SizedBox(
                              width: 50,
                              height: 50,
                              child: TextFormField(
                                controller: _otpControllers[index],
                                keyboardType: TextInputType.number,
                                maxLength: 1,
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
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                style: TextStyle(color: AppColors.darkGrey),
                                onChanged: (value) {
                                  if (value.length == 1 && index < 4) {
                                    FocusScope.of(context).nextFocus();
                                  }
                                },
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Panggil fungsi untuk verifikasi OTP
                            _verifyOTP();
                          },
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
                            minimumSize: Size(350, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Tambahkan logika untuk mengirim ulang OTP di sini
                          },
                          child: Text(
                            'Kirim Ulang Kode OTP',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            minimumSize: Size(350, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
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

  // Fungsi untuk verifikasi OTP
  Future<void> _verifyOTP() async {
    final otp = this.otp; // Ambil OTP dari controller
    final email = widget.email; // Ambil email dari widget

    // Logika untuk memverifikasi OTP
    // Misalnya, arahkan ke layar NewPasswordScreen jika OTP valid
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewPasswordScreen(email: email, otp: otp)),
    );
  }
}