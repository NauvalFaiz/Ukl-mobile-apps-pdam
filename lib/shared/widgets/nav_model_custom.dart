import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uklmobileapps/features/admin/presentation/views/admin_customer_page.dart';
import 'package:uklmobileapps/features/admin/presentation/views/admin_dashboard.dart';
import 'package:uklmobileapps/features/admin/presentation/views/admin_profile_page.dart';
import 'package:uklmobileapps/features/admin/presentation/views/admin_service_page.dart';
import 'package:uklmobileapps/features/admin/presentation/views/admin_transaction_page.dart';

class NavModelCustom extends StatelessWidget {
  final int currentIndex;

  const NavModelCustom({super.key, this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.14,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffF5F5F5)),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff000000).withOpacity(0.15),
            blurRadius: 3.3,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            0,
            "assets/home.svg",
            "assets/home_fill.svg",
            const AdminDashboard(),
          ),
          _buildNavItem(
            context,
            1,
            "assets/service.svg",
            "assets/service_fill.svg",
            const AdminServicePage(),
          ),
          _buildNavItem(
            context,
            2,
            "assets/customor.svg",
            "assets/customor_fill.svg",
            const AdminCustomerPage(),
          ),
          _buildNavItem(
            context,
            3,
            "assets/trans.svg",
            "assets/trans_fill.svg",
            const AdminTransactionPage(),
          ),
          _buildNavItem(
            context,
            4,
            "assets/Profile.svg",
            "assets/Profile_fill.svg",
            const AdminProfilePage(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    String icon,
    String iconFill,
    Widget page,
  ) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (isSelected) return;

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => page,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      child: Container(
        height: 43,
        width: 43,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffD0E4FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(10.49),
        ),
        child: SvgPicture.asset(
          isSelected ? iconFill : icon,
          width: 25,
          height: 25,
        ),
      ),
    );
  }
}
