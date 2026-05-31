import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_me_bloc.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_me_event.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_me_state.dart';
import 'package:uklmobileapps/features/bill/data/models/bill_model.dart';
import 'package:intl/intl.dart';
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
      extendBody: true, 
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
                      WaterUsageChartPage(bills: sortedBills),
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

class WaterUsageData {
  final String time;
  final double volume;
  final String price;

  WaterUsageData(this.time, this.volume, this.price);
}

class WaterUsageChartPage extends StatefulWidget {
  final List<BillModel> bills;
  const WaterUsageChartPage({super.key, required this.bills});

  @override
  State<WaterUsageChartPage> createState() => _WaterUsageChartPageState();
}

class _WaterUsageChartPageState extends State<WaterUsageChartPage> {
  late List<WaterUsageData> _chartData;
  late TooltipBehavior _tooltipBehavior;

  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    if (month >= 1 && month <= 12) return months[month];
    return '';
  }

  @override
  void initState() {
    super.initState();
    _updateChartData();
    
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
        final WaterUsageData usageData = data;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            usageData.price,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant WaterUsageChartPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bills != oldWidget.bills) {
      _updateChartData();
    }
  }

  void _updateChartData() {
    _chartData = widget.bills.map((bill) {
      String timeStr = '${_getMonthName(bill.month)} ${bill.year}';
      try {
        if (bill.createdAt.isNotEmpty) {
           DateTime dt = DateTime.parse(bill.createdAt).toLocal();
           timeStr = DateFormat('HH.mm').format(dt);
        }
      } catch (e) {
        // ignore
      }
      
      final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
      
      return WaterUsageData(
        timeStr, 
        bill.usageValue.toDouble(), 
        formatCurrency.format(bill.price)
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: SfCartesianChart(
        tooltipBehavior: _tooltipBehavior,
        primaryXAxis: const CategoryAxis(
          title: AxisTitle(text: 'Waktu'),
        ),
        primaryYAxis: const NumericAxis(
          title: AxisTitle(text: 'Volume (m³)', textStyle: TextStyle(fontSize: 12)),
          majorGridLines: MajorGridLines(dashArray: <double>[5, 5]),
        ),
        series: <CartesianSeries>[
          StepAreaSeries<WaterUsageData, String>(
            dataSource: _chartData,
            xValueMapper: (WaterUsageData data, _) => data.time,
            yValueMapper: (WaterUsageData data, _) => data.volume,
            borderDrawMode: BorderDrawMode.top,
            borderColor: Colors.blue,
            borderWidth: 3,
            gradient: LinearGradient(
              colors: [Colors.blue.withOpacity(0.5), Colors.white.withOpacity(0.1)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            markerSettings: const MarkerSettings(
              isVisible: true,
              shape: DataMarkerType.rectangle,
              color: Colors.blue,
              borderWidth: 2,
              borderColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
