import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uklmobileapps/features/admin/presentation/widgets/transaction/admin_transaction_utils.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_event.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_state.dart';
import 'package:uklmobileapps/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:uklmobileapps/features/bill/presentation/bloc/bill_event.dart';
import 'package:uklmobileapps/features/bill/presentation/bloc/bill_state.dart';
import 'package:uklmobileapps/features/bill/data/models/bill_model.dart';
import 'package:uklmobileapps/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:uklmobileapps/features/payment/presentation/bloc/payment_event.dart';
import 'package:uklmobileapps/features/payment/presentation/bloc/payment_state.dart';
import 'package:uklmobileapps/features/payment/data/models/payment_model.dart';
import 'package:uklmobileapps/features/admin/data/datasources/service_api_service.dart';
import 'package:uklmobileapps/features/admin/data/service/models/service_model.dart';
import 'package:uklmobileapps/shared/widgets/nav_model_custom.dart';
import 'package:uklmobileapps/shared/widgets/full_screen_image_page.dart';
import 'package:uklmobileapps/core/network/api_constants.dart';
import 'package:uklmobileapps/features/customer/presentation/widgets/CustomTabBar.dart';
import 'package:flutter_dotted/flutter_dotted.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uklmobileapps/features/admin/presentation/widgets/transaction/admin_bills_tab.dart';
import 'package:uklmobileapps/features/admin/presentation/widgets/transaction/admin_payments_tab.dart';

class AdminTransactionPage extends StatefulWidget {
  final int initialTabIndex;
  const AdminTransactionPage({super.key, this.initialTabIndex = 0});

  @override
  State<AdminTransactionPage> createState() => _AdminTransactionPageState();
}

