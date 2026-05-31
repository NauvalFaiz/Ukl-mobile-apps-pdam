import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_me_bloc.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_me_event.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_me_state.dart';
import 'package:uklmobileapps/shared/widgets/customer_nav_custom.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerMeBloc>().add(FetchDashboardData());
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    if (month >= 1 && month <= 12) return months[month];
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // TETAP ADA: Sesuai keinginan agar navbar menembus body
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Dashboard'),
      ),
      body: BlocBuilder<CustomerMeBloc, CustomerMeState>(
        builder: (context, state) {
          if (state is CustomerMeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CustomerDashboardLoaded) {
            final profile = state.profile;
            final bills = state.bills;
            final unpaidCount = bills.where((b) => !b.paid).length;

            // Data Grafik: Urutkan tagihan berdasar tahun lalu bulan
            final sortedBills = List.of(bills)
              ..sort((a, b) {
                if (a.year != b.year) return a.year.compareTo(b.year);
                return a.month.compareTo(b.month);
              });

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CustomerMeBloc>().add(FetchDashboardData());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Sapaan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Halo, ${profile.name}!',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'No: ${profile.customerNumber}',
                            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Tagihan Belum Dibayar
                    if (unpaidCount > 0)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Anda memiliki $unpaidCount tagihan yang belum dibayar.',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/customer/bills');
                              },
                              child: const Text('Bayar Sekarang', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: const Text(
                          'Semua tagihan Anda sudah lunas. Terima kasih!',
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                    
                    const SizedBox(height: 32),
                    const Text('Grafik Penggunaan Air', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),

                    // Chart
                    if (sortedBills.isEmpty)
                      const Center(child: Text('Belum ada data penggunaan'))
                    else
                      SizedBox(
                        height: 250,
                        child: BarChart(
                          BarChartData(
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final b = sortedBills[groupIndex];
                                  return BarTooltipItem(
                                    '${b.usageValue} m³\nRp ${b.price}',
                                    const TextStyle(color: Colors.white),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index >= 0 && index < sortedBills.length) {
                                      final b = sortedBills[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          '${_getMonthName(b.month)}\n${b.year}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(
                              sortedBills.length,
                              (i) => BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: sortedBills[i].usageValue.toDouble(),
                                    color: Colors.blue,
                                    width: 16,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    // SIZEDBOX PENAHAN TETAP ADA: Menghindari ketutupan navbar akibat extendBody
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            );
          }
          if (state is CustomerMeError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Memuat data...'));
        },
      ),
      bottomNavigationBar: const CustomerNavCustom(currentIndex: 0),
    );
  }
}
