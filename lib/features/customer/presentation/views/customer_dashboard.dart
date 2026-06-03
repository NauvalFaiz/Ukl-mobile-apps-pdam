import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_me_bloc.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_me_event.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_me_state.dart';
import 'package:uklmobileapps/features/bill/data/models/bill_model.dart';
import 'package:intl/intl.dart';
import 'package:uklmobileapps/shared/widgets/customer_nav_custom.dart';
import 'package:uklmobileapps/shared/widgets/time.dart';

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
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    if (month >= 1 && month <= 12) return months[month];
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: BlocBuilder<CustomerMeBloc, CustomerMeState>(
        builder: (context, state) {
          if (state is CustomerMeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CustomerDashboardLoaded) {
            final profile = state.profile;
            final bills = state.bills;

            // Filter hanya tagihan yang BELUM lunas
            final unpaidBills = bills.where((b) => !b.paid).toList();
            final unpaidCount = unpaidBills.length;

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
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      surfaceTintColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      titleSpacing: 0,
                      automaticallyImplyLeading: false,
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset('assets/profilCus.svg'),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GreetingWidget(userName: profile.name),
                          Text(
                            'ID: ${profile.customerNumber}',
                            style: const TextStyle(
                              height: 1.33,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF242E49),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Informasi Tagihan",
                          style: TextStyle(
                            fontFamily: 'CupertinoSystemText',
                            fontSize: 20,
                            height: 1.33,
                            color: Color(0xFF242E49),
                            fontWeight: FontWeight(590),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 20),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                context,
                                '/customer/bills',
                              );
                            },
                            child: SvgPicture.asset("assets/go.svg"),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    if (unpaidCount == 0) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(19),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAFBD9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset("assets/done.svg"),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Tidak ada tagihan",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF242E49),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Seluruh tagihan air anda bulan ini dan sebelumnya sudah lunas, terimakasih.",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: const Color(0xFF5D6A85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (unpaidCount == 1) ...[
                      // DESAIN 2: JIKA ADA 1 TAGIHAN - BIRU
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD2E4FF),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(19.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset("assets/blue.svg"),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          "Tagihan sudah diterbitkan",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'CupertinoSystemText',
                                            color: Color(0xFF242E49),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Tagihan air anda bulan ${_getMonthName(unpaidBills.first.month)} ini sudah tersedia. periksa rinciannya sekarang.",
                                          style: const TextStyle(
                                            fontSize: 15,
                                            height: 1.3,
                                            fontFamily: 'CupertinoSystemText',
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF3D4966),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF242E49),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/customer/bills',
                                    );
                                  },
                                  child: const Text(
                                    'Lihat Detail',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else if (unpaidCount <= 5) ...[
                      // DESAIN 3: KONDISI 2 SAMPAI 5 TAGIHAN - MERAH (DENGAN RINCIAN LIST)
                      (() {
                        final sortedUnpaidBills =
                            List<BillModel>.from(unpaidBills)..sort((a, b) {
                              int yearCompare = b.year.compareTo(a.year);
                              if (yearCompare != 0) return yearCompare;
                              return b.month.compareTo(a.month);
                            });

                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xffFFD7DD),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(19.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset("assets/logo_bils.svg"),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Segera lunasi tagihan anda",
                                            style: TextStyle(
                                              fontSize: 15,
                                              height: 1.33,
                                              fontWeight: FontWeight(590),
                                              fontFamily: 'CupertinoSystemText',
                                              color: Color(0xFF242E49),
                                            ),
                                          ),
                                          Text(
                                            "Anda memiliki $unpaidCount tagihan yang belum dibayar",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              height: 1.33,
                                              fontFamily: 'CupertinoSystemText',
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF3D4966),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ...sortedUnpaidBills.map((bill) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8.0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${_getMonthName(bill.month)} ${bill.year}',
                                                style: const TextStyle(
                                                  color: Color(0xFF4A5568),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                formatCurrency.format(
                                                  bill.price,
                                                ),
                                                style: const TextStyle(
                                                  color: Color(0xFF2D3748),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      const Divider(
                                        color: Color(0xEFEFEFEF),
                                        thickness: 1,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Total:',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            formatCurrency.format(
                                              sortedUnpaidBills.fold<num>(
                                                0,
                                                (sum, b) => sum + b.price,
                                              ),
                                            ),
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFFFA4A5B),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/customer/bills',
                                      );
                                    },
                                    child: const Text(
                                      'Bayar Sekarang',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }()),
                    ] else ...[
                      // DESAIN 4: LEBIH DARI 5 TUNGGAKAN - KUNING (SESUAI GAMBAR)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFFF9D2,
                          ), // Warna background kuning lembut sesuai gambar
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(19.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Menggunakan asset baru yang kamu minta
                                  SvgPicture.asset("assets/tunggak.svg"),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          "segera lunasi tagihan anda",
                                          style: TextStyle(
                                            fontSize: 15,
                                            height: 1.33,
                                            fontFamily: 'CupertinoSystemText',
                                            fontWeight: FontWeight(590),
                                            color: Color(0xFF242E49),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Anda memiliki $unpaidCount tagihan yang belum dibayar. Selesaikan pembayaran sebelum batas waktu agar layanan tetap lancar.",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            height: 1.33,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF242E49),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF1E293B),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/customer/bills',
                                    );
                                  },
                                  child: Text(
                                    'Lihat Detail',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14.44,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // ======================= Garfik ==================================================
                    const SizedBox(height: 32),
                    const Text(
                      'Grafik Pemakaian Air',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'CupertinoSystemText',
                        color: Color(0xFF242E49),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (sortedBills.isEmpty)
                      const Center(child: Text('Belum ada data penggunaan'))
                    else
                      WaterUsageChartPage(bills: sortedBills),

                    Text(
                      "Tips",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'CupertinoSystemText',
                        color: Color(0xFF242E49),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: SvgPicture.asset("assets/tips.svg"),
                    ),
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
  final Color color;
  final Color bgColor;

  WaterUsageData(this.time, this.volume, this.price, this.color, this.bgColor);
}

class WaterUsageChartPage extends StatefulWidget {
  final List<BillModel> bills;
  const WaterUsageChartPage({super.key, required this.bills});

  @override
  State<WaterUsageChartPage> createState() => _WaterUsageChartPageState();
}

class _WaterUsageChartPageState extends State<WaterUsageChartPage> {
  late List<WaterUsageData> _chartData;
  int _selectedFilterIndex = 2; // Default to 'Semua'

  final ZoomPanBehavior _zoomPanBehavior = ZoomPanBehavior(
    enablePanning: true,
    zoomMode: ZoomMode.x,
  );

  late final TooltipBehavior _tooltipBehavior = TooltipBehavior(
    enable: true,
    color: Colors.transparent,
    elevation: 0,
    builder:
        (
          dynamic data,
          dynamic point,
          dynamic series,
          int pointIndex,
          int seriesIndex,
        ) {
          final WaterUsageData usageData = data;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: usageData.bgColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              usageData.price,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: usageData.color,
                fontSize: 12,
              ),
            ),
          );
        },
  );

  final formatCurrency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp. ',
    decimalDigits: 0,
  );

  String _getMonthName(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    if (month >= 1 && month <= 12) {
      return monthNames[month - 1];
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _updateChartData();
  }

  @override
  void didUpdateWidget(covariant WaterUsageChartPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bills != oldWidget.bills) {
      _updateChartData();
    }
  }

  void _updateChartData() {
    if (widget.bills.isEmpty) {
      _chartData = [];
      return;
    }

    List<BillModel> filteredBills = List.from(widget.bills);

    if (_selectedFilterIndex == 0) {
      // 'Bulan' -> Tampilkan 6 bulan terakhir agar kurva terbentuk
      if (filteredBills.length > 6) {
        filteredBills = filteredBills.sublist(filteredBills.length - 6);
      }
    } else if (_selectedFilterIndex == 1) {
      // 'Tahun' -> 12 bulan terakhir
      if (filteredBills.length > 12) {
        filteredBills = filteredBills.sublist(filteredBills.length - 12);
      }
    }

    if (filteredBills.isEmpty) {
      _chartData = [];
      return;
    }

    double maxVol = filteredBills
        .map((e) => e.usageValue.toDouble())
        .reduce((a, b) => a > b ? a : b);
    double minVol = filteredBills
        .map((e) => e.usageValue.toDouble())
        .reduce((a, b) => a < b ? a : b);

    _chartData = filteredBills.map((bill) {
      // Adding year ensures uniqueness if data spans multiple years
      String timeStr = '${_getMonthName(bill.month)} ${bill.year}';
      double vol = bill.usageValue.toDouble();

      Color textColor = const Color(0xFF2196F3);
      Color bgColor = const Color(0xFFD2E4FF);

      if (vol == maxVol && maxVol > 0) {
        textColor = const Color(0xFFFA4A5B); // Merah
        bgColor = const Color(0xFFFFD7DD);
      } else if (vol == minVol && minVol < maxVol) {
        textColor = const Color(0xFFFFB300); // Kuning
        bgColor = const Color(0xFFFFF9D2);
      } else if (vol > minVol && vol < maxVol) {
        textColor = const Color(0xFF2196F3); // Biru
        bgColor = const Color(0xFFD2E4FF);
      }

      return WaterUsageData(
        timeStr,
        vol,
        formatCurrency.format(bill.price),
        textColor,
        bgColor,
      );
    }).toList();
  }

  Widget _buildFilterButton(int index, String text) {
    bool isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
          _updateChartData();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5D6A85) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFD4D4D4),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF5D6A85),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterButton(0, 'Bulan'),
              const SizedBox(width: 8),
              _buildFilterButton(1, 'Tahun'),
              const SizedBox(width: 8),
              _buildFilterButton(2, 'Semua'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 340, // slightly taller to fit labels
          child: ExcludeSemantics(
            child: SfCartesianChart(
              tooltipBehavior: _tooltipBehavior,
              zoomPanBehavior: _zoomPanBehavior,
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                autoScrollingDelta: 5,
                autoScrollingMode: AutoScrollingMode.end,
                majorGridLines: const MajorGridLines(width: 0),
                majorTickLines: const MajorTickLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelPlacement: LabelPlacement.onTicks,
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                labelStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontStyle: FontStyle.italic,
                  fontSize: 11,
                ),
              ),
              primaryYAxis: const NumericAxis(
                labelFormat: '{value} m³',
                rangePadding: ChartRangePadding.round,
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: Color(0xFFE2E8F0),
                  dashArray: <double>[5, 5],
                ),
                majorTickLines: MajorTickLines(width: 0),
                axisLine: AxisLine(width: 0),
                labelStyle: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontStyle: FontStyle.italic,
                ),
              ),
              margin: const EdgeInsets.only(
                top: 40,
                bottom: 10,
                left: 10,
                right: 20,
              ), // More top margin for labels
              series: <CartesianSeries>[
                SplineAreaSeries<WaterUsageData, String>(
                  dataSource: _chartData,
                  xValueMapper: (WaterUsageData data, _) => data.time,
                  yValueMapper: (WaterUsageData data, _) => data.volume,
                  borderColor: Colors.transparent,
                  borderWidth: 0,
                  enableTooltip: false,
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.3),
                      Colors.blue.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                SplineSeries<WaterUsageData, String>(
                  dataSource: _chartData,
                  xValueMapper: (WaterUsageData data, _) => data.time,
                  yValueMapper: (WaterUsageData data, _) => data.volume,
                  color: Colors.blue,
                  width: 4,
                  enableTooltip: false,
                ),
                ScatterSeries<WaterUsageData, String>(
                  dataSource: _chartData,
                  xValueMapper: (WaterUsageData data, _) => data.time,
                  yValueMapper: (WaterUsageData data, _) => data.volume,
                  pointColorMapper: (WaterUsageData data, _) => data.color,
                  enableTooltip: false,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    width: 18,
                    height: 18,
                    shape: DataMarkerType.circle,
                    borderWidth: 0,
                  ),
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    labelAlignment: ChartDataLabelAlignment.top,
                    builder:
                        (
                          dynamic data,
                          dynamic point,
                          dynamic series,
                          int pointIndex,
                          int seriesIndex,
                        ) {
                          final WaterUsageData usageData = data;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: usageData.bgColor,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              usageData.price,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: usageData.color,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                  ),
                ),
                ScatterSeries<WaterUsageData, String>(
                  dataSource: _chartData,
                  xValueMapper: (WaterUsageData data, _) => data.time,
                  yValueMapper: (WaterUsageData data, _) => data.volume,
                  color: Colors.white,
                  enableTooltip: false,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    width: 10,
                    height: 10,
                    shape: DataMarkerType.circle,
                    borderWidth: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}