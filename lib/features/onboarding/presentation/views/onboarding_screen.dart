import 'package:amicons/amicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:uklmobileapps/features/onboarding/presentation/bloc/onboarding_cubit.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentSlideIndex = 0;

  void _finishOnboarding(BuildContext context) {
    // 1. Simpan status onboarding ke SharedPreferences via Cubit
    context.read<OnboardingCubit>().completeOnboarding();

    // 2. Solusi Error: Mengoper AuthBloc ke LoginPage agar tidak hilang jalurnya
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> onboardingPages = [
      _buildPage(
        context,
        backgroundColor: Colors.blue.shade50,
        icon: Icons.water_drop,
        iconColor: Colors.blue.shade700,
        title: "Kemudahan Layanan PDAM",
        subtitle:
            "Sekarang pantau penggunaan air dan bayar tagihan jadi lebih mudah langsung dari genggaman Anda.",
      ),
      _buildPage(
        context,
        backgroundColor: Colors.green.shade50,
        icon: Icons.analytics_outlined,
        iconColor: Colors.green.shade700,
        title: "Catat Meter Mandiri",
        subtitle:
            "Laporkan angka meteran air Anda secara mandiri setiap bulan dengan akurat tanpa perlu menunggu petugas.",
      ),
      _buildPage(
        context,
        backgroundColor: Colors.amber.shade50,
        icon: Icons.notifications_active_outlined,
        iconColor: Colors.amber.shade700,
        title: "Notifikasi Real-time",
        subtitle:
            "Dapatkan informasi instan mengenai gangguan layanan, info pemeliharaan, hingga pengingat jatuh tempo.",
        secret_icon: "!",
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          CarouselSlider(
            items: onboardingPages,
            carouselController: _carouselController,
            options: CarouselOptions(
              height: double.infinity,
              viewportFraction: 1.0,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentSlideIndex = index;
                });
              },
            ),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _currentSlideIndex < onboardingPages.length - 1
                    ? TextButton(
                        onPressed: () => _finishOnboarding(context),
                        child: const Text(
                          "Lewati",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : const SizedBox(width: 60),
                Row(
                  children: onboardingPages.asMap().entries.map((entry) {
                    bool isActive = _currentSlideIndex == entry.key;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isActive ? 24.0 : 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: isActive
                            ? Colors.blue.shade700
                            : Colors.grey.shade400,
                      ),
                    );
                  }).toList(),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_currentSlideIndex < onboardingPages.length - 1) {
                      _carouselController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _finishOnboarding(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentSlideIndex == onboardingPages.length - 1
                        ? "Mulai"
                        : "Lanjut",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(
    BuildContext context, {
    required Color backgroundColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? secret_icon,
  }) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            if (secret_icon != null)
              Positioned(
                top: 15,
                right: 24,
                child: GestureDetector(
                  onTap: () {
                    print("Secret icon ditekan!");
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        secret_icon,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: iconColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 100, color: iconColor),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
