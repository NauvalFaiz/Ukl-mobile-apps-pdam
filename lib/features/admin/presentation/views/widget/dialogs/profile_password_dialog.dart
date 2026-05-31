import 'package:flutter/material.dart';
import 'package:uklmobileapps/core/utils/admin_validators.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_bloc.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_event.dart';

class ProfilePasswordDialog {
  static void show(
    BuildContext context, {
    required AdminProfileBloc bloc, 
    required int adminId,
    required String currentName,
    required String currentUsername,
    required String currentPhone,
  }) {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah Password Akun', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Password Baru',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (v) => v == null || v.length < 6 ? 'Password minimal 6 karakter' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Konfirmasi Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (v) => AdminValidators.validateConfirmPassword(newPasswordController.text, v),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (!dialogFormKey.currentState!.validate()) return;
              Navigator.pop(dialogContext);
              
              // 2. Gunakan parameter `bloc` untuk mengirim event ganti password
              bloc.add(
                UpdateAdminProfileEvent(
                  id: adminId,
                  name: currentName,
                  phone: currentPhone,
                  username: currentUsername,
                  password: newPasswordController.text,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), foregroundColor: Colors.white),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}