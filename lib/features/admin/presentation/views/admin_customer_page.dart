import 'package:flutter/material.dart';
import 'package:uklmobileapps/shared/widgets/nav_model_custom.dart';

class AdminCustomerPage extends StatelessWidget {
  const AdminCustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Admin Customer'),
      ),
      body: const Center(
        child: Text('Halaman Customer', style: TextStyle(fontSize: 24)),
      ),
      bottomNavigationBar: const SafeArea(
        child: NavModelCustom(currentIndex: 2),
      ),
    );
  }
}
