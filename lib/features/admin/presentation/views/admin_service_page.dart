import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uklmobileapps/features/admin/data/service/models/service_model.dart';
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

    final nameController = TextEditingController(
      text: isEditing ? service.name : '',
    );

    final minUsageController = TextEditingController(
      text: isEditing ? service.minUsage.toString() : '',
    );

    final maxUsageController = TextEditingController(
      text: isEditing ? service.maxUsage.toString() : '',
    );

    final priceController = TextEditingController(
      text: isEditing ? service.price.toString() : '',
    );

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.all(24),

          title: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Text(
                  isEditing ? 'Edit\nLayanan' : 'Tambah\nLayanan Baru',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF26314D),
                  ),
                ),
              ),

              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: SvgPicture.asset(
                      "assets/Close.svg",
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFFA4D5E),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 20),

                  const Text(
                    'Nama Layanan',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan Nama Layanan',
                      filled: true,
                      fillColor: const Color(0xFFF3F3F3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Batas Minimal - Maksimal Pemakaian',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: minUsageController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Min -m3',
                            hintStyle: TextStyle(
                              fontFeatures: [FontFeature.superscripts()],
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF3F3F3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: TextFormField(
                          controller: maxUsageController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Max -m3',
                            filled: true,
                            hintStyle: TextStyle(
                              fontFeatures: [FontFeature.superscripts()],
                            ),
                            fillColor: const Color(0xFFF3F3F3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Harga Tarif Layanan',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Masukkan Harga Tarif',
                      filled: true,
                      fillColor: const Color(0xFFF3F3F3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                ],
              ),
            ),
          ),

          actions: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F67FE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final data = {
                        "name": nameController.text,
                        "min_usage": int.tryParse(minUsageController.text) ?? 0,
                        "max_usage": int.tryParse(maxUsageController.text) ?? 0,
                        "price": int.tryParse(priceController.text) ?? 0,
                      };

                      if (isEditing) {
                        context.read<ServiceBloc>().add(
                          UpdateServiceEvent(service.id, data),
                        );
                      } else {
                        context.read<ServiceBloc>().add(
                          CreateServiceEvent(data),
                        );
                      }

                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(
                    isEditing ? 'Update Data Layanan' : 'Simpan Data Layanan',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── Dialog Hapus ───────────────────────────────────────────────
  void _showDeleteConfirm(BuildContext context, ServiceModel service) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Konfirmasi Hapus',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF26314D),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'layanan ${service.name}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Color(0xFF5C6A87)),
              ),

              const SizedBox(height: 20),

              const Text(
                'Tindakan ini permanen dan akan memengaruhi skema tarif pelanggan terkait. Apakah Anda yakin?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xFF5C6A87)),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFA4D5E),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    this.context.read<ServiceBloc>().add(
                      DeleteServiceEvent(service.id),
                    );

                    Navigator.pop(ctx);
                  },
                  child: const Text(
                    'Hapus',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF26314D),
                  ),
                ),
              ),
            ],
          ),
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.all(24),

          title: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Detail Layanan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF26314D),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),

              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () => Navigator.pop(detailCtx),
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: SvgPicture.asset(
                      "assets/Close.svg",
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFFA4D5E),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              const SizedBox(height: 16),

              _infoRow('ID', svc.id.toString()),
              const SizedBox(height: 12),

              _infoRow('Nama', svc.name),
              const SizedBox(height: 12),
              const Text(
                'Batas Minimal - Maksimal Pemakaian',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 44,
                    width: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xffF5F5F5),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text('${svc.minUsage} m³'),
                  ),
                  Container(
                    height: 44,
                    width: 120,
                    alignment: Alignment.center,

                    decoration: BoxDecoration(
                      color: Color(0xffF5F5F5),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text('${svc.maxUsage} m³'),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(
                'Harga Tarif Layanan',
                style: TextStyle(
                  color: Color(0xff242E49),
                  fontSize: 15,
                  fontWeight: FontWeight(600),
                ),
              ),
              SizedBox(height: 5),
              Container(
                height: 44,
                width: double.infinity,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: Color(0xffF5F5F5),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Rp ${_formatRupiah(svc.price)}',
                    style: TextStyle(
                      fontWeight: FontWeight(500),
                      fontSize: 15,
                      color: Color(0xff5D6A85),
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
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
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Kelola Layanan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight(650)),
        ),
      ),
      backgroundColor: Colors.white,
      body: BlocConsumer<ServiceBloc, ServiceState>(
        listener: (context, state) {
          if (state is ServiceOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is ServiceError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          bool isLoading =
              state is ServiceLoading || state is ServiceOperationLoading;
          List<ServiceModel> services = [];

          if (state is ServiceLoaded) {
            services = state.services;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  "Daftar Layanan",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight(560)),
                ),
              ),
              if (isLoading && services.isEmpty)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (services.isEmpty)
                const Expanded(
                  child: Center(child: Text('Tidak ada layanan ditemukan.')),
                )
              else
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final svc = services[index];
                      return GestureDetector(
                        onTap: () {
                          _showServiceDetail(svc);
                        },
                        child: Container(
                          height: 300,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FB),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFD6E4FF)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                svc.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2A44),
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                'Pemakaian: ${svc.minUsage} - ${svc.maxUsage} m³',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF5C6A87),
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                'Tarif: ${_formatRupiah(svc.price)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF5C6A87),
                                ),
                              ),

                              const Spacer(),

                              SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: OutlinedButton(
                                  onPressed: () {
                                    _showServiceForm(svc);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                    side: const BorderSide(color: Colors.blue),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Edit'),
                                      const SizedBox(width: 8),
                                      SvgPicture.asset(
                                        "assets/edit.svg",
                                        width: 18,
                                        height: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: OutlinedButton(
                                  onPressed: () =>
                                      _showDeleteConfirm(context, svc),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Hapus'),
                                      const SizedBox(width: 8),
                                      SvgPicture.asset(
                                        "assets/delate.svg",
                                        width: 18,
                                        height: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
        backgroundColor: Color(0xff0F67FE),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const NavModelCustom(currentIndex: 1),
    );
  }
}
