import 'package:flutter/material.dart';
import 'package:uklmobileapps/shared/widgets/nav_model_custom.dart';

class AdminServicePage extends StatelessWidget {
  const AdminServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:false, 
        title: Text('Admin Service'),),
      body: const Center(
        child: Text('Halaman Service', style: TextStyle(fontSize: 24)),
      ),
      bottomNavigationBar: const NavModelCustom(currentIndex: 1),
    );
  }
}
