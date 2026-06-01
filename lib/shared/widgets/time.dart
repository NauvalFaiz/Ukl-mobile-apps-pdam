import 'package:flutter/material.dart';

class GreetingWidget extends StatelessWidget {
  final String? userName; // Menerima parameter nama user (misal: profile.name)
  final TextStyle?
  style; // Menerima custom style jika ingin diubah warnanya/ukurannya

  const GreetingWidget({super.key, this.userName, this.style});

  // Fungsi internal menentukan ucapan berdasarkan waktu jam HP
  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 4 && hour < 11) {
      return 'Selamat Pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menggabungkan ucapan waktu dengan nama user menggunakan String Interpolation
    final String fullGreeting = userName != null
        ? '${_getGreeting()}, $userName'
        : _getGreeting();

    return Text(
      fullGreeting,
      style:
          style ??
          const TextStyle(
            fontSize: 11,
            fontFamily: 'CupertinoSystemText',
            height: 1.18,
            letterSpacing: 0.06,
            fontWeight: FontWeight(590),
            color: Color(0xFF818BA0),
          ),
    );
  }
}
