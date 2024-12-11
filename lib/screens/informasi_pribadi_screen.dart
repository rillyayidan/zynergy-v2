import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zynergy/core/config/assets/app_vectors.dart';
import 'package:zynergy/core/config/theme/app_colors.dart';
import 'package:zynergy/screens/ubah_jenis_kelamin.dart';
import 'package:zynergy/screens/ubah_kata_sandi.dart';
import 'package:zynergy/screens/ubah_nama_screen.dart';
import '../api/api_service.dart';

class InformasiPribadiScreen extends StatefulWidget {
  @override
  _InformasiPribadiScreenState createState() => _InformasiPribadiScreenState();
}

class _InformasiPribadiScreenState extends State<InformasiPribadiScreen> {
  final ApiService _apiService =
      ApiService(); // Create an instance of ApiService
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final localUserData = await _apiService.getLocalUserData();
      if (localUserData != null) {
        setState(() {
          _userData = localUserData;
        });
      } else {
        final userData = await _apiService.getUserData();
        setState(() {
          _userData = userData;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Informasi"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informasi Pribadi Section
              const Text(
                "Informasi Pribadi",
                style: TextStyle(
                  fontSize: 16,
                  // fontFamily: 'Geist',
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lightGrey, width: 1)),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding:
                            const EdgeInsets.only(right: 16, left: 16, top: 16),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nama Lengkap',
                              style: TextStyle(
                                color: AppColors.darkGrey,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userData?['name'] ?? 'Loading...',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.darkGrey,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Ubah',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.darkGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.chevron_right,
                                color: AppColors.darkGrey),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UbahNamaScreen()));
                        },
                      ),
                      ListTile(
                        contentPadding:
                            const EdgeInsets.only(right: 16, left: 16, top: 16),
                        title: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jenis Kelamin',
                              style: TextStyle(
                                color: AppColors.darkGrey,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Perempuan',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.darkGrey,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Ubah',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.darkGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.chevron_right,
                                color: AppColors.darkGrey),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UbahJenisKelamin()));
                        },
                      ),
                      ListTile(
                        contentPadding:
                            const EdgeInsets.only(right: 16, left: 16, top: 16),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Email',
                              style: TextStyle(
                                color: AppColors.darkGrey,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userData?['email'] ?? 'Loading...',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.darkGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.only(
                            right: 16, left: 16, top: 16, bottom: 16),
                        title: const Text(
                          'Kata Sandi',
                          style: TextStyle(
                            color: AppColors.darkGrey,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        trailing: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Ubah',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.darkGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.chevron_right,
                                color: AppColors.darkGrey),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UbahKataSandi()));
                        },
                      ),
                    ],
                  )),
              const SizedBox(height: 24),

              // Informasi Kesehatan Section
              const Text(
                "Informasi Kesehatan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape
                            .circle, // Keeps the container itself circular
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary
                                .withOpacity(0.3), // Shadow color with opacity
                            blurRadius: 20, // Blur effect for soft edges
                            spreadRadius:
                                8, // Keeps the shadow from expanding too far
                            offset: Offset(
                                0, 3), // Positions the shadow below the icon
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        AppVectors.iconHeart,
                        width: 80,
                        height: 80,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.lightGrey)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keterangan Status',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          _buildHealthStatus(
                              AppVectors.iconHeart, "Sehat Sekali"),
                          const SizedBox(height: 8),
                          _buildHealthStatus(
                              AppVectors.iconHeartBlue, "Cukup Sehat"),
                          const SizedBox(height: 8),
                          _buildHealthStatus(
                              AppVectors.iconHeartYellow, "Kurang Sehat"),
                          const SizedBox(height: 8),
                          _buildHealthStatus(
                              AppVectors.iconHeartRed, "Tidak Sehat"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build a tile for dynamic data (e.g., fetched from API)
  Widget _buildDynamicInfoTile(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  // Build a tile for static information
  Widget _buildStaticInfoTile(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ],
    );
  }

  // Build the health status row
  Widget _buildHealthStatus(String color, String status) {
    return Row(
      children: [
        SvgPicture.asset(color),
        const SizedBox(width: 8),
        Text(
          status,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.darkGrey,
          ),
        ),
      ],
    );
  }
}
