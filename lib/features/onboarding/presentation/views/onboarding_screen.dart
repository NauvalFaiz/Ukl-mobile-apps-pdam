import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uklmobileapps/features/onboarding/presentation/bloc/onboarding_cubit.dart';
import 'package:uklmobileapps/features/onboarding/presentation/views/widgets/pageonboarding.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentSlideIndex = 0;
  final int _totalPages = 3;
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding(BuildContext context) {
    context.read<OnboardingCubit>().completeOnboarding();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> onboardingPages = [
      OnboardingPageItem(
        backgroundColor: const Color(0xFFFFFFFF),
        title: "Pantau Penggunaan \n Air Lebih Mudah.",
        subtitle:
            "Cek riwayat kubikasi pemakaian air Anda \n kapan saja secara real-time",
        svgPath: 'assets/ilustrasi1.svg',
        height: 409,
        width: 327,
        currentPageIndex: _currentSlideIndex,
        totalPageCount: _totalPages,
      ),
      OnboardingPageItem(
        backgroundColor: Color(0xFFFFFFFF),
        title: "Cek biaya tagihan dan \n bayar tepat waktu.",
        subtitle:
            "Lakukan pembayaran tepat waktu untuk \n menikmati layanan tanpa hambatan.",
        svgPath: 'assets/ilustrasi2.svg',
        height: 409,
        width: 506,
        currentPageIndex: _currentSlideIndex,
        totalPageCount: _totalPages,
      ),
      OnboardingPageItem(
        backgroundColor: Color(0xFFFFFFFF),
        title: "Solusi layanan PDAM \n dalam genggaman",
        subtitle:
            "Saatnya beralih ke layanan PDAM \n langsung dari ponsel Anda.",
        secretIcon: 'assets/buttonscirt.svg',
        svgPath: 'assets/ilustrasi3.svg',
        height: 409,
        width: 470,
        currentPageIndex: _currentSlideIndex,
        totalPageCount: _totalPages,
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: onboardingPages,
              onPageChanged: (index) {
                setState(() {
                  _currentSlideIndex = index;
                });
              },
            ),

            Positioned(
              bottom: 40,
              left: 40,
              right: 40,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      if (_currentSlideIndex < onboardingPages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finishOnboarding(context);
                      }
                    },
                    child: Container(
                      width: 327,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFF0F67FE),
                        borderRadius: BorderRadius.circular(48),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade700.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        _currentSlideIndex == onboardingPages.length - 1
                            ? "Mulai Sekarang"
                            : "Lanjut",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight(700),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Visibility(
                    visible: _currentSlideIndex < onboardingPages.length - 1,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: TextButton(
                      onPressed: () => _finishOnboarding(context),
                      child: Text(
                        "Lewati",
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF242E49),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
}
