import 'package:flutter/material.dart';
import 'package:uklmobileapps/core/utils/admin_validators.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_bloc.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_event.dart';

class ProfileEditDialog {
  static void showUsername(
    BuildContext context, {
    required AdminProfileBloc bloc, 
    required int adminId,
    required String currentUsername,
    required String currentName,
    required String currentPhone,
  }) {
    final usernameController = TextEditingController(text: currentUsername);
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah Username', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Form(
          key: dialogFormKey,
          child: TextFormField(
            controller: usernameController,
            decoration: const InputDecoration(
              labelText: 'Username Baru',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_circle_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Username tidak boleh kosong';
              if (value.trim().length < 4) return 'Username minimal harus 4 karakter';
              return null;
            },
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
              
              // Menggunakan instance bloc dari parameter
              bloc.add(
                UpdateAdminProfileEvent(
                  id: adminId,
                  name: currentName,
                  phone: currentPhone,
                  username: usernameController.text.trim(),
                  password: null,
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

  // ─── B. DIALOG UBAH NAMA LENGKAP ───
  static void showName(
    BuildContext context, {
    required AdminProfileBloc bloc, // <-- Tambah parameter BLoC
    required int adminId,
    required String currentName,
    required String currentUsername,
    required String currentPhone,
  }) {
    final nameEditController = TextEditingController(text: currentName);
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Form(
          key: dialogFormKey,
          child: TextFormField(
            controller: nameEditController,
            decoration: const InputDecoration(
              labelText: 'Nama Lengkap Baru',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: AdminValidators.validateName,
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
              
              // Menggunakan instance bloc dari parameter
              bloc.add(
                UpdateAdminProfileEvent(
                  id: adminId,
                  name: nameEditController.text.trim(),
                  phone: currentPhone,
                  username: currentUsername,
                  password: null,
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

  // ─── C. DIALOG UBAH NOMOR TELEPON ───
  static void showPhone(
    BuildContext context, {
    required AdminProfileBloc bloc, // <-- Tambah parameter BLoC
    required int adminId,
    required String currentPhone,
    required String currentName,
    required String currentUsername,
  }) {
    final phoneEditController = TextEditingController(text: currentPhone);
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah Nomor Telepon', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Form(
          key: dialogFormKey,
          child: TextFormField(
            controller: phoneEditController,
            decoration: const InputDecoration(
              labelText: 'Nomor Telepon Baru',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            keyboardType: TextInputType.phone,
            validator: AdminValidators.validatePhone,
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
              
              // Menggunakan instance bloc dari parameter
              bloc.add(
                UpdateAdminProfileEvent(
                  id: adminId,
                  name: currentName,
                  phone: phoneEditController.text.trim(),
                  username: currentUsername,
                  password: null,
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