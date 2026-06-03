import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uklmobileapps/features/bill/data/models/bill_model.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_me_state.dart';

class UnpaidTabView extends StatelessWidget {
  final CustomerMeState state;
  final int? selectedUnpaidBillId;
  final ValueChanged<int?> onBillSelected;
  final Function(BillModel) onUploadPressed;

  const UnpaidTabView({
    super.key,
    required this.state,
    required this.selectedUnpaidBillId,
    required this.onBillSelected,
    required this.onUploadPressed,
  });

  String _getNamaBulan(int monthNumber) {
    const daftarBulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    if (monthNumber >= 1 && monthNumber <= 12) {
      return daftarBulan[monthNumber - 1];
    }
    return monthNumber.toString();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Validasi State Utama
    if (state is CustomerDashboardLoaded) {
      final loadedState = state as CustomerDashboardLoaded;
      final profile = loadedState.profile;

      // Mengambil daftar tagihan yang belum dibayar
      final unpaid = loadedState.bills.where((b) => !b.paid).toList();

      // Kasus jika tidak ada tagihan tertunggak
      if (unpaid.isEmpty) {
        return const Center(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Text(
                'Tidak ada tagihan tertunggak.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }

      // Mengurutkan dari tahun/bulan terbaru di atas ke tertua di bawah
      unpaid.sort((a, b) {
        if (b.year != a.year) {
          return b.year.compareTo(a.year);
        }
        return b.month.compareTo(a.month);
      });

      // OPTIMASI: Menggunakan komponen ListView utama yang adaptif
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: unpaid.length,
        itemBuilder: (context, index) {
          final selectedBill = unpaid[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Card(
              elevation: 4,
              color: const Color(0xFFFFD7DD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bulan Tagihan
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Tagihan Bulan ${_getNamaBulan(selectedBill.month)} ${selectedBill.year}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF242E49),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Layanan Rumah Tangga',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Detail Informasi Tagihan
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                "ID: ${profile.serviceId}",
                                style: const TextStyle(
                                  fontSize: 17,
                                  height: 1.33,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF242E49),
                                ),
                              ),
                            ),
                            const Divider(height: 20, thickness: 1),
                            _buildInfoRow(
                              label: 'Total penggunaan air',
                              value: '${selectedBill.usageValue} m³',
                              valueStyle: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF3D4966),
                              ),
                            ),
                            _buildInfoRow(
                              label: 'Total tagihan',
                              value: 'Rp. ${selectedBill.price}',
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Rp. ${selectedBill.price}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF242E49),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tombol Aksi Unggah Bukti
                    GestureDetector(
                      onTap: () => onUploadPressed(selectedBill),
                      child: Container(
                        width: double.infinity,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(44),
                          color: Colors.white,
                        ),
                        child: Text(
                          'Unggah Bukti Pembayaran',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFFA4D5E),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    // 2. Fallback Jika State Masih Loading / Mengalami Error diluar DashboardLoaded
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFA4D5E)),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
          Text(
            value,
            style:
                valueStyle ??
                const TextStyle(
                  fontSize: 13,
                  height: 1.33,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF3D4966),
                ),
          ),
        ],
      ),
    );
  }
}
