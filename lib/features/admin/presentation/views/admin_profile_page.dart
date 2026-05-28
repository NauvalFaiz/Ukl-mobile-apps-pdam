import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uklmobileapps/features/admin/presentation/views/widget/admin_change_password_page.dart';
import 'package:uklmobileapps/shared/widgets/nav_model_custom.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_bloc.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_event.dart';
import 'package:uklmobileapps/features/admin/presentation/bloc/admin_profile_state.dart';
import 'package:uklmobileapps/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:uklmobileapps/features/auth/presentation/bloc/auth_event.dart';
import 'package:uklmobileapps/features/auth/presentation/views/login_page.dart';
import 'package:uklmobileapps/core/utils/admin_validators.dart';

// Jika Amicons adalah library icon kustom Anda, silakan hilangkan komentar impor di bawah ini:
// import 'path_ke_amicons/amicons.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  int? _adminId;

  // Variabel lokal untuk menyimpan data profil saat ini dari state BLoC
  String _currentName = '';
  String _currentPhone = '';
  String _currentUsername = '';

  @override
  void initState() {
    super.initState();
    // Ambil data profil admin dari server saat halaman dibuka
    context.read<AdminProfileBloc>().add(FetchAdminProfileEvent());
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'A';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  // ─── 1. DIALOG POP-UP: UBAH USERNAME ───────────────────────────────────
  void _showEditUsernameDialog(BuildContext context, String currentUsername) {
    final TextEditingController usernameController = TextEditingController(
      text: currentUsername,
    );
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Ubah Username',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
                if (value == null || value.trim().isEmpty) {
                  return 'Username tidak boleh kosong';
                }
                if (value.trim().length < 4) {
                  return 'Username minimal harus 4 karakter';
                }
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

                context.read<AdminProfileBloc>().add(
                  UpdateAdminProfileEvent(
                    id: _adminId!,
                    name: _currentName,
                    phone: _currentPhone,
                    username: usernameController.text.trim(),
                    password: null,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // ─── 2. DIALOG POP-UP: UBAH NAMA LENGKAP ───────────────────────────────
  void _showEditNameDialog(BuildContext context, String currentName) {
    final TextEditingController nameEditController = TextEditingController(
      text: currentName,
    );
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Ubah Nama Lengkap',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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

                context.read<AdminProfileBloc>().add(
                  UpdateAdminProfileEvent(
                    id: _adminId!,
                    name: nameEditController.text.trim(),
                    phone: _currentPhone,
                    username: _currentUsername,
                    password: null,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // ─── 3. DIALOG POP-UP: UBAH NOMOR TELEPON ─────────────────────────────
  void _showEditPhoneDialog(BuildContext context, String currentPhone) {
    final TextEditingController phoneEditController = TextEditingController(
      text: currentPhone,
    );
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Ubah Nomor Telepon',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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

                context.read<AdminProfileBloc>().add(
                  UpdateAdminProfileEvent(
                    id: _adminId!,
                    name: phoneEditController.text.trim(),
                    phone: _currentPhone,
                    username: _currentUsername,
                    password: null,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // ─── 4. DIALOG POP-UP: KONFIRMASI HAPUS AKUN (DESAIN KAMU + ANTI OVERFLOW) ───
  void _showDeleteConfirmationDialog(BuildContext context) {
    if (_adminId == null) return;
    final TextEditingController deleteController = TextEditingController();
    bool isDeleteEnabled = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              // SingleChildScrollView dipasang di sini untuk mencegah overflow saat keyboard fokus naik
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Silakan ganti ke Amicons.vuesax_danger_fill jika library-nya sudah terpasang
                    const Icon(
                      Icons.warning_rounded,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Anda yakin menghapus akun anda?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Jika yakin, ketik "delate" pada kolom di bawah ini untuk menghapus akun secara permanen.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: deleteController,
                      decoration: InputDecoration(
                        hintText: 'Ketik "delate" di sini',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setStateDialog(() {
                          isDeleteEnabled = value == 'delate';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        'Jika anda ingin registrasi akun admin anda harus ',
                                  ),
                                  TextSpan(
                                    text: 'tutorial registrasi admin.',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isDeleteEnabled
                            ? () {
                                Navigator.pop(dialogContext);
                                context.read<AdminProfileBloc>().add(
                                  DeleteAdminProfileEvent(id: _adminId!),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Delate',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ─── 5. DIALOG POP-UP: KONFIRMASI LOGOUT ─────────────────────────────────
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar aplikasi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AuthBloc>().add(AuthLogoutRequested());
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ya, Keluar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // TETAP ADA: Sesuai keinginan agar navbar menembus body
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Admin Profil'),
        // DI-SCROLL TIDAK BERUBAH WARNA: Mengunci warna latar dan mematikan overlay elevasi
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
      ),
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
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is AdminProfileInitial || state is AdminProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          bool isUpdating =
              state is AdminProfileUpdating || state is AdminProfileDeleting;
          String role = (state is AdminProfileLoaded)
              ? state.role
              : 'IT Administrator';

          return SingleChildScrollView(
            // Penyeimbang margin bawah dari sistem operasi / device screen
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── A. Banner Profil Atas ───────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 16,
                  ),
                  color: const Color(0xFFD32F2F),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Text(
                          _getInitials(_currentName),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD32F2F),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentName.isNotEmpty ? _currentName : 'Admin',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          role.isNotEmpty ? role : 'IT Administrator',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── B. Daftar Menu Akun Interaktif ──────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris 1: Edit Username Admin
                      ListTile(
                        leading: const Icon(Icons.account_box_outlined),
                        title: const Text('Username Admin'),
                        subtitle: Text(
                          _currentUsername.isNotEmpty ? _currentUsername : '-',
                        ),
                        trailing: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFFD32F2F),
                        ),
                        contentPadding: EdgeInsets.zero,
                        onTap: isUpdating
                            ? null
                            : () => _showEditUsernameDialog(
                                context,
                                _currentUsername,
                              ),
                      ),
                      const Divider(),

                      // Baris 2: Edit Nama Lengkap
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text('Nama Lengkap'),
                        subtitle: Text(
                          _currentName.isNotEmpty ? _currentName : '-',
                        ),
                        trailing: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFFD32F2F),
                        ),
                        contentPadding: EdgeInsets.zero,
                        onTap: isUpdating
                            ? null
                            : () => _showEditNameDialog(context, _currentName),
                      ),
                      const Divider(),

                      // Baris 3: Edit Nomor Telepon
                      ListTile(
                        leading: const Icon(Icons.phone_outlined),
                        title: const Text('Nomor Telepon'),
                        subtitle: Text(
                          _currentPhone.isNotEmpty ? _currentPhone : '-',
                        ),
                        trailing: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFFD32F2F),
                        ),
                        contentPadding: EdgeInsets.zero,
                        onTap: isUpdating
                            ? null
                            : () =>
                                  _showEditPhoneDialog(context, _currentPhone),
                      ),
                      const Divider(),

                      // Baris 4: Ubah Password Akun
                      ListTile(
                        leading: const Icon(Icons.lock_open_outlined),
                        title: const Text('Keamanan Sandi'),
                        subtitle: const Text('Ubah Password Akun'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        contentPadding: EdgeInsets.zero,
                        onTap: _adminId == null || isUpdating
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AdminChangePasswordPage(
                                          adminId: _adminId!,
                                          currentName: _currentName,
                                          currentPhone: _currentPhone,
                                        ),
                                  ),
                                );
                              },
                      ),
                      const Divider(),

                      const SizedBox(height: 24),

                      if (isUpdating)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),

                      // ─── C. Danger Zone Buttons ───────────────────────────
                      // Tombol Hapus Akun
                      ElevatedButton(
                        onPressed: isUpdating
                            ? null
                            : () => _showDeleteConfirmationDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.red,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Hapus Akun Saya',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: isUpdating
                            ? null
                            : () => _showLogoutConfirmationDialog(context),
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text(
                          'Keluar / Logout',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      // SIZEDBOX PENAHAN TETAP ADA: Menghindari ketutupan navbar akibat extendBody
                      const SizedBox(height: 120),
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
