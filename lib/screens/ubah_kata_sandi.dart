import 'package:flutter/material.dart';
import 'package:zynergy/core/config/theme/app_colors.dart';

class UbahKataSandi extends StatelessWidget {
  const UbahKataSandi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ubah Kata Sandi',
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: AppColors.black),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buat Kata Sandi Baru',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: AppColors.black),
              ),
              const SizedBox(
                height: 12,
              ),
              TextField(
                decoration: InputDecoration(
                    suffixIcon: Icon(Icons.remove_red_eye_outlined),
                    focusColor: AppColors.lightGrey,
                    labelText: 'Kata Sandi Baru',
                    border: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: AppColors.lightGrey),
                        borderRadius: BorderRadius.circular(8))),
              ),
              const SizedBox(
                height: 24,
              ),
              TextField(
                decoration: InputDecoration(
                    suffixIcon: Icon(Icons.remove_red_eye_outlined),
                    focusColor: AppColors.lightGrey,
                    labelText: 'Konfirmasi Kata Sandi Baru',
                    border: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: AppColors.lightGrey),
                        borderRadius: BorderRadius.circular(8))),
              ),
              SizedBox(
                height: 24,
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => {},
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
