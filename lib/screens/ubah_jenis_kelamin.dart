import 'package:flutter/material.dart';
import 'package:zynergy/core/config/theme/app_colors.dart';

class UbahJenisKelamin extends StatefulWidget {
  const UbahJenisKelamin({Key? key}) : super(key: key);

  @override
  _UbahJenisKelaminState createState() => _UbahJenisKelaminState();
}

enum JenisKelamin { laki_laki, perempuan }

class _UbahJenisKelaminState extends State<UbahJenisKelamin> {
  JenisKelamin? _jenisKelamin = JenisKelamin.laki_laki;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Ubah Jenis Kelamin'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Jenis Kelamin',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: Radio(
                      activeColor: AppColors.primary,
                      value: JenisKelamin.laki_laki,
                      groupValue: _jenisKelamin,
                      onChanged: (JenisKelamin? value) {
                        setState(() {
                          _jenisKelamin = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Laki-Laki',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: Radio(
                      activeColor: AppColors.primary,
                      value: JenisKelamin.perempuan,
                      groupValue: _jenisKelamin,
                      onChanged: (JenisKelamin? value) {
                        setState(() {
                          _jenisKelamin = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  const Text(
                    'Perempuan',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(
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
        ));
  }
}
