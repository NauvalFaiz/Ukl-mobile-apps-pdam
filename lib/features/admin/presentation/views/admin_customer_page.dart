import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    // Pastikan data services sudah ter-load untuk dropdown
    context.read<ServiceBloc>().add(FetchAllServices());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─── Form Tambah / Edit ─────────────────────────────────────────
  void _showCustomerForm([CustomerModel? customer]) {
    final isEditing = customer != null;
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final customerNumberController = TextEditingController(text: isEditing ? customer.customerNumber : '');
    final nameController = TextEditingController(text: isEditing ? customer.name : '');
    final phoneController = TextEditingController(text: isEditing ? customer.phone : '');
    final addressController = TextEditingController(text: isEditing ? customer.address : '');
    final formKey = GlobalKey<FormState>();

    // Ambil daftar services dari state ServiceBloc yang sudah ada
    final serviceState = context.read<ServiceBloc>().state;
    final List<ServiceModel> services = serviceState is ServiceLoaded
        ? serviceState.allServices
        : [];

    // Nilai awal untuk dropdown
    int? selectedServiceId = isEditing ? customer.serviceId : (services.isNotEmpty ? services.first.id : null);

    // Jika services masih kosong, fetch dulu lalu tunggu
    if (services.isEmpty && !isEditing) {
      context.read<ServiceBloc>().add(FetchAllServices());
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Pelanggan' : 'Tambah Pelanggan'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Username & Password hanya saat Create
                      if (!isEditing) ...[
                        TextFormField(
                          controller: usernameController,
                          decoration: const InputDecoration(labelText: 'Username'),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        TextFormField(
                          controller: passwordController,
                          decoration: const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                      ],
                      TextFormField(
                        controller: customerNumberController,
                        decoration: const InputDecoration(labelText: 'Nomor Pelanggan (NIK)'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(labelText: 'Alamat'),
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 8),
                      // ─── Dropdown Service ID (reaktif ke ServiceBloc) ───
                      BlocBuilder<ServiceBloc, ServiceState>(
                        builder: (context, svcState) {
                          if (svcState is ServiceLoading) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final List<ServiceModel> loadedServices = svcState is ServiceLoaded
                              ? svcState.allServices
                              : [];

                          if (loadedServices.isEmpty) {
                            return const Text(
                              'Tidak ada layanan tersedia. Tambahkan layanan terlebih dahulu.',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            );
                          }

                          // Pastikan selectedServiceId valid
                          if (selectedServiceId == null || !loadedServices.any((s) => s.id == selectedServiceId)) {
                            selectedServiceId = loadedServices.first.id;
                          }

                          return DropdownButtonFormField<int>(
                            value: selectedServiceId,
                            isExpanded: true,
                            decoration: const InputDecoration(labelText: 'Pilih Layanan'),
                            items: loadedServices.map((svc) {
                              return DropdownMenuItem<int>(
                                value: svc.id,
                                child: Text(
                                  '${svc.name} (ID: ${svc.id})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setDialogState(() => selectedServiceId = val);
                            },
                            validator: (v) => v == null ? 'Pilih layanan' : null,
                          );
                        },
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
                    if (formKey.currentState!.validate()) {
                      final data = <String, dynamic>{
                        "customer_number": customerNumberController.text,
                        "name": nameController.text,
                        "phone": phoneController.text,
                        "address": addressController.text,
                        "service_id": selectedServiceId,
                      };

                      if (!isEditing) {
                        data["username"] = usernameController.text;
                        data["password"] = passwordController.text;
                        context.read<CustomerBloc>().add(CreateCustomerEvent(data));
                      } else {
                        context.read<CustomerBloc>().add(UpdateCustomerEvent(customer.id, data));
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

  // ─── Dialog Hapus ───────────────────────────────────────────────
  void _showDeleteConfirm(BuildContext parentCtx, CustomerModel customer) {
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
                context.read<CustomerBloc>().add(DeleteCustomerEvent(customer.id));
                Navigator.pop(ctx);       // tutup dialog konfirmasi
                Navigator.pop(parentCtx); // tutup dialog detail
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ─── Dialog Detail Customer (klik item) ────────────────────────
  void _showCustomerDetail(CustomerModel c) {
    // Ambil nama layanan dari ServiceBloc
    final serviceState = context.read<ServiceBloc>().state;
    String serviceName = 'ID: ${c.serviceId}';
    if (serviceState is ServiceLoaded) {
      final matched = serviceState.allServices.where((s) => s.id == c.serviceId);
      if (matched.isNotEmpty) serviceName = '${matched.first.name} (ID: ${c.serviceId})';
    }

    showDialog(
      context: context,
      builder: (detailCtx) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.person),
              const SizedBox(width: 8),
              Expanded(child: Text(c.name, overflow: TextOverflow.ellipsis)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow('ID', c.id.toString()),
              const Divider(),
              _infoRow('NIK', c.customerNumber),
              const Divider(),
              _infoRow('Nama', c.name),
              const Divider(),
              _infoRow('Telepon', c.phone),
              const Divider(),
              _infoRow('Alamat', c.address),
              const Divider(),
              _infoRow('Layanan', serviceName),
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
                _showCustomerForm(c);
              },
              child: const Text('Edit'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => _showDeleteConfirm(detailCtx, c),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Admin Customer'),
      ),
      body: BlocConsumer<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is CustomerError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          bool isLoading = state is CustomerLoading || state is CustomerOperationLoading;
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
                    labelText: 'Cari Pelanggan (Nama / NIK)...',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<CustomerBloc>().add(const SearchCustomerByName(''));
                      },
                    ),
                  ),
                  onChanged: (value) {
                    context.read<CustomerBloc>().add(SearchCustomerByName(value));
                  },
                ),
              ),
              if (isLoading && customers.isEmpty)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (customers.isEmpty)
                const Expanded(child: Center(child: Text('Tidak ada pelanggan ditemukan.')))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final c = customers[index];

                      // Ambil nama layanan dari ServiceBloc
                      final serviceState = context.read<ServiceBloc>().state;
                      String serviceName = 'Service ID: ${c.serviceId}';
                      if (serviceState is ServiceLoaded) {
                        final matched = serviceState.allServices.where((s) => s.id == c.serviceId);
                        if (matched.isNotEmpty) serviceName = matched.first.name;
                      }

                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(c.name),
                        subtitle: Text('NIK: ${c.customerNumber} | $serviceName'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        onTap: () => _showCustomerDetail(c),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCustomerForm(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const NavModelCustom(currentIndex: 2),
    );
  }
}
