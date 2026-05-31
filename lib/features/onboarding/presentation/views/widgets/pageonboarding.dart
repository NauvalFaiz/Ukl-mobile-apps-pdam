import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uklmobileapps/features/auth/presentation/views/admin_registration_page.dart';
import 'package:uklmobileapps/features/auth/presentation/views/dialogs/firstDialog.dart';

class OnboardingPageItem extends StatelessWidget {
  final Color backgroundColor;
  final String svgPath;
  final String title;
  final String subtitle;
  final String? secretIcon;
  final double height;
  final double width;
  final int currentPageIndex;
  final int totalPageCount;

  const OnboardingPageItem({
    super.key,
    required this.backgroundColor,
    required this.svgPath,
    required this.title,
    required this.subtitle,
    this.secretIcon,
    required this.height,
    required this.width,
    required this.currentPageIndex,
    required this.totalPageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            if (secretIcon != null)
              Positioned(
                top: 15,
                right: 24,
                child: GestureDetector(
                  onTap: () {
                    if (ModalRoute.of(context)?.isCurrent == false) {
                      return;
                    }
                    showDialog(
                      context: context,
                      builder: (context) => const Firstdialog(),
                    );
                  },
                  child: SvgPicture.asset(secretIcon!),
                ),
              ),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      svgPath,
                      height: height,
                      width: width,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 29),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(totalPageCount, (index) {
                        bool isActive = currentPageIndex == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isActive ? 24.0 : 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: isActive
                                ? const Color(0xff1976D2)
                                : Colors.grey.shade400,
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 22),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        letterSpacing: -0.26,
                        height: 1.2,
                        fontFamily: 'CupertinoSystemText',
                        fontWeight: FontWeight(700),
                        color: Color(0xff242E49),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.38,
                        fontFamily: 'CupertinoSystemText',
                        color: Color(0xFF5D6A85),
                        fontWeight: FontWeight(400),
                      ),
                    ),
                    const SizedBox(height: 120),
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
