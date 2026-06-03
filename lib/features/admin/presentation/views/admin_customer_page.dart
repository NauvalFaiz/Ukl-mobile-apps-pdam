import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_event.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_state.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/service/service_bloc.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/service/service_event.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/service/service_state.dart';
import 'package:uklmobileapps/features/customer/data/models/customer_model.dart';
import 'package:uklmobileapps/features/admin/data/service/models/service_model.dart';
import 'package:uklmobileapps/shared/widgets/nav_model_custom.dart';

class AdminCustomerPage extends StatefulWidget {
  const AdminCustomerPage({super.key});

  @override
  State<AdminCustomerPage> createState() => _AdminCustomerPageState();
}

class _AdminCustomerPageState extends State<AdminCustomerPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(FetchAllCustomers());
    context.read<ServiceBloc>().add(FetchAllServices());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildCustomTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Form Tambah / Edit ─────────────────────────────────────────
  void _showCustomerForm([CustomerModel? customer]) {
    final isEditing = customer != null;
    final usernameController = TextEditingController(
      text: isEditing ? (customer.username ?? '') : '',
    );
    final passwordController = TextEditingController();
    final customerNumberController = TextEditingController(
      text: isEditing ? customer.customerNumber : '',
    );
    final nameController = TextEditingController(
      text: isEditing ? customer.name : '',
    );
    final phoneController = TextEditingController(
      text: isEditing ? customer.phone : '',
    );
    final addressController = TextEditingController(
      text: isEditing ? customer.address : '',
    );
    final formKey = GlobalKey<FormState>();

    final serviceState = context.read<ServiceBloc>().state;
    final List<ServiceModel> services = serviceState is ServiceLoaded
        ? serviceState.allServices
        : [];

    int? selectedServiceId = isEditing
        ? customer.serviceId
        : (services.isNotEmpty ? services.first.id : null);

    if (services.isEmpty && !isEditing) {
      context.read<ServiceBloc>().add(FetchAllServices());
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCustomTextField(
                          label: 'Username',
                          hint: 'Masukkan Username',
                          controller: usernameController,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        _buildCustomTextField(
                          label: 'NIK',
                          hint: 'Masukkan NIK',
                          controller: customerNumberController,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        _buildCustomTextField(
                          label: 'Nama',
                          hint: 'Masukkan Nama Lengkap',
                          controller: nameController,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        _buildCustomTextField(
                          label: 'Password',
                          hint: isEditing
                              ? 'Kosongkan jika tidak ingin mengubah password'
                              : 'Masukkan Password',
                          controller: passwordController,
                          obscureText: true,
                          validator: (v) =>
                              !isEditing && (v == null || v.isEmpty)
                              ? 'Wajib diisi'
                              : null,
                        ),
                        _buildCustomTextField(
                          label: 'Nomor Telepon',
                          hint: 'Masukkan Nomor Telepon',
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        _buildCustomTextField(
                          label: 'Alamat',
                          hint: 'Masukkan Alamat',
                          controller: addressController,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),

                        // Layanan Box
                        const Text(
                          'Layanan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        BlocBuilder<ServiceBloc, ServiceState>(
                          builder: (context, svcState) {
                            if (svcState is ServiceLoading) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final List<ServiceModel> loadedServices =
                                svcState is ServiceLoaded
                                ? svcState.allServices
                                : [];

                            if (loadedServices.isEmpty) {
                              return const Text(
                                'Tidak ada layanan tersedia. Tambahkan layanan terlebih dahulu.',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              );
                            }

                            if (selectedServiceId == null ||
                                !loadedServices.any(
                                  (s) => s.id == selectedServiceId,
                                )) {
                              selectedServiceId = loadedServices.first.id;
                            }

                            String selectedServiceName = 'Pilih Layanan';
                            try {
                              selectedServiceName = loadedServices
                                  .firstWhere((s) => s.id == selectedServiceId)
                                  .name;
                            } catch (e) {}

                            return GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (bCtx) {
                                    return SafeArea(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: loadedServices.length,
                                        itemBuilder: (context, index) {
                                          final svc = loadedServices[index];
                                          return ListTile(
                                            title: Text(svc.name),
                                            onTap: () {
                                              setDialogState(
                                                () =>
                                                    selectedServiceId = svc.id,
                                              );
                                              Navigator.pop(bCtx);
                                            },
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            selectedServiceName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Pilih layanan customer',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0D6EFD),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D6EFD),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                final data = <String, dynamic>{
                                  "customer_number":
                                      customerNumberController.text,
                                  "name": nameController.text,
                                  "phone": phoneController.text,
                                  "address": addressController.text,
                                  "service_id": selectedServiceId,
                                };

                                data["username"] = usernameController.text;
                                if (passwordController.text.isNotEmpty) {
                                  data["password"] = passwordController.text;
                                }

                                if (!isEditing) {
                                  context.read<CustomerBloc>().add(
                                    CreateCustomerEvent(data),
                                  );
                                } else {
                                  context.read<CustomerBloc>().add(
                                    UpdateCustomerEvent(customer.id, data),
                                  );
                                }
                                Navigator.pop(ctx);
                              }
                            },
                            child: Text(
                              isEditing
                                  ? 'Simpan Perubahan'
                                  : 'Tambahkan Pelanggan',
                              style: const TextStyle(
                                color: Colors.white,
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
              ),
            );
          },
        );
      },
    );
  }

  // ─── Dialog Hapus ───────────────────────────────────────────────
  void _showDeleteConfirm(CustomerModel customer) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Hapus Pelanggan'),
          content: Text('Yakin ingin menghapus pelanggan "${customer.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                context.read<CustomerBloc>().add(
                  DeleteCustomerEvent(customer.id),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Komponen Helper untuk menyusun baris info di dalam Card
  Widget _infoRowDetail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueGrey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value!,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF334155),
                fontWeight: FontWeight.w600,
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
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0.0,
        centerTitle: true,
        title: const Text(
          'Kelola Pelanggan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight(650)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is CustomerError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          bool isLoading =
              state is CustomerLoading || state is CustomerOperationLoading;
          List<CustomerModel> customers = [];

          if (state is CustomerLoaded) {
            customers = state.customers;
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Cari Pelanggan',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(
                        12.0,
                      ), // Mengatur jarak aman ikon dari tepi border
                      child: SvgPicture.asset(
                        'assets/Search.svg',
                        height: 20, // Ukuran proporsional (bukan 5.5)
                        width: 20,
                        fit: BoxFit
                            .contain, // Memastikan gambar SVG pas di dalam batasan ukuran
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<CustomerBloc>().add(
                          const SearchCustomerByName(''),
                        );
                      },
                    ),
                  ),
                  onChanged: (value) {
                    context.read<CustomerBloc>().add(
                      SearchCustomerByName(value),
                    );
                  },
                ),
              ),
              if (isLoading && customers.isEmpty)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (customers.isEmpty)
                const Expanded(
                  child: Center(child: Text('Tidak ada pelanggan ditemukan.')),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 8,
                      bottom: 100,
                    ),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final c = customers[index];
                      final serviceState = context.read<ServiceBloc>().state;
                      String serviceName = 'Layanan Umum';
                      String servicePriceText = '0';

                      if (serviceState is ServiceLoaded) {
                        final matched = serviceState.allServices.where(
                          (s) => s.id == c.serviceId,
                        );
                        if (matched.isNotEmpty) {
                          serviceName = matched.first.name;
                          // Ambil data price langsung diubah menjadi String rupiah format desimal teratur
                          final rawPrice = matched.first.price ?? 0;
                          servicePriceText = double.parse(rawPrice.toString())
                              .toStringAsFixed(0)
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]}.',
                              );
                        }
                      }

                      return _CustomerCard(
                        c: c,
                        serviceName: serviceName,
                        servicePriceText: servicePriceText,
                        onEdit: () => _showCustomerForm(c),
                        onDelete: () => _showDeleteConfirm(c),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff0F67FE),

        onPressed: () => _showCustomerForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const NavModelCustom(currentIndex: 2),
    );
  }
}

