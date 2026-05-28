import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uklmobileapps/features/admin/presentation/views/admin_dashboard.dart';
import 'package:uklmobileapps/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:uklmobileapps/features/auth/presentation/bloc/auth_event.dart';
import 'package:uklmobileapps/features/auth/presentation/bloc/auth_state.dart';
import 'package:uklmobileapps/features/auth/presentation/views/login_page.dart' show LoginPage;
import 'package:uklmobileapps/features/customer/presentation/views/customer_dashboard.dart';
import 'package:uklmobileapps/features/onboarding/presentation/bloc/onboarding_cubit.dart';
import 'package:uklmobileapps/features/onboarding/presentation/views/onboarding_screen.dart';

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

  void _handleUnauthenticatedNavigation(BuildContext context) {
    final isFirstTime = context.read<OnboardingCubit>().state;

    if (isFirstTime) {
      _navigateReplace(context, const OnboardingScreen());
    } else {
      // Solusi Error: Membungkus LoginPage dengan BlocProvider.value
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (newContext) => BlocProvider.value(
            value: context.read<AuthBloc>(),
            child: const LoginPage(),
          ),
        ),
      );
    }
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
                _handleUnauthenticatedNavigation(context);
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
              Text('PDAM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}