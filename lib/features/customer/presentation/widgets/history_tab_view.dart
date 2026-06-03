import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uklmobileapps/core/network/api_constants.dart';
import 'package:uklmobileapps/shared/widgets/full_screen_image_page.dart';

class HistoryTabView extends StatefulWidget {
  final List<dynamic> allPayments;
  final bool paymentLoading;
  final bool paymentHasMore;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;

  const HistoryTabView({
    super.key,
    required this.allPayments,
    required this.paymentLoading,
    required this.paymentHasMore,
    required this.scrollController,
    required this.onRefresh,
  });

  @override
  State<HistoryTabView> createState() => _HistoryTabViewState();
}

class _HistoryTabViewState extends State<HistoryTabView> {
  String _selectedFilter = 'Menunggu Verifikasi';

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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${_getNamaBulan(date.month)} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredPayments = widget.allPayments.where((p) {
      if (_selectedFilter == 'Semua') return true;
      if (_selectedFilter == 'Menunggu Verifikasi') return !p.verified;
      if (_selectedFilter == 'Pembayaran Berhasil') return p.verified;
      return true;
    }).toList();

    Widget content;
    if (widget.allPayments.isEmpty && widget.paymentLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (widget.allPayments.isEmpty && !widget.paymentLoading) {
      content = const Center(child: Text('Belum ada riwayat pembayaran.'));
    } else if (filteredPayments.isEmpty && !widget.paymentLoading) {
      content = const Center(child: Text('Tidak ada transaksi yang sesuai.'));
    } else {
      content = RefreshIndicator(
        onRefresh: widget.onRefresh,
        color: const Color(0xFF3B82F6),
        backgroundColor: Colors.white,
        child: ListView.builder(
          controller: widget.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 4,
            bottom: 120,
          ),
          itemCount:
              filteredPayments.length + (widget.paymentLoading || widget.paymentHasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == filteredPayments.length) {
              if (widget.paymentLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return const Padding(
                padding: EdgeInsets.all(12),
                child: Center(
                  child: Text(
                    'Semua riwayat telah ditampilkan',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            final p = filteredPayments[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Card(
                elevation: 4,
                color: p.verified ? const Color(0xFFD5F5A3) : const Color(0xFFFFF5AC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Tagihan
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
                              'Tagihan Bulan ${_formatDate(p.createdAt)}',
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

                      // Status Pembayaran
                      Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          p.verified ? 'Status: Pembayaran Berhasil' : 'Status: Menunggu Admin',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: p.verified ? const Color(0xFF53B175) : Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Tombol Lihat Detail
                      GestureDetector(
                        onTap: () {
                          if (p.file.isEmpty) return;
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Detail Pembayaran'),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      p.verified ? 'Status: Berhasil' : 'Status: Menunggu Admin',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: p.verified ? Colors.green : Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => FullScreenImagePage(
                                              imageUrl:
                                                  '${ApiConstants.baseUrl}/payment-proof/${Uri.encodeComponent(p.file)}',
                                              tag: 'payment_image_customer_${p.id}',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Hero(
                                        tag: 'payment_image_customer_${p.id}',
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            '${ApiConstants.baseUrl}/payment-proof/${Uri.encodeComponent(p.file)}',
                                            cacheWidth: 800,
                                            height: 300,
                                            fit: BoxFit.contain,
                                            loadingBuilder:
                                                (context, child, loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return const SizedBox(
                                                    height: 150,
                                                    child: Center(
                                                      child: CircularProgressIndicator(),
                                                    ),
                                                  );
                                                },
                                            errorBuilder: (context, error, stackTrace) =>
                                                Container(
                                                  height: 150,
                                                  color: Colors.grey.shade200,
                                                  child: const Center(
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.broken_image,
                                                          size: 50,
                                                          color: Colors.grey,
                                                        ),
                                                        SizedBox(height: 8),
                                                        Text(
                                                          'Gambar tidak ditemukan',
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Tutup'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(44),
                            color: Colors.white,
                          ),
                          child: Text(
                            'Lihat Detail',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF53B175),
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
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildFilterChip('Menunggu Verifikasi'),
              const SizedBox(width: 8),
              _buildFilterChip('Pembayaran Berhasil'),
              const SizedBox(width: 8),
              _buildFilterChip('Semua'),
            ],
          ),
        ),
        Expanded(child: content),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    Color bgColor = Colors.transparent;
    Color borderColor = const Color(0xFFCBD5E1);
    Color textColor = const Color(0xFF64748B);

    if (isSelected) {
      if (label == 'Menunggu Verifikasi') {
        bgColor = const Color(0xFFFFF5AC);
      } else if (label == 'Pembayaran Berhasil') {
        bgColor = const Color(0xFFD5F5A3);
      } else {
        bgColor = const Color(0xFFE2E8F0);
      }
      borderColor = bgColor;
      textColor = const Color(0xFF1E293B);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
