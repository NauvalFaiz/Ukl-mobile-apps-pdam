import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uklmobileapps/core/network/api_constants.dart';
import 'package:uklmobileapps/core/utils/admin_validators.dart';
import 'package:uklmobileapps/features/auth/presentation/views/components/custom_input.dart';

class AdminRegistrationPage extends StatefulWidget {
  const AdminRegistrationPage({super.key});

  @override
  State<AdminRegistrationPage> createState() => _AdminRegistrationPageState();
}

class _AdminRegistrationPageState extends State<AdminRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _registerAdmin() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final appKey = prefs.getString('app_key');

      final dio = Dio();
      if (appKey != null && appKey.isNotEmpty) {
        dio.options.headers['app-key'] = appKey;
      }

      final payload = {
        "username": _usernameController.text,
        "password": _passwordController.text,
        "name": _nameController.text,
        "phone": _phoneController.text,
      };

      final response = await dio.post(
        '${ApiConstants.baseUrl}/admins',
        data: payload,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi Admin Berhasil!')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } on DioException catch (e) {
      final serverMessage =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal Registrasi: $serverMessage')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal Registrasi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      // 1. SingleChildScrollView ditaruh di paling luar agar SEMUA komponen bisa di-scroll
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ================= 1. HEADER SECTION (IKUT DI-SCROLL) =================
            Container(
              decoration: const BoxDecoration(
                color: Color(0xff0F67FE),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              height: 360, 
              width: screenWidth,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // Background SVG memenuhi area atas
                    Positioned.fill(
                      child: SvgPicture.asset(
                        'assets/card_register-login.svg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Tombol Close/Kembali
                    Positioned(
                      top: 60, // Jarak aman dari status bar HP
                      right: 20,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: SvgPicture.asset('assets/Close.svg'),
                      ),
                    ),
                    // Judul/Grafis Register
                    Positioned(
                      left: 24,
                      bottom: 40,
                      right: 24,
                      child: SvgPicture.asset(
                        'assets/register.svg',
                        alignment: Alignment.bottomLeft,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ================= 2. FORM SECTION (IKUT DI-SCROLL) =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- NAMA LENGKAP ---
                    _buildInputLabel('Nama Lengkap'),
                    CustomInput(
                      controller: _nameController,
                      hintText: 'Enter your name...',
                      validator: AdminValidators.validateName,
                    ),
                    const SizedBox(height: 20),

                    // --- NOMOR TELEPON ---
                    _buildInputLabel('Nomor Telepon'),
                    CustomInput(
                      controller: _phoneController,
                      hintText: 'Enter your phone number...',
                      keyboardType: TextInputType.phone,
                      validator: AdminValidators.validatePhone,
                    ),
                    const SizedBox(height: 20),

                    // --- USERNAME ---
                    _buildInputLabel('Username'),
                    CustomInput(
                      controller: _usernameController,
                      hintText: 'Enter your username...',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // --- PASSWORD ---
                    _buildInputLabel('Password'),
                    CustomInput(
                      controller: _passwordController,
                      hintText: '*****************',
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        if (value.length < 8) {
                          return 'Password minimal mengandung 8 karakter.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // --- BUTTON REGISTER ---
                    ElevatedButton(
                      onPressed: _isLoading ? null : _registerAdmin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A6CFF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Daftar Akun Admin',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                    const SizedBox(
                      height: 24,
                    ), // Jarak manis di bagian paling bawah halaman
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }
}