class _AdminTransactionPageState extends State<AdminTransactionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _billScrollController = ScrollController();
  final ScrollController _paymentScrollController = ScrollController();

  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String _getNamaBulan(int monthNumber) {
    const daftarBulan = [
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
    if (monthNumber >= 1 && monthNumber <= 12) {
      return daftarBulan[monthNumber - 1];
    }
    return monthNumber.toString();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(() {
      setState(() {});
    });
    context.read<BillBloc>().add(FetchAllBills());
    context.read<PaymentBloc>().add(FetchAllPayments());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _billScrollController.dispose();
    _paymentScrollController.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────
  // FORM TAMBAH / EDIT TAGIHAN
  // ────────────────────────────────────────────────────────────
  void _showBillForm([BillModel? bill]) {
    final isEditing = bill != null;
    int? selectedCustomerId = isEditing ? bill.customerId : null;

    // PERBAIKAN LOGIKA: Simpan ID Layanan jika sedang dalam mode edit
    int? selectedServiceId = isEditing ? bill.serviceId : null;
    ServiceModel? selectedService;

    final monthController = TextEditingController(
      text: isEditing ? bill.month.toString() : '',
    );
    final yearController = TextEditingController(
      text: isEditing ? bill.year.toString() : '',
    );
    final measurementController = TextEditingController(
      text: isEditing ? bill.measurementNumber : '',
    );
    final usageController = TextEditingController(
      text: isEditing ? bill.usageValue.toString() : '',
    );
    final priceController = TextEditingController(
      text: isEditing ? bill.price.toString() : '',
    );
    final formKey = GlobalKey<FormState>();

    // Trigger pengambilan data customer sebelum modal muncul
    context.read<CustomerBloc>().add(FetchAllCustomers());

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            void updatePrice() {
              final usageVal = int.tryParse(usageController.text) ?? 0;
              if (selectedService != null && usageVal > 0) {
                priceController.text = (selectedService!.price * usageVal)
                    .toString();
              }
            }

            return AlertDialog(
              title: Text(isEditing ? 'Edit Tagihan' : 'Tambah Tagihan'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Dropdown Customer ───────────────────
                      const Text(
                        'Pilih Customer',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      BlocBuilder<CustomerBloc, CustomerState>(
                        builder: (context, customerState) {
                          if (customerState is CustomerLoading) {
                            return const SizedBox(
                              height: 48,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          final customers = customerState is CustomerLoaded
                              ? customerState.allCustomers
                              : [];

                          if (customers.isEmpty) {
                            return const Text(
                              'Belum ada data customer',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            );
                          }

                          return DropdownButtonFormField<int>(
                            value: selectedCustomerId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            hint: const Text('Pilih Customer'),
                            items: customers.map<DropdownMenuItem<int>>((c) {
                              return DropdownMenuItem<int>(
                                value: c.id,
                                child: Text(
                                  '${c.name} (ID: ${c.id})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setStateDialog(() => selectedCustomerId = val);
                            },
                            validator: (v) =>
                                v == null ? 'Wajib pilih customer' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // ─── Dropdown Service ───────────────────
                      const Text(
                        'Pilih Layanan (Service)',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<List<ServiceModel>>(
                        future: context
                            .read<ServiceApiService>()
                            .getAllServices(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              height: 48,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          final services = snapshot.data ?? [];
                          if (services.isEmpty) {
                            return const Text(
                              'Belum ada data layanan',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            );
                          }

                          // PERBAIKAN LOGIKA: Pasangkan objek service asli saat data Future selesai dimuat
                          if (selectedServiceId != null &&
                              selectedService == null) {
                            final found = services.where(
                              (s) => s.id == selectedServiceId,
                            );
                            if (found.isNotEmpty) {
                              selectedService = found.first;
                            }
                          }

                          return DropdownButtonFormField<int>(
                            value: selectedService?.id,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            hint: const Text('Pilih Layanan'),
                            items: services.map<DropdownMenuItem<int>>((s) {
                              return DropdownMenuItem<int>(
                                value: s.id,
                                child: Text(
                                  '${s.name} — ${_currencyFormat.format(s.price)}/m³',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setStateDialog(() {
                                selectedService = services.firstWhere(
                                  (s) => s.id == val,
                                );
                                selectedServiceId = val;
                                updatePrice();
                              });
                            },
                            validator: (v) =>
                                v == null ? 'Wajib pilih layanan' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // ─── Bulan ───────────────────
                      TextFormField(
                        controller: monthController,
                        decoration: const InputDecoration(
                          labelText: 'Bulan (1-12)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),

                      // ─── Tahun ───────────────────
                      TextFormField(
                        controller: yearController,
                        decoration: const InputDecoration(
                          labelText: 'Tahun',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),

                      // ─── Nomor Meteran ───────────────────
                      TextFormField(
                        controller: measurementController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Meteran',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),

                      // ─── Pemakaian (Usage Value) ───────────────────
                      TextFormField(
                        controller: usageController,
                        decoration: const InputDecoration(
                          labelText: 'Pemakaian (m³)',
                          border: OutlineInputBorder(),
                          suffixText: 'm³',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Wajib diisi' : null,
                        onChanged: (_) {
                          setStateDialog(() {
                            updatePrice();
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      // ─── Harga (Price) ───────────────────
                      TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Total Harga (Rp)',
                          border: OutlineInputBorder(),
                          prefixText: 'Rp ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate() &&
                        selectedCustomerId != null &&
                        selectedService != null) {
                      final usageVal = int.tryParse(usageController.text) ?? 0;
                      final priceVal = int.tryParse(priceController.text) ?? 0;

                      final data = {
                        "customer_id": selectedCustomerId,
                        "service_id": selectedService!.id,
                        "month": int.tryParse(monthController.text) ?? 0,
                        "year": int.tryParse(yearController.text) ?? 0,
                        "measurement_number": measurementController.text,
                        "usage_value": usageVal,
                        "price": priceVal,
                      };

                      if (isEditing) {
                        context.read<BillBloc>().add(
                          UpdateBillEvent(bill.id, data),
                        );
                      } else {
                        context.read<BillBloc>().add(CreateBillEvent(data));
                      }
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────────
  // DETAIL BILL
  // ────────────────────────────────────────────────────────────
  void _showBillDetail(BillModel bill) {
    final paymentState = context.read<PaymentBloc>().state;
    PaymentModel? relatedPayment;
    if (paymentState is PaymentLoaded) {
      try {
        relatedPayment = paymentState.payments.firstWhere(
          (p) => p.billId == bill.id,
        );
      } catch (e) {}
    } else if (paymentState is PaymentLoadingMore) {
      try {
        relatedPayment = paymentState.payments.firstWhere(
          (p) => p.billId == bill.id,
        );
      } catch (e) {}
    }

    String status = 'BELUM LUNAS';
    Color statusColor = const Color(0xFFFA4D5E);
    Color bgColor = const Color(0xFFFFE5E8);
    if (bill.paid) {
      status = 'LUNAS';
      statusColor = const Color(0xFF52B640);
      bgColor = const Color(0xFFE8F6E3);
    } else if (relatedPayment != null && !relatedPayment.verified) {
      status = 'MENUNGGU VERIFIKASI';
      statusColor = const Color(0xFFFACC15);
      bgColor = const Color(0xFFFEF9C3);
    }

    showDialog(
      context: context,
      builder: (detailCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    const Expanded(
                      child: Text(
                        'Info Tagihan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF242E49),
                        ),
                      ),
                    ),
                    if (status != 'BELUM LUNAS')
                      InkWell(
                        onTap: () => Navigator.pop(detailCtx),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFA4D5E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade200),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: Column(
                    children: [
                      _detailRow('ID:', bill.id.toString()),
                      _detailRow('Customer ID:', bill.customerId.toString()),
                      _detailRow(
                        'Bulan/Tahun:',
                        '${getNamaBulan(bill.month)} ${bill.year}',
                      ),
                      _detailRow('No Meteran:', bill.measurementNumber),
                      _detailRow('Pemakaian:', '${bill.usageValue} m³'),
                      _detailRow(
                        'Total Harga:',
                        currencyFormat.format(bill.price),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              flex: 2,
                              child: Text(
                                'Status:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                status,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (status == 'LUNAS' &&
                          relatedPayment != null &&
                          relatedPayment.file.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenImagePage(
                              imageUrl:
                                  '${ApiConstants.baseUrl}/payment-proof/${Uri.encodeComponent(relatedPayment!.file)}',
                              tag: 'payment_image_admin_${relatedPayment!.id}',
                            ),
                          ),
                        );
                      } else if (status == 'MENUNGGU VERIFIKASI' &&
                          relatedPayment != null) {
                        context.read<PaymentBloc>().add(
                          VerifyPaymentEvent(relatedPayment!.id),
                        );
                        Navigator.pop(detailCtx);
                      } else {
                        Navigator.pop(detailCtx);
                      }
                    },
                    child: Text(
                      status == 'LUNAS'
                          ? 'Lihat Bukti Pembayaran'
                          : (status == 'MENUNGGU VERIFIKASI'
                                ? 'Verifikasi'
                                : 'Tutup'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────────
  // DETAIL PAYMENT
  // ────────────────────────────────────────────────────────────
  void _showPaymentDetail(PaymentModel payment) {
    showDialog(
      context: context,
      builder: (detailCtx) {
        return AlertDialog(
          title: const Text('Detail Pembayaran'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Payment ID', '#${payment.id}'),
                _detailRow('Bill ID', '#${payment.billId}'),
                _detailRow('Customer ID', '${payment.customerId}'),
                if (payment.file.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Bukti Pembayaran:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullScreenImagePage(
                            imageUrl:
                                '${ApiConstants.baseUrl}/payment-proof/${Uri.encodeComponent(payment.file)}',
                            tag: 'payment_image_admin_${payment.id}',
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'payment_image_admin_${payment.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          '${ApiConstants.baseUrl}/payment-proof/${Uri.encodeComponent(payment.file)}',
                          cacheWidth: 800,
                          height: 200,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              height: 200,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 200,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Gambar tidak ditemukan',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),
                ] else
                  const Text('File: (Tidak ada file)'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Status: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: payment.verified ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        payment.verified ? 'TERVERIFIKASI' : 'MENUNGGU',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(detailCtx),
              child: const Text('Tutup'),
            ),
            if (!payment.verified)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  context.read<PaymentBloc>().add(
                    VerifyPaymentEvent(payment.id),
                  );
                  Navigator.pop(detailCtx);
                },
                child: const Text(
                  'Verifikasi',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF242E49),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Admin Transaksi',
          style: TextStyle(
            color: Color(0xFF242E49),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<BillBloc, BillState>(
            listener: (context, state) {
              if (state is BillOperationSuccess) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is BillError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          ),
          BlocListener<PaymentBloc, PaymentState>(
            listener: (context, state) {
              if (state is PaymentOperationSuccess) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is PaymentError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          ),
        ],
        child: Column(
          children: [
            CustomTabBar(
              tabController: _tabController,
              tabs: const ['Input Bill', 'Verifikasi Bayar'],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ── TAB 1: BILLS ──────────────────────────────────
                  AdminBillsTab(
                    searchController: _searchController,
                    scrollController: _billScrollController,
                    onShowDetail: _showBillDetail,
                  ),

                  // ── TAB 2: PAYMENTS ──────────────────────────────
                  AdminPaymentsTab(scrollController: _paymentScrollController),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              backgroundColor: Color(0xff0F67FE),
              onPressed: () => _showBillForm(),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Tambah Tagihan',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
      bottomNavigationBar: const NavModelCustom(currentIndex: 3),
    );
  }
}
