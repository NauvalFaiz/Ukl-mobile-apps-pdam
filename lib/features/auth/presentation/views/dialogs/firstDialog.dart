import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uklmobileapps/features/auth/presentation/views/dialogs/seconsDialog.dart';

class Firstdialog extends StatefulWidget {
  const Firstdialog({super.key});

  @override
  State<Firstdialog> createState() => _FirstdialogState();
}

class _FirstdialogState extends State<Firstdialog> {
  bool _isDialogOpen = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      title: Text(
        "Syarat & Ketentuan\n Penggunaan Aplikasi",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF242E49),
          fontFamily: 'CupertinoSystemText',
          fontWeight: FontWeight(590),
          fontSize: 20,
          height: 1.25,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _text("Selamat datang di aplikasi PDAM Mobile. "),
          SizedBox(height: 12),
          _text(
            "Dengan melanjutkan penggunaan aplikasi ini, Anda menyetujui bahwa seluruh data penggunaan air, pelaporan angka meteran mandiri, dan informasi transaksi digital Anda akan diproses secara aman oleh sistem internal PDAM sesuai dengan hukum perlindungan data yang berlaku.",
          ),
          SizedBox(height: 12),
          _text(
            "Aplikasi ini ditujukan untuk memberikan kemudahan bagi pelanggan umum dalam mengakses layanan administrasi secara transparan. Segala bentuk manipulasi data atau penggunaan fitur secara ilegal akan ditindak tegas sesuai hukum.",
          ),
          SizedBox(height: 12),
          _text(
            "Hak akses pengelolaan data pelanggan, konfigurasi tarif kubikasi air, dan validasi bukti transaksi keuangan hanya diberikan kepada staf yang memiliki otoritas resmi dari PDAM.",
          ),
          SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              if (ModalRoute.of(context)?.isCurrent == false) {
                return;
              }
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Seconsdialog(),
              );
            },
            child: Text(
              "Daftar sebagai Admin PDAM",
              style: TextStyle(
                fontFamily: 'CupertinoSystemText',
                fontSize: 12,
                color: Color(0xff0F67FE),
                decoration: TextDecoration.underline,
                height: 1.3,
                decorationColor: Color(0xff0F67FE),
                decorationThickness: 2,
              ),
            ),
          ),
          Text(
            "*akses hanya untuk admin resmi PDAM",
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'CupertinoSystemText',
              color: Color(0xffFA4D5E),
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            padding: EdgeInsets.only(top: 16, bottom: 16, left: 32, right: 32),
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFF0F67FE),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Text(
              "Tutup",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight(700),
                fontSize: 14,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _text(String label) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'CupertinoSystemText',
        fontSize: 12,
        height: 1.33,
        fontWeight: FontWeight(400),
        color: Color(0xFF3D4966),
      ),
    );
  }
}
