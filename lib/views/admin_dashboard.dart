import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uklmobileapps/shared/widgets/nav_model_custom.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import 'login_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(child: NavModelCustom()),
      appBar: AppBar(
        title: const Text('Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          )
        ],
      ),
      body: const Center(
        child: Text(
          'ROLE: ADMIN',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
