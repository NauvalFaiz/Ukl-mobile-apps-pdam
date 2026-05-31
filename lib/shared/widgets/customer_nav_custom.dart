import 'package:flutter/material.dart';
import 'package:uklmobileapps/features/customer/presentation/views/customer_dashboard.dart';
import 'package:uklmobileapps/features/customer/presentation/views/customer_bill_page.dart';
import 'package:uklmobileapps/features/customer/presentation/views/customer_profile_page.dart';

class CustomerNavCustom extends StatelessWidget {
  final int currentIndex;
  const CustomerNavCustom({super.key, this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: bottomInset > 0 ? bottomInset : 16,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.087,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              offset: const Offset(0, 10),
              blurRadius: 10,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, 0, Icons.dashboard, 'DASHBOARD'),
            _buildNavItem(context, 1, Icons.receipt_long, 'TAGIHAN'),
            _buildNavItem(context, 2, Icons.person, 'PROFIL'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
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
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.white70,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.white70,
              fontSize: 8,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
