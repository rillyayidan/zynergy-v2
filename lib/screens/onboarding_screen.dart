import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import '../core/config/assets/app_vectors.dart'; // Import app_vectors.dart
import '../core/config/theme/app_colors.dart'; // Import app_colors.dart
import '../core/config/strings/app_text.dart'; // Import app_text.dart

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': OnboardingText.title1, // Menggunakan konstanta dari app_text.dart
      'description': OnboardingText.description1, // Menggunakan konstanta dari app_text.dart
      'image': AppVectors.page1, // Menggunakan konstanta dari app_vectors.dart
    },
    {
      'title': OnboardingText.title2, // Menggunakan konstanta dari app_text.dart
      'description': OnboardingText.description2, // Menggunakan konstanta dari app_text.dart
      'image': AppVectors.page2, // Menggunakan konstanta dari app_vectors.dart
    },
    {
      'title': OnboardingText.title3, // Menggunakan konstanta dari app_text.dart
      'description': OnboardingText.description3, // Menggunakan konstanta dari app_text.dart
      'image': AppVectors.page3, // Menggunakan konstanta dari app_vectors.dart
    },
    {
      'title': OnboardingText.title4, // Menggunakan konstanta dari app_text.dart
      'description': OnboardingText.description4, // Menggunakan konstanta dari app_text.dart
      'image': AppVectors.page4, // Menggunakan konstanta dari app_vectors.dart
    },
  ];

  void _skipToLastPage() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: _currentPage == _pages.length - 1
            ? null
            : [
          TextButton(
            onPressed: _skipToLastPage,
            child: Text(
              'Lewati',
              style: TextStyle(color: AppColors.darkGrey, fontSize: 16), // Menggunakan konstanta dari app_colors.dart
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(
                      title: _pages[index]['title']!,
                      description: _pages[index]['description']!,
                      image: _pages[index]['image']!,
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 320,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, // Menggunakan konstanta dari app_colors.dart
                      foregroundColor: AppColors.secondary, // Menggunakan konstanta dari app_colors.dart
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      )),
                  onPressed: _currentPage == _pages.length - 1
                      ? () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isOnboardingComplete', true);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  }
                      : () {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Memulai' : 'Selanjutnya',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                    (index) => _buildDot(index: index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({required String title, required String description, required String image}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0, left: 20.0, right: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(padding: const EdgeInsets.only(bottom: 40.0),
            child: SvgPicture.asset(
              image,
              height: 275,
            ),
          ),
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.darkGrey)), // Menggunakan konstanta dari app_colors.dart
          SizedBox(height: 20),
          Text(description, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.darkGrey.withOpacity(0.7))), // Menggunakan konstanta dari app_colors.dart
        ],
      ),
    );
  }

  Widget _buildDot({required int index}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 6),
      height: 6,
      width: _currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : AppColors.darkGrey.withOpacity(0.2), // Menggunakan konstanta dari app_colors.dart
        borderRadius: BorderRadius.circular(9999),
      ),
    );
  }
}