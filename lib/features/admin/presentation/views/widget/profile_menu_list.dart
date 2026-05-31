import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_bloc.dart';
import 'package:uklmobileapps/features/admin/presentation/views/widget/dialogs/profile_action_dialog.dart';
import 'package:uklmobileapps/features/admin/presentation/views/widget/dialogs/profile_edit_dialog.dart';
import 'package:uklmobileapps/features/admin/presentation/views/widget/dialogs/profile_password_dialog.dart';


class ProfileMenuList extends StatelessWidget {
  final int? adminId;
  final String currentName;
  final String currentPhone;
  final String currentUsername;
  final bool isUpdating;
  final VoidCallback onLogoutConfirmed;

  const ProfileMenuList({
    super.key,
    required this.adminId,
    required this.currentName,
    required this.currentPhone,
    required this.currentUsername,
    required this.isUpdating,
    required this.onLogoutConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    // Ambil instance BLoC aktif dari context halaman utama
    final adminBloc = context.read<AdminProfileBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Menu Username ───
        ListTile(
          leading: const Icon(Icons.account_box_outlined),
          title: const Text('Username Admin'),
          subtitle: Text(currentUsername.isNotEmpty ? currentUsername : '-'),
          trailing: const Icon(Icons.edit_outlined, color: Color(0xFFD32F2F)),
          contentPadding: EdgeInsets.zero,
          onTap: isUpdating || adminId == null
              ? null
              : () => ProfileEditDialog.showUsername(
                    context,
                    bloc: adminBloc,
                    adminId: adminId!,
                    currentUsername: currentUsername,
                    currentName: currentName,
                    currentPhone: currentPhone,
                  ),
        ),
        const Divider(),

        // ─── Menu Nama Lengkap ───
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('Nama Lengkap'),
          subtitle: Text(currentName.isNotEmpty ? currentName : '-'),
          trailing: const Icon(Icons.edit_outlined, color: Color(0xFFD32F2F)),
          contentPadding: EdgeInsets.zero,
          onTap: isUpdating || adminId == null
              ? null
              : () => ProfileEditDialog.showName(
                    context,
                    bloc: adminBloc,
                    adminId: adminId!,
                    currentName: currentName,
                    currentUsername: currentUsername,
                    currentPhone: currentPhone,
                  ),
        ),
        const Divider(),

        // ─── Menu Nomor Telepon ───
        ListTile(
          leading: const Icon(Icons.phone_outlined),
          title: const Text('Nomor Telepon'),
          subtitle: Text(currentPhone.isNotEmpty ? currentPhone : '-'),
          trailing: const Icon(Icons.edit_outlined, color: Color(0xFFD32F2F)),
          contentPadding: EdgeInsets.zero,
          onTap: isUpdating || adminId == null
              ? null
              : () => ProfileEditDialog.showPhone(
                    context,
                    bloc: adminBloc,
                    adminId: adminId!,
                    currentPhone: currentPhone,
                    currentName: currentName,
                    currentUsername: currentUsername,
                  ),
        ),
        const Divider(),

        // ─── Menu Password ───
        ListTile(
          leading: const Icon(Icons.key, color: Colors.grey),
          title: const Text('Passwords'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          contentPadding: EdgeInsets.zero,
          onTap: isUpdating || adminId == null
              ? null
              : () => ProfilePasswordDialog.show(
                    context,
                    bloc: adminBloc,
                    adminId: adminId!,
                    currentName: currentName,
                    currentUsername: currentUsername,
                    currentPhone: currentPhone,
                  ),
        ),
        const Divider(),

        const SizedBox(height: 24),
        if (isUpdating)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(child: CircularProgressIndicator()),
          ),

        ElevatedButton(
          onPressed: isUpdating || adminId == null
              ? null
              : () => ProfileActionDialog.showDeleteConfirmation(
                    context,
                    bloc: adminBloc,
                    adminId: adminId!,
                  ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.red,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            'Hapus Akun Saya',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),

        // ─── Tombol Logout ───
        ElevatedButton.icon(
          onPressed: isUpdating
              ? null
              : () => ProfileActionDialog.showLogoutConfirmation(
                    context,
                    onConfirm: onLogoutConfirmed,
                  ),
          icon: const Icon(Icons.exit_to_app),
          label: const Text(
            'Keluar / Logout',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),

        const SizedBox(height: 120), // Spacer penahan custom Navbar Anda
      ],
    );
  }
}