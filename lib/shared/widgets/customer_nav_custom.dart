import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uklmobileapps/features/customer/presentation/views/customer_dashboard.dart';
import 'package:uklmobileapps/features/customer/presentation/views/customer_bill_page.dart';
import 'package:uklmobileapps/features/customer/presentation/views/customer_profile_page.dart';

class CustomerNavCustom extends StatelessWidget {
  final int currentIndex;
  const CustomerNavCustom({super.key, this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.12,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xffF5F5F5)),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xff000000).withOpacity(0.15),
            offset: const Offset(0, 0),
            blurRadius: 3.3,
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
            'DASHBOARD',
          ),
          _buildNavItem(
            context,
            1,
            "assets/trans.svg",
            "assets/trans_fill.svg",
            'TAGIHAN',
          ),
          _buildNavItem(
            context,
            2,
            "assets/Profile.svg",
            "assets/Profile_fill.svg",
            'PROFIL',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    String icon,
    String icon_fill,
    String label,
  ) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (isSelected) return;
        Widget page;
        switch (index) {
          case 0:
            page = const CustomerDashboard();
            break;
          case 1:
            page = const CustomerBillPage();
            break;
          case 2:
            page = const CustomerProfilePage();
            break;
          default:
            page = const CustomerDashboard();
        }
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => page,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 43,
            width: 43,
            alignment: AlignmentDirectional.center,
            decoration: BoxDecoration(
              color: isSelected ? Color(0xffD0E4FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(10.49),
            ),
            child: SvgPicture.asset(
              isSelected ? icon_fill : icon,
              height: 25.17,
              width: 25.17,
            ),
          ),
        ],
      ),
    );
  }
}
