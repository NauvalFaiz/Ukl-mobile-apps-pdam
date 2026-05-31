import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_me_bloc.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_me_event.dart';
import 'package:uklmobileapps/features/customer/presentation/bloc/customer_me_state.dart';
import 'package:uklmobileapps/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:uklmobileapps/features/auth/presentation/bloc/auth_event.dart';
import 'package:uklmobileapps/shared/widgets/customer_nav_custom.dart';

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerMeBloc>().add(FetchDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // TETAP ADA: Sesuai keinginan agar navbar menembus body
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profil Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
      body: BlocBuilder<CustomerMeBloc, CustomerMeState>(
        builder: (context, state) {
          if (state is CustomerMeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CustomerDashboardLoaded) {
            final profile = state.profile;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person, size: 50),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildProfileItem('Nama Lengkap', profile.name),
                  _buildProfileItem('Nomor Telepon', profile.phone),
                  _buildProfileItem('Alamat', profile.address),
                  _buildProfileItem('Nomor Pelanggan (NIK)', profile.customerNumber),
                  
                  const SizedBox(height: 32),
                  const Text('Detail Layanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // In a real scenario with nested relation, profile.service would exist.
                  // For now, we only have serviceId in CustomerModel.
                  // We'll show the Service ID.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Paket Layanan', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('ID Layanan: ${profile.serviceId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        // If we had service object:
                        // Text(profile.service?.name ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        // const SizedBox(height: 12),
                        // const Text('Tarif per Meter Kubik', style: TextStyle(color: Colors.grey)),
                        // const SizedBox(height: 4),
                        // Text('Rp ${profile.service?.price ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                  // SIZEDBOX PENAHAN TETAP ADA: Menghindari ketutupan navbar akibat extendBody
                  const SizedBox(height: 120),
                ],
              ),
            );
          }
          if (state is CustomerMeError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Memuat data...'));
        },
      ),
      bottomNavigationBar: const CustomerNavCustom(currentIndex: 2),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
          const Divider(),
        ],
      ),
    );
  }
}
