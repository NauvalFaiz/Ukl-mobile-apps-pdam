import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/Intersect.svg',
                width: 100,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0066FF)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'PDAM Mobile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Solusi Praktis Kelola Layanan Air\nBersih dalam Genggaman.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}