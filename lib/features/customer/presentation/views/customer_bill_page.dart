import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_me_bloc.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_me_event.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_me_state.dart';
import 'package:uklmobileapps/features/bill/data/models/bill_model.dart';
import 'package:uklmobileapps/shared/widgets/customer_nav_custom.dart';
import 'package:uklmobileapps/shared/widgets/full_screen_image_page.dart';
import 'package:uklmobileapps/core/network/api_constants.dart';

class CustomerBillPage extends StatefulWidget {
  const CustomerBillPage({super.key});

  @override
  State<CustomerBillPage> createState() => _CustomerBillPageState();
}

class _CustomerBillPageState extends State<CustomerBillPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  final ScrollController _paymentScrollController = ScrollController();
  int? _selectedUnpaidBillId;

  // Pagination state for history tab
  final List _allPayments = [];
  int _paymentPage = 1;
  bool _paymentLoading = false;
  bool _paymentHasMore = true;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();

    _paymentScrollController.addListener(() {
      if (_paymentScrollController.position.pixels >=
          _paymentScrollController.position.maxScrollExtent - 200) {
        _loadMorePayments();
      }
    });
  }

  void _loadData() {
    context.read<CustomerMeBloc>().add(FetchDashboardData());
    // Reset and load first page of payments
    setState(() {
      _allPayments.clear();
      _paymentPage = 1;
      _paymentHasMore = true;
    });
    _loadMorePayments();
  }

  Future<void> _loadMorePayments() async {
    if (_paymentLoading || !_paymentHasMore) return;
    setState(() => _paymentLoading = true);
    try {
      final payments = await context.read<CustomerMeBloc>().apiService.getMyPayments(
        page: _paymentPage,
        limit: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _allPayments.addAll(payments);
        _paymentPage++;
        _paymentHasMore = payments.length == _pageSize;
        _paymentLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _paymentLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _paymentScrollController.dispose();
    super.dispose();
  }

  void _showUploadDialog(BillModel bill) async {
    File? selectedImage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Upload Bukti Bayar'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unggah bukti transfer bank resmi. Pastikan gambar jelas dan tidak terpotong.', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  if (selectedImage != null)
                    Image.file(selectedImage!, height: 150, fit: BoxFit.cover)
                  else
                    Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picked = await _picker.pickImage(source: ImageSource.camera);
                          if (picked != null) setStateDialog(() => selectedImage = File(picked.path));
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Kamera'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picked = await _picker.pickImage(source: ImageSource.gallery);
                          if (picked != null) setStateDialog(() => selectedImage = File(picked.path));
                        },
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Galeri'),
                      ),
                    ],
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: selectedImage == null
                      ? null
                      : () {
                          context.read<CustomerMeBloc>().add(UploadPaymentProof(bill.id, selectedImage!.path));
                          Navigator.pop(ctx);
                        },
                  child: const Text('Upload'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, 
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Tagihan & Pembayaran'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Belum Bayar'),
            Tab(text: 'Riwayat'),
          ],
        ),
      ),
      body: BlocConsumer<CustomerMeBloc, CustomerMeState>(
        listener: (context, state) {
          if (state is CustomerMeOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            _loadData();
          } else if (state is CustomerMeError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is CustomerMeLoading || state is CustomerMeOperationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CustomerDashboardLoaded) {
            final unpaidBills = state.bills.where((b) => !b.paid).toList();
            // In a real app we'd fetch payments from state.payments, but DashboardLoaded only has bills and profile.
            // Let's refetch or use a different state strategy. 
            // Wait, CustomerDashboardLoaded doesn't have payments!
            // I should have CustomerMeBloc fetch payments as well in FetchDashboardData, or trigger it.
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              // TAB 1: BELUM BAYAR
              _buildUnpaidTab(state),
              
              // TAB 2: RIWAYAT
              _buildHistoryTab(),
            ],
          );
        },
      ),
      bottomNavigationBar: const CustomerNavCustom(currentIndex: 1),
    );
  }

  Widget _buildUnpaidTab(CustomerMeState state) {
    if (state is CustomerDashboardLoaded) {
      final unpaid = state.bills.where((b) => !b.paid).toList();
      if (unpaid.isEmpty) return const Center(child: Text('Tidak ada tagihan tertunggak.'));
      
      // Select the first unpaid bill by default if not yet selected
      if (_selectedUnpaidBillId == null && unpaid.isNotEmpty) {
        // We use Future.microtask to avoid calling setState during build phase
        Future.microtask(() {
          if (mounted) setState(() => _selectedUnpaidBillId = unpaid.first.id);
        });
      }

      final selectedBill = unpaid.firstWhere(
        (b) => b.id == _selectedUnpaidBillId,
        orElse: () => unpaid.first,
      );

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih Tagihan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedUnpaidBillId,
                  isExpanded: true,
                  hint: const Text('Pilih Bulan Tagihan'),
                  items: unpaid.map((b) {
                    return DropdownMenuItem<int>(
                      value: b.id,
                      child: Text('Bulan ${b.month}/${b.year} - No. ${b.measurementNumber}'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedUnpaidBillId = val;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_selectedUnpaidBillId != null)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Rincian Tagihan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text('Bulan / Tahun: ${selectedBill.month}/${selectedBill.year}'),
                      const SizedBox(height: 4),
                      Text('Nomor Meteran: ${selectedBill.measurementNumber}'),
                      const SizedBox(height: 4),
                      Text('Pemakaian: ${selectedBill.usageValue} m³'),
                      const SizedBox(height: 8),
                      Text('Total Pembayaran: Rp ${selectedBill.price}', 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showUploadDialog(selectedBill),
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Upload Bukti Bayar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 120),
          ],
        ),
      );
    }
    return const Center(child: Text('Memuat data...'));
  }


  Widget _buildHistoryTab() {
    if (_allPayments.isEmpty && _paymentLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_allPayments.isEmpty && !_paymentLoading) {
      return const Center(child: Text('Belum ada riwayat pembayaran.'));
    }

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView.builder(
        controller: _paymentScrollController,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
        itemCount: _allPayments.length + (_paymentLoading || _paymentHasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _allPayments.length) {
            // Footer: loading atau "semua sudah dimuat"
            if (_paymentLoading) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Center(
                child: Text(
                  'Semua riwayat telah ditampilkan',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          final p = _allPayments[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: p.verified ? Colors.green.shade100 : Colors.orange.shade100,
                child: Icon(
                  p.verified ? Icons.verified : Icons.hourglass_top,
                  color: p.verified ? Colors.green : Colors.orange,
                  size: 20,
                ),
              ),
              title: Text('Tagihan #${p.billId}'),
              subtitle: Text('Dibuat: ${p.createdAt}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: p.verified ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  p.verified ? 'Berhasil' : 'Menunggu Admin',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              onTap: () {
                if (p.file.isEmpty) return;
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Bukti Pembayaran'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullScreenImagePage(
                                  imageUrl:
                                      '${ApiConstants.baseUrl}/payment-proof/${Uri.encodeComponent(p.file)}',
                                  tag: 'payment_image_customer_${p.id}',
                                ),
                              ),
                            );
                          },
                          child: Hero(
                            tag: 'payment_image_customer_${p.id}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                '${ApiConstants.baseUrl}/payment-proof/${Uri.encodeComponent(p.file)}',
                                cacheWidth: 800,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const SizedBox(
                                    height: 150,
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 150,
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
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

