import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zynergy/core/config/assets/app_vectors.dart';
import 'package:zynergy/core/config/theme/app_colors.dart';
import 'package:zynergy/screens/components/custom_modal.dart';
import 'package:zynergy/screens/pemberitahuan_screen.dart';

class PengaturanScreen extends StatefulWidget {
  @override
  _PengaturanScreenState createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  bool pengingat = true;
  bool suaraPengingat = true;
  bool modeHening = false;
  bool modeAkhirPekan = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Back button functionality
          },
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top switch
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,

                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8), // Teal gradient start
                    AppColors.primary, // Teal-blue gradient end
                  ],
                  // stops: [0.8, 0.1, 1],
                ),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppVectors.iconStopWatchBold,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Pengingat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                    child: Switch(
                      value: pengingat,
                      activeTrackColor: AppColors.secondary,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          pengingat = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Section title
            const Text(
              'Pengaturan Pengingat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            // Reminder settings card
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  // Suara Pengingat
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(AppVectors.iconSoundWave),
                            const SizedBox(width: 12),
                            const Text(
                              'Suara Pengingat',
                              style: TextStyle(
                                  color: AppColors.darkGrey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Switch(
                          value: modeHening,
                          activeColor: AppColors.secondary,
                          activeTrackColor: AppColors.primary,
                          onChanged: (value) {
                            setState(() {
                              modeHening = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  // Suara
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    title: Row(
                      children: [
                        SvgPicture.asset(AppVectors.iconMusicNote),
                        SizedBox(
                          width: 12,
                        ),
                        const Text(
                          'Suara',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.darkGrey),
                        ),
                      ],
                    ),
                    trailing: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('On',
                            style: TextStyle(
                              color: AppColors.darkGrey,
                              fontSize: 14,
                            )),
                        SizedBox(
                          width: 8,
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: 16, color: AppColors.darkGrey),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PemberitahuanScreen()));
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  // Mode Hening
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(AppVectors.iconMuted),
                            const SizedBox(width: 12),
                            const Text(
                              'Mode Hening',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkGrey),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                CustomModal.show(context,
                                    message:
                                        'Mengaktifkan mode ini akan menonaktifkan suara notifikasi.');
                              },
                              child: Icon(
                                Icons.info_outline,
                                size: 20,
                                color: AppColors.darkGrey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: modeHening,
                              activeColor: AppColors.secondary,
                              activeTrackColor: AppColors.primary,
                              onChanged: (value) {
                                setState(() {
                                  modeHening = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  // Mode Akhir Pekan
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(AppVectors.iconCoffee),
                            const SizedBox(width: 12),
                            const Text('Mode Akhir Pekan',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.darkGrey,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                CustomModal.show(context,
                                    message:
                                        'Mengaktifkan mode ini akan menonaktifkan pemberitahuan di hari libur (Weekend).');
                              },
                              child: const Icon(Icons.info_outline,
                                  size: 20, color: AppColors.darkGrey),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: modeAkhirPekan,
                              activeColor: AppColors.secondary,
                              activeTrackColor: AppColors.primary,
                              onChanged: (value) {
                                setState(() {
                                  modeAkhirPekan = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
