import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_bloc.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_event.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_state.dart';
import 'package:uklmobileapps/core/utils/admin_validators.dart';

class AdminChangePasswordPage extends StatefulWidget {
  final int adminId;
  final String currentName;
  final String currentPhone;

  const AdminChangePasswordPage({
    super.key,
    required this.adminId,
    required this.currentName,
    required this.currentPhone,
  });

  @override
  State<AdminChangePasswordPage> createState() => _AdminChangePasswordPageState();
}

class _AdminChangePasswordPageState extends State<AdminChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSavePassword(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<AdminProfileBloc>().add(
          UpdateAdminProfileEvent(
            id: widget.adminId,
            name: widget.currentName,
            phone: widget.currentPhone,
            password: _passwordController.text, username: '',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Password'),
      ),
      body: BlocConsumer<AdminProfileBloc, AdminProfileState>(
        listener: (context, state) {
          if (state is AdminProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password berhasil diperbarui!')),
            );
            Navigator.pop(context); // Kembali ke halaman profil setelah sukses
          } else if (state is AdminProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          bool isLoading = state is AdminProfileUpdating;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Pastikan gunakan password yang kuat dan aman.',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password Baru',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password baru tidak boleh kosong';
                      }
                      if (value.length < 8) {
                        return 'Password minimal harus 8 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Konfirmasi Password Baru',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_reset),
                    ),
                    obscureText: true,
                    validator: (value) => AdminValidators.validateConfirmPassword(
                      _passwordController.text,
                      value,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: isLoading ? null : () => _onSavePassword(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Simpan Password Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}