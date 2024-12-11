import 'package:flutter/material.dart';
import 'verification_screen.dart';
import '../api/api_service.dart';
import '../core/config/theme/app_colors.dart';
import '../core/config/strings/app_text.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _apiService = ApiService();

  bool _obscureTextPassword = true;
  bool _obscureTextConfirmPassword = true;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final response = await _apiService.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        _confirmPasswordController.text,
      );

      if (response.success) {
        await _apiService.saveToken(response.data['token']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VerificationScreen()),
        );
      } else {
        _showErrorDialog(response.message);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pendaftaran Gagal'),
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            RegisterText.title,
                            style: TextStyle(
                              color: AppColors.darkGrey,
                              fontWeight: FontWeight.w600,
                              fontSize: 22,
                            ),
                          ),
                          SizedBox(height: 20),

                          // Form registrasi
                          // textField 'Nama'
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: RegisterText.nameLabel,
                              labelStyle: TextStyle(color: AppColors.darkGrey.withOpacity(0.6), fontSize: 18),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.primary),
                                borderRadius: BorderRadius.circular(8.0), // Atur border radius di sini
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.primary),
                                borderRadius: BorderRadius.circular(8.0), // Atur border radius di sini
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
                            style: TextStyle(color: AppColors.darkGrey), // Warna teks abu-abu
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ketik Nama Lengkap Anda!';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10),

                          // textField 'Email'
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: RegisterText.emailLabel,
                              labelStyle: TextStyle(color: AppColors.darkGrey.withOpacity(0.6), fontSize: 18),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.primary),
                                borderRadius: BorderRadius.circular(8.0), // Atur border radius di sini
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.primary),
                                borderRadius: BorderRadius.circular(8.0), // Atur border radius di sini
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
                            style: TextStyle(color: AppColors.darkGrey), // Warna teks abu-abu
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ketik Email Anda!';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10),

                          // textField 'Kata Sandi'
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: RegisterText.passwordLabel,
                              labelStyle: TextStyle(color: AppColors.darkGrey.withOpacity(0.6), fontSize: 18),
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
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureTextPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: AppColors.darkGrey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureTextPassword = !_obscureTextPassword;
                                  });
                                },
                              ),
                            ),
                            style: TextStyle(color: AppColors.darkGrey),
                            obscureText: _obscureTextPassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ketik Kata Sandi Anda!';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10),

                          // textField 'Konfirmasi Kata Sandi'
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: RegisterText.confirmPasswordLabel,
                              labelStyle: TextStyle(color: AppColors.darkGrey.withOpacity(0.6), fontSize: 18),
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
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureTextConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: AppColors.darkGrey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureTextConfirmPassword = !_obscureTextConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            style: TextStyle(color: AppColors.darkGrey),
                            obscureText: _obscureTextConfirmPassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ketik Kata Sandi Anda!';
                              }
                              if (value != _passwordController.text) {
                                return 'Periksa Kembali, Kata Sandi Tidak cocok!';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 30),

                          // Button 'Daftar'
                          ElevatedButton(
                            onPressed: _register,
                            child: Text(
                              RegisterText.registerButton,
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

                          // Button 'Sudah Punya Akun'
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoginScreen()),
                              );
                            },
                            child: Text(
                              'Aku Udah Punya Akun',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              minimumSize: Size(320, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(color: AppColors.primary),
                              )
                            )
                          ),
                        ],
                      ),
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