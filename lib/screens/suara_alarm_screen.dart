import 'package:flutter/material.dart';

class SuaraAlarmScreen extends StatefulWidget {
  const SuaraAlarmScreen({super.key});

  @override
  State<SuaraAlarmScreen> createState() => _SuaraAlarmScreenState();
}

class _SuaraAlarmScreenState extends State<SuaraAlarmScreen> {
  String selectedSound = 'Bunyi Bip (Default)';

  // List of available sounds
  final List<String> sounds = [
    'Bunyi Bip (Default)',
    'Dering',
    'Notifikasi',
    'Alarm',
    'Melody',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Suara Pengingat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pengaturan Suara Alarm',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedSound,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: sounds.map((String sound) {
                    return DropdownMenuItem<String>(
                      value: sound,
                      child: Text(
                        sound,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedSound = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
