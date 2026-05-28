import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:uklmobileapps/features/auth/presentation/views/login_page.dart';
import 'package:uklmobileapps/features/onboarding/presentation/bloc/onboarding_cubit.dart';
import 'package:uklmobileapps/core/network/api_client.dart';
import 'package:uklmobileapps/core/storage/token_storage.dart';
import 'package:uklmobileapps/features/auth/data/datasources/auth_service.dart';
import 'package:uklmobileapps/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:uklmobileapps/features/onboarding/presentation/views/splash_screen.dart';
import 'package:uklmobileapps/features/admin/data/datasources/admin_service.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Peringatan: File .env tidak ditemukan, menggunakan fallback URL.");
  }

  final prefs = await SharedPreferences.getInstance();
  final tokenStorage = TokenStorage(prefs);

  final dio = Dio();
  final apiClient = ApiClient(dio: dio, tokenStorage: tokenStorage);
  final authService = AuthService(apiClient: apiClient);
  final adminService = AdminService(apiClient: apiClient);

  runApp(MyApp(tokenStorage: tokenStorage, authService: authService, adminService: adminService));
}

class MyApp extends StatelessWidget {
  final TokenStorage tokenStorage;
  final AuthService authService;
  final AdminService adminService;

  const MyApp({
    super.key,
    required this.tokenStorage,
    required this.authService,
    required this.adminService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              AuthBloc(authService: authService, tokenStorage: tokenStorage),
        ),
        BlocProvider<OnboardingCubit>(
          create: (_) => OnboardingCubit()..checkOnboardingStatus(),
        ),
        BlocProvider<AdminProfileBloc>(
          create: (context) => AdminProfileBloc(adminService: adminService),
        ),
      ],
      child: MaterialApp(
        title: 'PDAM App Test',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const SplashScreen(),
        routes: {'/login': (context) => const LoginPage()},
      ),
    );
  }
}
