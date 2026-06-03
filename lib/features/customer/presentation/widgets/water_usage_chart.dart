import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:uklmobileapps/features/customer/presentation/views/customer_dashboard.dart';

// Asumsi BillModel diimport dari project Anda
// import 'path_to_bill_model/bill_model.dart'; 

class WaterUsageChartPage extends StatefulWidget {
  final List<dynamic> bills; // Ganti dynamic dengan BillModel Anda
  const WaterUsageChartPage({super.key, required this.bills});

  @override
  State<WaterUsageChartPage> createState() => _WaterUsageChartPageState();
}

class _WaterUsageChartPageState extends State<WaterUsageChartPage> {
  late List<WaterUsageData> _chartData;
  int _selectedFilterIndex = 2; // Default: 'Semua'

  final ZoomPanBehavior _zoomPanBehavior = ZoomPanBehavior(
    enablePanning: true,
    zoomMode: ZoomMode.x,
  );

  late final TooltipBehavior _tooltipBehavior = TooltipBehavior(
    enable: true,
    color: Colors.transparent,
    elevation: 0,
    builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
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
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    if (month >= 1 && month <= 12) return monthNames[month - 1];
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

    List<dynamic> filteredBills = List.from(widget.bills);

    if (_selectedFilterIndex == 0) {
      if (filteredBills.length > 6) {
        filteredBills = filteredBills.sublist(filteredBills.length - 6);
      }
    } else if (_selectedFilterIndex == 1) {
      if (filteredBills.length > 12) {
        filteredBills = filteredBills.sublist(filteredBills.length - 12);
      }
    }

    if (filteredBills.isEmpty) {
      _chartData = [];
      return;
    }

    double maxVol = filteredBills.map((e) => e.usageValue.toDouble()).reduce((a, b) => a > b ? a : b);
    double minVol = filteredBills.map((e) => e.usageValue.toDouble()).reduce((a, b) => a < b ? a : b);

    _chartData = filteredBills.map((bill) {
      String timeStr = '${_getMonthName(bill.month)} ${bill.year}';
      double vol = bill.usageValue.toDouble();

      Color textColor = const Color(0xFF2196F3);
      Color bgColor = const Color(0xFFD2E4FF);

      if (vol == maxVol && maxVol > 0) {
        textColor = const Color(0xFFFA4A5B); 
        bgColor = const Color(0xFFFFD7DD);
      } else if (vol == minVol && minVol < maxVol) {
        textColor = const Color(0xFFFFB300); 
        bgColor = const Color(0xFFFFF9D2);
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
          height: 340,
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
              margin: const EdgeInsets.only(top: 40, bottom: 10, left: 10, right: 20),
              series: <CartesianSeries>[
                SplineAreaSeries<WaterUsageData, String>(
                  dataSource: _chartData,
                  xValueMapper: (WaterUsageData data, _) => data.time,
                  yValueMapper: (WaterUsageData data, _) => data.volume,
                  borderColor: Colors.transparent,
                  borderWidth: 0,
                  enableTooltip: false,
                  gradient: LinearGradient(
                    colors: [Colors.blue.withOpacity(0.3), Colors.blue.withOpacity(0.0)],
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
                    builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
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