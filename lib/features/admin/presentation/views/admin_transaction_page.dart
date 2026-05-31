import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<BillBloc>().add(FetchAllBills());
    context.read<PaymentBloc>().add(FetchAllPayments());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showBillForm([BillModel? bill]) {
    final isEditing = bill != null;
    int? selectedCustomerId = isEditing ? bill.customerId : null;
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
    final formKey = GlobalKey<FormState>();

    // Pastikan data customer sudah di-load
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
                      TextFormField(
                        controller: yearController,
                        decoration: const InputDecoration(
                          labelText: 'Tahun (e.g. 2027)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
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
                      TextFormField(
                        controller: usageController,
                        decoration: const InputDecoration(
                          labelText: 'Usage Value (m³)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
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
                        selectedCustomerId != null) {
                      final data = {
                        "customer_id": selectedCustomerId,
                        "month": int.tryParse(monthController.text) ?? 0,
                        "year": int.tryParse(yearController.text) ?? 0,
                        "measurement_number": measurementController.text,
                        "usage_value": int.tryParse(usageController.text) ?? 0,
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

  void _showDeleteBillConfirm(BuildContext parentCtx, BillModel bill) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Hapus Tagihan'),
          content: Text('Yakin ingin menghapus tagihan ID ${bill.id}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                context.read<BillBloc>().add(DeleteBillEvent(bill.id));
                Navigator.pop(ctx);
                Navigator.pop(parentCtx);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

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
              Text('ID: ${bill.id}'),
              Text('Customer ID: ${bill.customerId}'),
              Text('Bulan/Tahun: ${bill.month}/${bill.year}'),
              Text('No Meteran: ${bill.measurementNumber}'),
              Text('Pemakaian: ${bill.usageValue} m³'),
              Text('Total Harga: Rp ${bill.price}'),
              Text('Status: ${bill.paid ? "LUNAS" : "BELUM LUNAS"}'),
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
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => _showDeleteBillConfirm(detailCtx, bill),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentDetail(PaymentModel payment) {
    showDialog(
      context: context,
      builder: (detailCtx) {
        return AlertDialog(
          title: const Text('Detail Pembayaran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment ID: ${payment.id}'),
              Text('Bill ID: ${payment.billId}'),
              Text('Customer ID: ${payment.customerId}'),
              if (payment.file.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Bukti Pembayaran:'),
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
                Text('File: (Tidak ada file)'),
              const SizedBox(height: 8),
              Text(
                payment.verified
                    ? 'Status: TERVERIFIKASI'
                    : 'Status: MENUNGGU VERIFIKASI',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: payment.verified ? Colors.green : Colors.orange,
                ),
              ),
            ],
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
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                context.read<PaymentBloc>().add(DeletePaymentEvent(payment.id));
                Navigator.pop(detailCtx);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
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
        child: TabBarView(
          controller: _tabController,
          children: [
            // TAB 1: BILLS
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
                          context.read<BillBloc>().add(
                            const SearchBillById(''),
                          );
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
                      if (state is BillLoading ||
                          state is BillOperationLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is BillLoaded) {
                        if (state.bills.isEmpty) {
                          return const Center(child: Text('Tidak ada tagihan'));
                        }
                        return ListView.builder(
                          itemCount: state.bills.length,
                          itemBuilder: (context, index) {
                            final b = state.bills[index];
                            return ListTile(
                              title: Text(
                                'Bill #${b.id} - Customer: ${b.customerId}',
                              ),
                              subtitle: Text(
                                'Bulan: ${b.month}/${b.year} | Rp ${b.price}',
                              ),
                              trailing: Icon(
                                b.paid ? Icons.check_circle : Icons.warning,
                                color: b.paid ? Colors.green : Colors.orange,
                              ),
                              onTap: () => _showBillDetail(b),
                            );
                          },
                        );
                      }
                      return const Center(child: Text('Error memuat tagihan'));
                    },
                  ),
                ),
              ],
            ),

            // TAB 2: PAYMENTS
            BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, state) {
                if (state is PaymentLoading ||
                    state is PaymentOperationLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is PaymentLoaded) {
                  if (state.payments.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada data pembayaran'),
                    );
                  }
                  return ListView.builder(
                    itemCount: state.payments.length,
                    itemBuilder: (context, index) {
                      final p = state.payments[index];
                      return ListTile(
                        leading: const Icon(Icons.receipt),
                        title: Text('Payment #${p.id} (Bill: ${p.billId})'),
                        subtitle: Text(
                          p.verified ? 'TERVERIFIKASI' : 'MENUNGGU VERIFIKASI',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () => _showPaymentDetail(p),
                      );
                    },
                  );
                }
                return const Center(child: Text('Error memuat pembayaran'));
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBillForm(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const NavModelCustom(currentIndex: 3),
    );
  }
}
