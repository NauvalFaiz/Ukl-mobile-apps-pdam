import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:uklmobileapps/features/auth/presentation/views/login_page.dart';
import 'package:uklmobileapps/features/customer/data/datasources/customer_me_api_service.dart';
import 'package:uklmobileapps/features/customer/presentation/views/customer_bill_page.dart';
import 'package:uklmobileapps/features/customer/presentation/views/customer_profile_page.dart';
import 'package:uklmobileapps/features/onboarding/presentation/bloc/onboarding_cubit.dart';
import 'package:uklmobileapps/core/network/api_client.dart';
import 'package:uklmobileapps/core/storage/token_storage.dart';
import 'package:uklmobileapps/features/auth/data/datasources/auth_service.dart';
import 'package:uklmobileapps/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:uklmobileapps/features/onboarding/presentation/views/splash_screen.dart';
import 'package:uklmobileapps/features/admin/data/datasources/admin_service.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_bloc.dart';
import 'package:uklmobileapps/features/admin/data/datasources/service_api_service.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/service/service_bloc.dart';
import 'package:uklmobileapps/features/admin/data/datasources/customer_api_service.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/customer/customer_bloc.dart';
import 'package:uklmobileapps/features/admin/data/datasources/bill_api_service.dart';
import 'package:uklmobileapps/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:uklmobileapps/features/admin/data/datasources/payment_api_service.dart';
import 'package:uklmobileapps/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_me_bloc.dart';
import 'package:uklmobileapps/features/customer/presentation/views/customer_dashboard.dart';


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
  final serviceApiService = ServiceApiService(apiClient: apiClient);
  final customerApiService = CustomerApiService(apiClient: apiClient);
  final billApiService = BillApiService(apiClient: apiClient);
  final paymentApiService = PaymentApiService(apiClient: apiClient);
  final customerMeApiService = CustomerMeApiService(apiClient: apiClient);

  runApp(MyApp(
    tokenStorage: tokenStorage, 
    authService: authService, 
    adminService: adminService,
    serviceApiService: serviceApiService,
    customerApiService: customerApiService,
    billApiService: billApiService,
    paymentApiService: paymentApiService,
    customerMeApiService: customerMeApiService,
  ));
}

class MyApp extends StatelessWidget {
  final TokenStorage tokenStorage;
  final AuthService authService;
  final AdminService adminService;
  final ServiceApiService serviceApiService;
  final CustomerApiService customerApiService;
  final BillApiService billApiService;
  final PaymentApiService paymentApiService;
  final CustomerMeApiService customerMeApiService;

  const MyApp({
    super.key,
    required this.tokenStorage,
    required this.authService,
    required this.adminService,
    required this.serviceApiService,
    required this.customerApiService,
    required this.billApiService,
    required this.paymentApiService,
    required this.customerMeApiService,
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
        BlocProvider<ServiceBloc>(
          create: (context) => ServiceBloc(apiService: serviceApiService),
        ),
        BlocProvider<CustomerBloc>(
          create: (context) => CustomerBloc(apiService: customerApiService),
        ),
        BlocProvider<BillBloc>(
          create: (context) => BillBloc(apiService: billApiService),
        ),
        BlocProvider<PaymentBloc>(
          create: (context) => PaymentBloc(apiService: paymentApiService),
        ),
        BlocProvider<CustomerMeBloc>(
          create: (context) => CustomerMeBloc(apiService: customerMeApiService),
        ),
      ],
      child: MaterialApp(
        title: 'PDAM App Test',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/customer/dashboard': (context) => const CustomerDashboard(),
          '/customer/bills': (context) => const CustomerBillPage(),
          '/customer/profile': (context) => const CustomerProfilePage(),
        },
      ),
    );
  }
}
