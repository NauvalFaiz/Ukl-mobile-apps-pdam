import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotted/flutter_dotted.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_me_bloc.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_me_event.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_me_state.dart';
import 'package:uklmobileapps/features/bill/data/models/bill_model.dart';
import 'package:uklmobileapps/features/customer/presentation/widgets/CustomTabBar.dart';
import 'package:uklmobileapps/features/customer/presentation/widgets/history_tab_view.dart';
import 'package:uklmobileapps/features/customer/presentation/widgets/unpaid_tab_view.dart';
import 'package:uklmobileapps/shared/widgets/customer_nav_custom.dart';

class CustomerBillPage extends StatefulWidget {
  const CustomerBillPage({super.key});

  @override
  State<CustomerBillPage> createState() => _CustomerBillPageState();
}

class _CustomerBillPageState extends State<CustomerBillPage>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final ScrollController _paymentScrollController = ScrollController();
  int? _selectedUnpaidBillId;
  late TabController _tabController;

  final List _allPayments = [];
  int _paymentPage = 1;
  bool _paymentLoading = false;
  bool _paymentHasMore = true;
  static const int _pageSize = 10;

  CustomerDashboardLoaded? _lastLoadedDashboardState;

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

  // Mengubah menjadi Future<void> agar kompatibel dengan RefreshIndicator
  Future<void> _loadData() async {
    context.read<CustomerMeBloc>().add(FetchDashboardData());
    setState(() {
      _allPayments.clear();
      _paymentPage = 1;
      _paymentHasMore = true;
    });
    await _loadMorePayments();
  }

  Future<void> _loadMorePayments() async {
    if (_paymentLoading || !_paymentHasMore) return;
    setState(() => _paymentLoading = true);
    try {
      final payments = await context
          .read<CustomerMeBloc>()
          .apiService
          .getMyPayments(page: _paymentPage, limit: _pageSize);
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
    bool isSizeValid = true;
    const int maxFileSizeBytes = 10 * 1024 * 1024;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Unggah Bukti\nPembayaran',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF242E49),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'ID Tagihan: ${bill.measurementNumber}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF707E94),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FlutterDotted(
                          color: !isSizeValid
                              ? Colors.red
                              : const Color(0xFFCBD5E1),
                          gap: 4,
                          strokeWidth: 3,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                if (selectedImage != null && isSizeValid) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      selectedImage!,
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ] else ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF3B82F6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add_to_photos_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'PNG/JPG\ntidak lebih dari 10mb',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF475569),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                                if (!isSizeValid) ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Ukuran file terlalu besar! Maksimal 10 MB.',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final picked = await _picker.pickImage(
                                          source: ImageSource.camera,
                                          imageQuality: 80,
                                        );
                                        if (picked != null) {
                                          final file = File(picked.path);
                                          final int fileSize = file
                                              .lengthSync();
                                          setStateDialog(() {
                                            selectedImage = file;
                                            isSizeValid =
                                                fileSize <= maxFileSizeBytes;
                                          });
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Color(0xFF3B82F6),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.camera_alt_outlined,
                                        size: 16,
                                        color: Color(0xFF3B82F6),
                                      ),
                                      label: const Text(
                                        'kamera',
                                        style: TextStyle(
                                          color: Color(0xFF3B82F6),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final picked = await _picker.pickImage(
                                          source: ImageSource.gallery,
                                        );
                                        if (picked != null) {
                                          final file = File(picked.path);
                                          final int fileSize = file
                                              .lengthSync();
                                          setStateDialog(() {
                                            selectedImage = file;
                                            isSizeValid =
                                                fileSize <= maxFileSizeBytes;
                                          });
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Color(0xFF3B82F6),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.upload_outlined,
                                        size: 16,
                                        color: Color(0xFF3B82F6),
                                      ),
                                      label: const Text(
                                        'upload',
                                        style: TextStyle(
                                          color: Color(0xFF3B82F6),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Unggah bukti transfer bank resmi. Pastikan gambar beresolusi jelas dan tidak terpotong.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: selectedImage == null || !isSizeValid
                                ? null
                                : () async {
                                    context.read<CustomerMeBloc>().add(
                                      UploadPaymentProof(
                                        bill.id,
                                        selectedImage!.path,
                                      ),
                                    );

                                    Navigator.pop(ctx);

                                    await Future.delayed(
                                      const Duration(milliseconds: 350),
                                    );

                                    if (mounted) {
                                      _showSuccessDialog();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E293B),
                              disabledBackgroundColor: const Color(0xFFCBD5E1),
                              disabledForegroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Kirim Bukti Pembayaran',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: SvgPicture.asset(
                        "assets/Close.svg",
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFFA4D5E),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog.fullscreen(
          child: Stack(
            children: [
              Positioned.fill(
                child: SvgPicture.asset(
                  'assets/Succes_page.svg',
                  fit: BoxFit.cover,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx, rootNavigator: true).pop();
                        _loadData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1D4ED8),
                        elevation: 2,
                        shadowColor: Colors.black.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Selesai',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text(
          'Tagihan Air Anda',
          style: TextStyle(
            color: Color(0xFF242E49),
            fontWeight: FontWeight.w700,
            fontSize: 22,
            height: 1.27,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<CustomerMeBloc, CustomerMeState>(
        listener: (context, state) {
          if (state is CustomerMeError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is CustomerDashboardLoaded) {
            _lastLoadedDashboardState = state;

            final unpaidBills = state.bills.where((b) => !b.paid).toList();
            if (_selectedUnpaidBillId == null && unpaidBills.isNotEmpty) {
              setState(() {
                _selectedUnpaidBillId = unpaidBills.first.id;
              });
            }
          }
        },
        builder: (context, state) {
          if (state is CustomerMeLoading ||
              state is CustomerMeOperationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerDashboardLoaded ||
              _lastLoadedDashboardState != null) {
            final displayState = state is CustomerDashboardLoaded
                ? state
                : _lastLoadedDashboardState!;

            return Column(
              children: [
                CustomTabBar(tabController: _tabController),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Perubahan Utama: Menambahkan RefreshIndicator untuk fitur seret bawah (Pull-to-Refresh)
                      RefreshIndicator(
                        onRefresh: _loadData,
                        color: const Color(0xFF3B82F6),
                        backgroundColor: Colors.white,
                        child: UnpaidTabView(
                          state: displayState,
                          selectedUnpaidBillId: _selectedUnpaidBillId,
                          onBillSelected: (val) {
                            setState(() {
                              _selectedUnpaidBillId = val;
                            });
                          },
                          onUploadPressed: _showUploadDialog,
                        ),
                      ),
                      HistoryTabView(
                        allPayments: _allPayments,
                        paymentLoading: _paymentLoading,
                        paymentHasMore: _paymentHasMore,
                        scrollController: _paymentScrollController,
                        onRefresh: () async => _loadData(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              CustomTabBar(tabController: _tabController),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      alignment: Alignment.center,
                      child: const Text(
                        'Gagal memuat data atau tidak ada data tagihan.\nTarik ke bawah untuk memuat ulang.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const CustomerNavCustom(currentIndex: 1),
    );
  }
}
