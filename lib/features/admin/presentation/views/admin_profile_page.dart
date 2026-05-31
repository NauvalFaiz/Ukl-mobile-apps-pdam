import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uklmobileapps/features/admin/presentation/views/widget/profile_header.dart' show ProfileHeader;
import 'package:uklmobileapps/features/admin/presentation/views/widget/profile_menu_list.dart';
import 'package:uklmobileapps/shared/widgets/nav_model_custom.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_bloc.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_event.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_state.dart';
import 'package:uklmobileapps/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:uklmobileapps/features/auth/presentation/bloc/auth_event.dart';
import 'package:uklmobileapps/features/auth/presentation/views/login_page.dart';

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
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Admin Profil'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
      ),
      body: BlocConsumer<AdminProfileBloc, AdminProfileState>(
        listener: (context, state) {
          if (state is AdminProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AdminProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
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

          final bool isUpdating = state is AdminProfileUpdating || state is AdminProfileDeleting;
          final String role = (state is AdminProfileLoaded) ? state.role : 'IT Administrator';

          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileHeader(name: _currentName, role: role),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ProfileMenuList(
                    adminId: _adminId,
                    currentName: _currentName,
                    currentPhone: _currentPhone,
                    currentUsername: _currentUsername,
                    isUpdating: isUpdating,
                    onLogoutConfirmed: () {
                      context.read<AuthBloc>().add(AuthLogoutRequested());
                      _navigateToLogin();
                    },
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