import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uklmobileapps/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:uklmobileapps/features/auth/presentation/bloc/auth_event.dart';
import 'package:uklmobileapps/features/auth/presentation/views/login_page.dart';
import 'package:uklmobileapps/shared/widgets/nav_model_custom.dart';
import 'package:uklmobileapps/core/network/api_client.dart';
import 'package:uklmobileapps/core/storage/token_storage.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int totalCustomers = 0;
  int pendingVerifications = 0;
  int totalServices = 0;
  int totalBills = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenStorage = TokenStorage(prefs);
      final apiClient = ApiClient(dio: Dio(), tokenStorage: tokenStorage);
      final dio = apiClient.dio;

      final futures = await Future.wait([
        dio.get('/customers'),
        dio.get('/payments'),
        dio.get('/services'),
        dio.get('/bills'),
      ]);

      final customersRes = futures[0].data;
      final paymentsRes = futures[1].data;
      final servicesRes = futures[2].data;
      final billsRes = futures[3].data;

      if (!mounted) return;

      setState(() {
        totalCustomers = _parseCount(customersRes);
        pendingVerifications = _parsePending(paymentsRes);
        totalServices = _parseCount(servicesRes);
        totalBills = _parseCount(billsRes);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetch dashboard: $e');
      
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  int _parseCount(dynamic res) {
    if (res is Map<String, dynamic> && res.containsKey('count')) {
      return (res['count'] as num).toInt();
    }
    return 0;
  }

  int _parsePending(dynamic res) {
    List<dynamic> list = [];
    if (res is List) {
      list = res;
    } else if (res is Map<String, dynamic> && res['data'] is List) {
      list = res['data'];
    }

    int pending = 0;
    for (var item in list) {
      if (item is Map<String, dynamic> &&
          item['status'] is Map<String, dynamic>) {
        if (item['status']['verified'] == false) {
          pending++;
        }
      }
    }
    return pending;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const NavModelCustom(currentIndex: 0),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Operasional',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        _buildStatCard(
                          'Total Customer',
                          totalCustomers.toString(),
                          Icons.people,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Butuh Verifikasi',
                          pendingVerifications.toString(),
                          Icons.warning,
                          Colors.red,
                        ),
                        _buildStatCard(
                          'Jenis Layanan',
                          totalServices.toString(),
                          Icons.settings,
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Total Tagihan',
                          totalBills.toString(),
                          Icons.receipt,
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isAlert = false,
  }) {
    return Card(
      color: isAlert ? Colors.red : Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: isAlert ? Colors.white : color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isAlert ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isAlert ? Colors.white : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}