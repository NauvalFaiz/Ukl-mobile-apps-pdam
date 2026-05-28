import 'package:flutter/material.dart';
import 'package:uklmobileapps/features/admin/presentation/views/admin_dashboard.dart';
import 'package:uklmobileapps/features/admin/presentation/views/admin_service_page.dart';
import 'package:uklmobileapps/features/admin/presentation/views/admin_customer_page.dart';
import 'package:uklmobileapps/features/admin/presentation/views/admin_transaction_page.dart';
import 'package:uklmobileapps/features/admin/presentation/views/admin_profile_page.dart';

class NavModelCustom extends StatelessWidget {
  final int currentIndex;
  const NavModelCustom({super.key, this.currentIndex = 0});

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
          _buildNavItem(context, 1, Icons.miscellaneous_services, 'SERVICE'),
          _buildNavItem(context, 2, Icons.people, 'CUSTOMER'),
          _buildNavItem(context, 3, Icons.receipt, 'TRANSAKSI'),
          _buildNavItem(context, 4, Icons.person, 'PROFIL'),
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
            page = const AdminDashboard();
            break;
          case 1:
            page = const AdminServicePage();
            break;
          case 2:
            page = const AdminCustomerPage();
            break;
          case 3:
            page = const AdminTransactionPage();
            break;
          case 4:
            page = const AdminProfilePage();
            break;
          default:
            page = const AdminDashboard();
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


