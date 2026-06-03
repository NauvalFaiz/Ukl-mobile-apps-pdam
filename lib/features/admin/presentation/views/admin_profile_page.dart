import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uklmobileapps/shared/widgets/nav_model_custom.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_bloc.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_event.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_state.dart';
import 'package:uklmobileapps/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:uklmobileapps/features/auth/presentation/bloc/auth_event.dart';
import 'package:uklmobileapps/features/auth/presentation/views/login_page.dart';
import 'package:uklmobileapps/features/admin/presentation/views/widget/dialogs/profile_action_dialog.dart';
import 'package:uklmobileapps/features/admin/presentation/views/widget/dialogs/profile_password_dialog.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  int? _adminId;
  String _currentName = '';
  String _currentPhone = '';
  String _currentUsername = '';

  @override
  void initState() {
    super.initState();
    context.read<AdminProfileBloc>().add(FetchAdminProfileEvent());
  }

  void _navigateToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: BlocConsumer<AdminProfileBloc, AdminProfileState>(
        listener: (context, state) {
          if (state is AdminProfileError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AdminProfileUpdateSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AdminProfileLoaded) {
            _adminId = state.id;
            _currentName = state.name;
            _currentPhone = state.phone;
            _currentUsername = state.username;
          } else if (state is AdminProfileDeleteSuccess) {
            context.read<AuthBloc>().add(AuthLogoutRequested());
            _navigateToLogin();
          }
        },
        builder: (context, state) {
          if (state is AdminProfileInitial || state is AdminProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final bool isUpdating =
              state is AdminProfileUpdating || state is AdminProfileDeleting;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // PERBAIKAN: Menggunakan Stack untuk mewadahi Positioned banner SVG
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      height: 168,
                      width: double.infinity,
                      child: SvgPicture.asset(
                        'assets/profiladmin.svg',
                        fit: BoxFit
                            .cover, // Menggunakan cover agar memenuhi lebar secara proporsional
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Username',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF242E49),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _currentUsername.isNotEmpty ? _currentUsername : '-',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF242E49),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '****************',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Icon(
                              Icons.visibility_off,
                              color: Color(0xFF64748B),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: isUpdating || _adminId == null
                              ? null
                              : () {
                                  ProfilePasswordDialog.show(
                                    context,
                                    bloc: context.read<AdminProfileBloc>(),
                                    adminId: _adminId!,
                                    currentName: _currentName,
                                    currentUsername: _currentUsername,
                                    currentPhone: _currentPhone,
                                  );
                                },
                          child: const Text(
                            'Ganti Password',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                      const Text(
                        'Keluar Akun',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF242E49),
                        ),
                      ),
                      const SizedBox(height: 16),

                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFA4D5E)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: isUpdating
                            ? null
                            : () {
                                ProfileActionDialog.showLogoutConfirmation(
                                  context,
                                  onConfirm: () {
                                    context.read<AuthBloc>().add(
                                      AuthLogoutRequested(),
                                    );
                                    _navigateToLogin();
                                  },
                                );
                              },
                        child: const Text(
                          'Keluar Akun',
                          style: TextStyle(
                            color: Color(0xFFFA4D5E),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFA4D5E)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: isUpdating || _adminId == null
                            ? null
                            : () {
                                ProfileActionDialog.showDeleteConfirmation(
                                  context,
                                  bloc: context.read<AdminProfileBloc>(),
                                  adminId: _adminId!,
                                );
                              },
                        child: const Text(
                          'Hapus Akun',
                          style: TextStyle(
                            color: Color(0xFFFA4D5E),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 120,
                      ), 
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const NavModelCustom(currentIndex: 4),
    );
  }
}
