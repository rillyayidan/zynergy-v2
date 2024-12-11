import 'package:flutter/material.dart';
import 'pengingat_makan.dart';
import 'pengingat_tidur.dart';
import 'pengingat_olahraga.dart';
import 'pengingat_cek_kesehatan.dart';
import '../core/config/theme/app_colors.dart'; // Import app_colors.dart
import '../core/config/strings/app_text.dart'; // Import app_text.dart

class PengingatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background dengan Radial Gradient
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
                          AppColors.primary.withOpacity(0.8), // Warna awal radial gradient
                          AppColors.primary, // Warna akhir radial gradient
                        ],
                        stops: [0.4, 1.0],
                        radius: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bagian bawah background putih dengan content card pengingat
          ListView(
            children: [
              Container(
                color: Colors.transparent,
                padding: EdgeInsets.only(top: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      PengingatText.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 26.0),

              // Elemen abu-abu di belakang background putih dengan border radius 24
              Stack(
                children: [
                  Container(
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

                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Container(
                      width: screenWidth,
                      padding: EdgeInsets.only(top: 24.0, bottom: 0.0, left: 20.0, right: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32.0),
                          topRight: Radius.circular(32.0),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Card Pengingat Makan
                          _buildCard(
                            context,
                            PengingatText.makanTitle,
                            'assets/images/makan.png',
                            PengingatText.makanDescription,
                            PengingatText.makanButton,
                                () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PengingatMakanScreen(),)
                              );
                            },
                          ),
                          SizedBox(height: 20),

                          // Card Pengingat Tidur
                          _buildCard(
                            context,
                            PengingatText.tidurTitle,
                            'assets/images/tidur.png',
                            PengingatText.tidurDescription,
                            PengingatText.tidurButton,
                                () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PengingatTidurScreen(),)
                              );
                            },
                          ),
                          SizedBox(height: 20),

                          // Card Pengingat Olahraga
                          _buildCard(
                            context,
                            PengingatText.olahragaTitle,
                            'assets/images/olahraga.png',
                            PengingatText.olahragaDescription,
                            PengingatText.olahragaButton,
                                () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PengingatOlahragaScreen(),)
                              );
                            },
                          ),
                          SizedBox(height: 20),

                          // Card Pengingat Cek Kesehatan
                          _buildCard(
                            context,
                            PengingatText.cekKesehatanTitle,
                            'assets/images/checkup.png',
                            PengingatText.cekKesehatanDescription,
                            PengingatText.cekKesehatanButton,
                                () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PengingatCekKesehatanScreen(),)
                              );
                            },
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, String imagePath, String description, String buttonText, VoidCallback onPressed) {
    return SizedBox(
      width: 353,
      height: 363,
      child: Card(
        elevation: 0.0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.lightGrey),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Transform.translate(
                offset: Offset(0, -8),
                child: Image.asset(
                  imagePath,
                  width: 329,
                  height: 160,
                ),
              ),
              SizedBox(height: 0),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                description,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 13,
                ),
              ),
              Spacer(), // Memberikan ruang di antara elemen-elemen
              SizedBox(
                width: 329,
                height: 34,
                child: ElevatedButton(
                  onPressed: onPressed,
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: (0.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}