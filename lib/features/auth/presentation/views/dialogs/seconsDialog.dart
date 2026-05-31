import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uklmobileapps/features/auth/presentation/views/admin_registration_page.dart';

class Seconsdialog extends StatelessWidget {
  const Seconsdialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      title: SvgPicture.asset('assets/warning.svg', height: 73, width: 79),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Akses Terbatas! \n [ ONLY FOR ADMIN ]",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight(590),
              color: Color(0xFF242E49),
              fontFamily: 'CupertinoSystemText',
              height: 1.25,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Halaman ini hanya diperuntukkan bagi staf\n administrator IT PDAM resmi. Tindakan ilegal \nakan dicatat oleh sistem.",
            style: TextStyle(
              fontSize: 12,
              height: 1.33,
              color: Color(0xFF242E49),
              fontFamily: 'CupertinoSystemText',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            height: 48,
            width: 327,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Color(0xFF0F67FE),
            ),
            child: Text(
              "Kembali",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight(700),
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminRegistrationPage(),
              ),
            );
          },
          child: Container(
            height: 48,
            width: 327,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Color(0xFFFEDA0F),
            ),
            child: Text(
              "Lanjutkan (admin)",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight(700),
                fontSize: 14,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
         
      ],
    );
  }
}