class _CustomerCard extends StatefulWidget {
  final CustomerModel c;
  final String serviceName;
  final String servicePriceText;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CustomerCard({
    required this.c,
    required this.serviceName,
    required this.servicePriceText,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<_CustomerCard> {
  bool _isExpanded = false;

  Widget _infoRowDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueGrey.shade400,
                fontWeight: FontWeight.w500,
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
                color: const Color(0xFF334155),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final serviceName = widget.serviceName;
    final servicePriceText = widget.servicePriceText;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isExpanded ? Colors.blue.shade200 : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    radius: 20,
                    child: Icon(
                      Icons.person,
                      color: Colors.blue.shade600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        if (!_isExpanded) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ID Pelanggan:',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blueGrey.shade400,
                                ),
                              ),
                              Text(
                                c.id.toString(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF334155),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(),
                ),
                _infoRowDetail('Username:', c.username ?? ''),
                _infoRowDetail('NIK:', c.customerNumber),
                _infoRowDetail('ID Pelanggan:', c.id.toString()),
                _infoRowDetail('Nomor Telepon:', c.phone),
                _infoRowDetail('Alamat:', c.address),
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F0FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tarif per Meter Kubik Rp $servicePriceText /m³',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue.shade600,
                          side: BorderSide(color: Colors.blue.shade200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.onDelete,
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Hapus'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade600,
                          side: BorderSide(color: Colors.red.shade200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
