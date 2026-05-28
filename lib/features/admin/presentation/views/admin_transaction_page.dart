import 'package:flutter/material.dart';
import 'package:uklmobileapps/shared/widgets/nav_model_custom.dart';

class AdminTransactionPage extends StatelessWidget {
  const AdminTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Admin Transaksi'),
      ),
      body: const Center(
        child: Text('Halaman Transaksi', style: TextStyle(fontSize: 24)),
      ),
      bottomNavigationBar: const SafeArea(
        child: NavModelCustom(currentIndex: 3),
      ),
    );
  }
}
