import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BillStatusBanner extends StatelessWidget {
  final int unpaidCount;
  final List<dynamic> unpaidBills;
  final Function(int) getMonthName;

  const BillStatusBanner({
    super.key,
    required this.unpaidCount,
    required this.unpaidBills,
    required this.getMonthName,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);

    // DESAIN 1: LUNAS (0 TAGIHAN)
    if (unpaidCount == 0) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xffE2FCD6),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(19.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset("assets/done.svg"),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tagihan Anda Bulan Ini Lunas",
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.33,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'CupertinoSystemText',
                        color: Color(0xFF242E49),
                      ),
                    ),
                    Text(
                      "Terima kasih telah melakukan pembayaran tepat waktu.",
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.33,
                        fontFamily: 'CupertinoSystemText',
                        color: Color(0xFF3D4966),
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

    // DESAIN 2: TUNGGAKAN 1 BULAN
    if (unpaidCount == 1) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xffD2E4FF),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(19.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset("assets/blue.svg"),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Segera lunasi tagihan anda",
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.33,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'CupertinoSystemText',
                            color: Color(0xFF242E49),
                          ),
                        ),
                        Text(
                          "Selesaikan pembayaran sebelum batas waktu agar layanan tetap lancar.",
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.33,
                            fontFamily: 'CupertinoSystemText',
                            color: Color(0xFF3D4966),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF242E49),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  onPressed: () => Navigator.pushReplacementNamed(context, '/customer/bills'),
                  child: const Text('Lihat Detail', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // DESAIN 3: KONDISI 2 SAMPAI 5 TAGIHAN
    if (unpaidCount <= 5) {
      final sortedUnpaidBills = List.from(unpaidBills)
        ..sort((a, b) {
          int yearCompare = b.year.compareTo(a.year);
          if (yearCompare != 0) return yearCompare;
          return b.month.compareTo(a.month);
        });

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xffFFD7DD),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(19.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset("assets/logo_bils.svg"),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Segera lunasi tagihan anda",
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.33,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'CupertinoSystemText',
                            color: Color(0xFF242E49),
                          ),
                        ),
                        Text(
                          "Anda memiliki $unpaidCount tagihan yang belum dibayar",
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.33,
                            fontFamily: 'CupertinoSystemText',
                            color: Color(0xFF3D4966),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ...sortedUnpaidBills.map((bill) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${getMonthName(bill.month)} ${bill.year}',
                              style: const TextStyle(color: Color(0xFF4A5568), fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              formatCurrency.format(bill.price),
                              style: const TextStyle(color: Color(0xFF2D3748), fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(color: Color(0xEFEFEFEF), thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          formatCurrency.format(sortedUnpaidBills.fold<num>(0, (sum, b) => sum + b.price)),
                          style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFA4A5B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  onPressed: () => Navigator.pushReplacementNamed(context, '/customer/bills'),
                  child: const Text('Bayar Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // DESAIN 4: LEBIH DARI 5 TUNGGAKAN
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9D2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(19.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset("assets/tunggak.svg"),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "segera lunasi tagihan anda",
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.33,
                          fontFamily: 'CupertinoSystemText',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF242E49),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Anda memiliki $unpaidCount tagihan yang belum dibayar. Selesaikan pembayaran sebelum batas waktu agar layanan tetap lancar.",
                        style: const TextStyle(fontSize: 12, height: 1.33, color: Color(0xFF242E49)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1E293B),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                onPressed: () => Navigator.pushReplacementNamed(context, '/customer/bills'),
                child: Text(
                  'Lihat Detail',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14.44, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}