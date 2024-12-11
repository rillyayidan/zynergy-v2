import 'package:flutter/material.dart';
import 'package:zynergy/core/config/theme/app_colors.dart';

class UbahNamaScreen extends StatelessWidget {
  const UbahNamaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ubah Nama ',
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
                'Masukkan nama baru',
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
                    focusColor: AppColors.lightGrey,
                    labelText: 'Nama',
                    hintText: 'Masukkan nama anda',
                    border: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: AppColors.lightGrey),
                        borderRadius: BorderRadius.circular(8))),
              ),
              const SizedBox(
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
