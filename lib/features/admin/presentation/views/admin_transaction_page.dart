import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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

class AdminTransactionPage extends StatefulWidget {
  const AdminTransactionPage({super.key});

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<BillBloc>().add(FetchAllBills());
    context.read<PaymentBloc>().add(FetchAllPayments());

    _billScrollController.addListener(() {
      if (_billScrollController.position.pixels >=
          _billScrollController.position.maxScrollExtent - 200) {
        context.read<BillBloc>().add(FetchMoreBills());
      }
    });

    _paymentScrollController.addListener(() {
      if (_paymentScrollController.position.pixels >=
          _paymentScrollController.position.maxScrollExtent - 200) {
        context.read<PaymentBloc>().add(FetchMorePayments());
      }
    });
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
  // FORM TAMBAH / EDIT TAGIHAN dengan kalkulasi harga otomatis
  // ────────────────────────────────────────────────────────────
  void _showBillForm([BillModel? bill]) {
    final isEditing = bill != null;
    int? selectedCustomerId = isEditing ? bill.customerId : null;
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

    void _updatePrice() {
      final usageVal = int.tryParse(usageController.text) ?? 0;
      if (selectedService != null && usageVal > 0) {
        priceController.text = (selectedService!.price * usageVal).toString();
      }
    }

    context.read<CustomerBloc>().add(FetchAllCustomers());

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
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
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                            validator: (v) => v == null ? 'Wajib pilih customer' : null,
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
                        future: context.read<ServiceApiService>().getAllServices(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(
                              height: 48,
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            );
                          }
                          final services = snapshot.data ?? [];
                          if (services.isEmpty) {
                            return const Text(
                              'Belum ada data layanan',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            );
                          }
                          return DropdownButtonFormField<int>(
                            value: selectedService?.id,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                selectedService = services.firstWhere((s) => s.id == val);
                                _updatePrice();
                              });
                            },
                            validator: (v) => v == null ? 'Wajib pilih layanan' : null,
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
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),

                      // ─── Tahun ───────────────────
                      TextFormField(
                        controller: yearController,
                        decoration: const InputDecoration(
                          labelText: 'Tahun (contoh: 2025)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
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
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),

                      // ─── Usage Value ───────────────────
                      TextFormField(
                        controller: usageController,
                        decoration: const InputDecoration(
                          labelText: 'Pemakaian (m³)',
                          border: OutlineInputBorder(),
                          suffixText: 'm³',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        onChanged: (_) {
                          _updatePrice();
                          setStateDialog(() {}); 
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
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
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
                        context.read<BillBloc>().add(UpdateBillEvent(bill.id, data));
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
    showDialog(
      context: context,
      builder: (detailCtx) {
        return AlertDialog(
          title: const Text('Detail Tagihan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('ID', '#${bill.id}'),
              _detailRow('Customer ID', '${bill.customerId}'),
              _detailRow('Bulan/Tahun', '${bill.month}/${bill.year}'),
              _detailRow('No Meteran', bill.measurementNumber),
              _detailRow('Pemakaian', '${bill.usageValue} m³'),
              _detailRow('Total Harga', _currencyFormat.format(bill.price)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: bill.paid ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      bill.paid ? 'LUNAS' : 'BELUM LUNAS',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(detailCtx),
              child: const Text('Tutup'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(detailCtx);
                _showBillForm(bill);
              },
              child: const Text('Edit'),
            ),
          ],
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
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('Gambar tidak ditemukan',
                                      style: TextStyle(color: Colors.grey)),
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
                    const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: payment.verified ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        payment.verified ? 'TERVERIFIKASI' : 'MENUNGGU',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
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
                  context.read<PaymentBloc>().add(VerifyPaymentEvent(payment.id));
                  Navigator.pop(detailCtx);
                },
                child: const Text('Verifikasi', style: TextStyle(color: Colors.white)),
              ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Admin Transaksi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Bills (Tagihan)'),
            Tab(text: 'Payments (Pembayaran)'),
          ],
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<BillBloc, BillState>(
            listener: (context, state) {
              if (state is BillOperationSuccess) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is BillError) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          ),
          BlocListener<PaymentBloc, PaymentState>(
            listener: (context, state) {
              if (state is PaymentOperationSuccess) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is PaymentError) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          ),
        ],
        child: TabBarView(
          controller: _tabController,
          children: [
            // ── TAB 1: BILLS ──────────────────────────────────
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Cari ID / No. Meteran...',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<BillBloc>().add(const SearchBillById(''));
                        },
                      ),
                    ),
                    onChanged: (value) {
                      context.read<BillBloc>().add(SearchBillById(value));
                    },
                  ),
                ),
                Expanded(
                  child: BlocBuilder<BillBloc, BillState>(
                    builder: (context, state) {
                      if (state is BillLoading || state is BillOperationLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      List<BillModel> bills = [];
                      bool isLoadingMore = false;
                      bool hasReachedMax = false;

                      if (state is BillLoaded) {
                        bills = state.bills;
                        hasReachedMax = state.hasReachedMax;
                      } else if (state is BillLoadingMore) {
                        bills = state.bills;
                        isLoadingMore = true;
                      }

                      if (bills.isEmpty) {
                        return const Center(child: Text('Tidak ada tagihan'));
                      }

                      return ListView.builder(
                        controller: _billScrollController,
                        itemCount: bills.length + (isLoadingMore ? 1 : 0) + (hasReachedMax && bills.isNotEmpty ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (isLoadingMore && index == bills.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (hasReachedMax && index == bills.length) {
                            return const Padding(
                              padding: EdgeInsets.all(12),
                              child: Center(
                                child: Text(
                                  'Semua data telah ditampilkan',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            );
                          }
                          final b = bills[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: b.paid ? Colors.green.shade100 : Colors.orange.shade100,
                                child: Icon(
                                  b.paid ? Icons.check_circle : Icons.warning_amber,
                                  color: b.paid ? Colors.green : Colors.orange,
                                ),
                              ),
                              title: Text('Bill #${b.id} — Customer: ${b.customerId}'),
                              subtitle: Text(
                                'Bulan: ${b.month}/${b.year} | ${_currencyFormat.format(b.price)}',
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                              onTap: () => _showBillDetail(b),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            // ── TAB 2: PAYMENTS ──────────────────────────────
            BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, state) {
                if (state is PaymentLoading || state is PaymentOperationLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<PaymentModel> payments = [];
                bool isLoadingMore = false;
                bool hasReachedMax = false;

                if (state is PaymentLoaded) {
                  payments = state.payments;
                  hasReachedMax = state.hasReachedMax;
                } else if (state is PaymentLoadingMore) {
                  payments = state.payments;
                  isLoadingMore = true;
                }

                if (payments.isEmpty) {
                  return const Center(child: Text('Tidak ada data pembayaran'));
                }

                return ListView.builder(
                  controller: _paymentScrollController,
                  itemCount: payments.length + (isLoadingMore ? 1 : 0) + (hasReachedMax && payments.isNotEmpty ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (isLoadingMore && index == payments.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (hasReachedMax && index == payments.length) {
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(
                          child: Text(
                            'Semua data telah ditampilkan',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }
                    final p = payments[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: p.verified ? Colors.green.shade100 : Colors.orange.shade100,
                          child: Icon(
                            p.verified ? Icons.verified : Icons.hourglass_top,
                            color: p.verified ? Colors.green : Colors.orange,
                          ),
                        ),
                        title: Text('Payment #${p.id} (Bill: ${p.billId})'),
                        subtitle: Text(
                          p.verified ? 'TERVERIFIKASI' : 'MENUNGGU VERIFIKASI',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () => _showPaymentDetail(p),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBillForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tagihan'),
      ),
      bottomNavigationBar: const NavModelCustom(currentIndex: 3),
    );
  }
}
