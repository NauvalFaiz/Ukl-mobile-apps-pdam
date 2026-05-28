import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import 'blocs/auth/auth_bloc.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'shared/token_storage.dart';
import 'views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Local Storage
  final prefs = await SharedPreferences.getInstance();
  final tokenStorage = TokenStorage(prefs);

  // 2. Inisialisasi API Client & Service
  final dio = Dio();
  final apiClient = ApiClient(dio: dio, tokenStorage: tokenStorage);
  final authService = AuthService(apiClient: apiClient);

  runApp(MyApp(
    tokenStorage: tokenStorage,
    authService: authService,
  ));
}

class MyApp extends StatelessWidget {
  final TokenStorage tokenStorage;
  final AuthService authService;

  const MyApp({
    super.key,
    required this.tokenStorage,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authService: authService,
            tokenStorage: tokenStorage,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'PDAM App Test',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // Mulai dari SplashScreen
        home: const SplashScreen(),
      ),
    );
  }
}
