import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uklmobileapps/core/network/api_client.dart';
import 'package:uklmobileapps/core/storage/token_storage.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_bloc.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_event.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_state.dart';
import 'package:uklmobileapps/shared/widgets/nav_model_custom.dart';
import 'package:uklmobileapps/shared/widgets/time.dart';
import 'package:uklmobileapps/features/customer/presentation/widgets/ts.dart';
import 'package:uklmobileapps/features/admin/presentation/views/admin_transaction_page.dart';

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

  String adminName = 'Admin';
  String adminEmail = '';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    context.read<AdminProfileBloc>().add(FetchAdminProfileEvent());
    _fetchDashboardData();
    _fetchAdminProfile();
  }

  Future<void> _fetchAdminProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenStorage = TokenStorage(prefs);

      final apiClient = ApiClient(dio: Dio(), tokenStorage: tokenStorage);

      final response = await apiClient.dio.get('/me');

      if (!mounted) return;

      final data = response.data['data'];

      setState(() {
        adminName = data['name'] ?? 'Admin';
        adminEmail = data['email'] ?? '';
      });
    } catch (e) {
      debugPrint('Error fetch profile: $e');
    }
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
    if (res is Map<String, dynamic>) {
      if (res['count'] != null) {
        return (res['count'] as num).toInt();
      }

      if (res['data'] is List) {
        return (res['data'] as List).length;
      }
    }

    if (res is List) {
      return res.length;
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
      if (item is Map<String, dynamic>) {
        if (item['verified'] == false || item['verified'] == 0 || item['verified'] == '0') {
          pending++;
        }
      }
    }

    return pending;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const NavModelCustom(currentIndex: 0),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0.0,

        title: BlocBuilder<AdminProfileBloc, AdminProfileState>(
          builder: (context, state) {
            if (state is AdminProfileLoaded) {
              return Row(
                children: [
                  SvgPicture.asset('assets/admin.svg', width: 40, height: 40),

                  const SizedBox(width: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GreetingWidget(userName: state.name),

                      Text(
                        state.role,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xff818BA0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                SvgPicture.asset('assets/admin.svg', width: 40, height: 40),
                const SizedBox(width: 12),
                const Text('Memuat...'),
              ],
            );
          },
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                AppDate.format(DateTime.now()),
                style: const TextStyle(
                  color: Color(0xff818BA0),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data dan Aktivitas',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF242E49),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildLargeCard(
                    title: 'Total Customer',
                    value: totalCustomers.toString(),
                    icon: 'assets/customor_fill.svg',
                    color: const Color(0xFF2166F3),
                    bgColor: const Color(0xFFF7FAFF),
                  ),

                  const SizedBox(height: 16),

                  _buildLargeCard(
                    title: 'Butuh Verifikasi',
                    value: pendingVerifications.toString(),
                    icon: 'assets/icon.svg',
                    color: const Color(0xFFF84B5E),
                    bgColor: const Color(0xFFFFF7F8),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) =>
                              const AdminTransactionPage(initialTabIndex: 1),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildSmallCard(
                          title: 'Total Tagihan',
                          value: totalBills.toString(),
                          icon: 'assets/trans_fill.svg',
                          color: const Color(0xFFF6CD00),
                          bgColor: const Color(0xFFFFFDF4),
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: _buildSmallCard(
                          title: 'Jenis Layanan',
                          value: totalServices.toString(),
                          icon: 'assets/service_fill.svg',
                          color: const Color(0xFF2166F3),
                          bgColor: const Color(0xFFF7FAFF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLargeCard({
    required String title,
    required String value,
    required String icon,
    required Color color,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.15)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5C6B8A),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withOpacity(.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SvgPicture.asset(icon, height: 21.17, width: 21.17),
              ),
              const SizedBox(width: 16),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF242E49),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: 145,
            height: 44,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Lihat',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCard({
    required String title,
    required String value,
    required String icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.15)),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5C6B8A),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withOpacity(.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SvgPicture.asset(
                  icon,
                  color: color,
                  height: 21.17,
                  width: 21.17,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF242E49),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 120,
            height: 40,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Lihat',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
