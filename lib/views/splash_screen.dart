import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import 'login_page.dart';
import 'admin_dashboard.dart';
import 'customer_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthCheckStatus());
  }

  void _navigateBasedOnRole(BuildContext context, AuthAuthenticated state) {
    Widget page;
    if (state.role.toUpperCase() == 'ADMIN') {
      page = const AdminDashboard();
    } else {
      page = const CustomerDashboard();
    }
    _navigateReplace(context, page);
  }

  void _navigateReplace(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _navigateBasedOnRole(context, state);
          } else if (state is AuthUnauthenticated || state is AuthFailure) {
            Future.delayed(const Duration(milliseconds: 2000), () {
              if (mounted) {
                _navigateReplace(context, const LoginPage());
              }
            });
            
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          }
        },
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Memuat Sistem (Test Mode)...', style: TextStyle(fontSize: 18)),
              SizedBox(height: 16),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
