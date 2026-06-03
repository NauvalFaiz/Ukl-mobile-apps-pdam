import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTabBar extends StatefulWidget {
  final TabController tabController;
  final List<String> tabs;

  const CustomTabBar({
    super.key,
    required this.tabController,
    this.tabs = const ['Belum Bayar', 'Riwayat'],
  });

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  // BAGIAN initState DAN dispose YANG MEMICU ERROR SUDAH DIHAPUS TOTAL
  // KARENA ANIMASI SEKARANG DIATASI OLEH ANIMATEDBUILDER DI BAWAH

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double tabWidth = constraints.maxWidth / widget.tabs.length;

          return AnimatedBuilder(
            animation: widget.tabController.animation!,
            builder: (context, child) {
              final double animationValue =
                  widget.tabController.animation!.value;

              return Stack(
                children: [
                  Positioned(
                    left: animationValue * tabWidth,
                    width: tabWidth,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D6EFD),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFCCE0FF),
                          width: 3.5,
                        ),
                      ),
                    ),
                  ),

                  // TEKS TAB
                  Row(
                    children: List.generate(widget.tabs.length, (index) {
                      final double distance = (animationValue - index).abs();

                      // Transisi warna teks halus (Linear Interpolation)
                      final Color finalColor = Color.lerp(
                        const Color(0xFF5D6A85), // Abu-abu saat tidak aktif
                        Colors.white, // Putih saat aktif
                        (1 - distance).clamp(0.0, 1.0),
                      )!;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            widget.tabController.animateTo(index);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            alignment: Alignment.center,
                            child: Text(
                              widget.tabs[index],
                              style: GoogleFonts.plusJakartaSans(
                                color: finalColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
