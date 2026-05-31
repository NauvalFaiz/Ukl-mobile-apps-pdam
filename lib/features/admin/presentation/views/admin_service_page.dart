import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uklmobileapps/features/service/data/models/service_model.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/service/service_bloc.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/service/service_event.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/service/service_state.dart';
import 'package:uklmobileapps/shared/widgets/nav_model_custom.dart';

class AdminServicePage extends StatefulWidget {
  const AdminServicePage({super.key});

  @override
  State<AdminServicePage> createState() => _AdminServicePageState();
}

class _AdminServicePageState extends State<AdminServicePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ServiceBloc>().add(FetchAllServices());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─── Form Tambah / Edit ─────────────────────────────────────────
  void _showServiceForm([ServiceModel? service]) {
    final isEditing = service != null;
    final nameController = TextEditingController(text: isEditing ? service.name : '');
    final minUsageController = TextEditingController(text: isEditing ? service.minUsage.toString() : '');
    final maxUsageController = TextEditingController(text: isEditing ? service.maxUsage.toString() : '');
    final priceController = TextEditingController(text: isEditing ? service.price.toString() : '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Layanan' : 'Tambah Layanan'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama Layanan'),
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: minUsageController,
                    decoration: const InputDecoration(labelText: 'Min Usage'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: maxUsageController,
                    decoration: const InputDecoration(labelText: 'Max Usage'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
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
                  final data = {
                    "name": nameController.text,
                    "min_usage": int.tryParse(minUsageController.text) ?? 0,
                    "max_usage": int.tryParse(maxUsageController.text) ?? 0,
                    "price": int.tryParse(priceController.text) ?? 0,
                  };

                  if (isEditing) {
                    context.read<ServiceBloc>().add(UpdateServiceEvent(service.id, data));
                  } else {
                    context.read<ServiceBloc>().add(CreateServiceEvent(data));
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
  }

  // ─── Dialog Hapus ───────────────────────────────────────────────
  void _showDeleteConfirm(BuildContext parentCtx, ServiceModel service) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Hapus Layanan'),
          content: Text('Yakin ingin menghapus layanan "${service.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                context.read<ServiceBloc>().add(DeleteServiceEvent(service.id));
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

  // ─── Dialog Detail Service (klik item) ─────────────────────────
  void _showServiceDetail(ServiceModel svc) {
    showDialog(
      context: context,
      builder: (detailCtx) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.info_outline),
              const SizedBox(width: 8),
              Expanded(child: Text(svc.name, overflow: TextOverflow.ellipsis)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow('ID Layanan', svc.id.toString()),
              const Divider(),
              _infoRow('Nama', svc.name),
              const Divider(),
              _infoRow('Min Pemakaian', '${svc.minUsage} m³'),
              const Divider(),
              _infoRow('Max Pemakaian', '${svc.maxUsage} m³'),
              const Divider(),
              _infoRow('Harga', 'Rp ${_formatRupiah(svc.price)}'),
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
                _showServiceForm(svc);
              },
              child: const Text('Edit'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => _showDeleteConfirm(detailCtx, svc),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatRupiah(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Admin Service'),
      ),
      body: BlocConsumer<ServiceBloc, ServiceState>(
        listener: (context, state) {
          if (state is ServiceOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is ServiceError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          bool isLoading = state is ServiceLoading || state is ServiceOperationLoading;
          List<ServiceModel> services = [];

          if (state is ServiceLoaded) {
            services = state.services;
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Cari Layanan...',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<ServiceBloc>().add(const SearchServiceByName(''));
                      },
                    ),
                  ),
                  onChanged: (value) {
                    context.read<ServiceBloc>().add(SearchServiceByName(value));
                  },
                ),
              ),
              if (isLoading && services.isEmpty)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (services.isEmpty)
                const Expanded(child: Center(child: Text('Tidak ada layanan ditemukan.')))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final svc = services[index];
                      return ListTile(
                        title: Text(svc.name),
                        subtitle: Text('ID: ${svc.id} | Min: ${svc.minUsage} | Max: ${svc.maxUsage} | Rp ${_formatRupiah(svc.price)}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        onTap: () => _showServiceDetail(svc),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showServiceForm(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const NavModelCustom(currentIndex: 1),
    );
  }
}
