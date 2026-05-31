import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uklmobileapps/core/network/api_constants.dart';
import 'package:uklmobileapps/core/utils/admin_validators.dart';

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
  bool _obscurePassword = true;

  // State untuk mendeteksi error pada masing-masing field secara real-time
  bool _nameHasError = false;
  bool _phoneHasError = false;
  bool _usernameHasError = false;
  bool _passwordHasError = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _registerAdmin() async {
    // Validasi form saat tombol ditekan
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
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            // ================= HEADER SECTION =================
            SizedBox(
              height: 320, // Menggunakan ukuran proposional sesuai gambar UI
              width: screenWidth,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SvgPicture.asset(
                      'assets/card_register-login.svg',
                      fit: BoxFit.fill,
                    ),
                  ),
                  Positioned(
                    top: 50,
                    right: 20,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: SvgPicture.asset('assets/Close.svg'),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    bottom: 50,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          'assets/register.svg',
                          height: 142,
                          width: 326,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ================= FORM SECTION =================
            Padding(
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- NAMA LENGKAP ---
                    _buildInputLabel('Nama Lengkap'),
                    TextFormField(
                      controller: _nameController,
                      decoration: _buildInputDecoration(
                        'Enter your email address...',
                        hasError: _nameHasError,
                      ),
                      // Listener pembaruan warna saat terjadi validasi
                      onChanged: (val) {
                        if (_nameHasError)
                          setState(() => _nameHasError = false);
                      },
                      validator: (value) {
                        final res = AdminValidators.validateName(value);
                        setState(() => _nameHasError = res != null);
                        return res;
                      },
                    ),
                    const SizedBox(height: 20),

                    // --- NOMOR TELEPON ---
                    _buildInputLabel('Nomor Telepon'),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _buildInputDecoration(
                        'Enter your email address...',
                        hasError: _phoneHasError,
                      ),
                      onChanged: (val) {
                        if (_phoneHasError)
                          setState(() => _phoneHasError = false);
                      },
                      validator: (value) {
                        final res = AdminValidators.validatePhone(value);
                        setState(() => _phoneHasError = res != null);
                        return res;
                      },
                    ),
                    const SizedBox(height: 20),

                    // --- USERNAME ---
                    _buildInputLabel('Username'),
                    TextFormField(
                      controller: _usernameController,
                      decoration: _buildInputDecoration(
                        'Enter your email address...',
                        hasError: _usernameHasError,
                      ),
                      onChanged: (val) {
                        if (_usernameHasError)
                          setState(() => _usernameHasError = false);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() => _usernameHasError = true);
                          return 'Username tidak boleh kosong';
                        }
                        setState(() => _usernameHasError = false);
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // --- PASSWORD ---
                    _buildInputLabel('Password'),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration:
                          _buildInputDecoration(
                            '*****************',
                            hasError: _passwordHasError,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons
                                          .visibility_rounded, // Diperbaiki agar berganti icon mata terbuka/tertutup
                                color: _passwordHasError
                                    ? const Color(0xffFA4D5E)
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                      onChanged: (val) {
                        if (_passwordHasError)
                          setState(() => _passwordHasError = false);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() => _passwordHasError = true);
                          return 'Password tidak boleh kosong';
                        }
                        if (value.length < 8) {
                          // Mengikuti gambar "minimal mengandung 8 karakter"
                          setState(() => _passwordHasError = true);
                          return 'Password minimal mengandung 8 karakter.';
                        }
                        setState(() => _passwordHasError = false);
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
                    const SizedBox(height: 50),
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

  InputDecoration _buildInputDecoration(String hint, {bool hasError = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: hasError ? const Color(0xffFA4D5E) : const Color(0xFF5D6A85),
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      filled: true,
      // ==============================================================
      // PERBAIKAN LOGIKA WARNA BACKGROUND DI SINI (SESUAI GAMBAR BARU)
      // ==============================================================
      // JIKA ERROR -> Pakai warna soft pink (0xFFFFD7DD)
      // JIKA NORMAL -> Pakai warna abu-abu (0xFFF5F5F5)
      fillColor: hasError ? const Color(0xFFFFD7DD) : const Color(0xFFF5F5F5),

      errorStyle: const TextStyle(
        color: Color(0xffFA4D5E),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),

      // Border Normal (Tanpa garis tepi hitam)
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(color: Color(0xFF1A6CFF), width: 1.5),
      ),

      // Border Khusus Saat State Error Berjalan
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(color: Color(0xffFA4D5E), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(color: Color(0xffFA4D5E), width: 1.5),
      ),
    );
  }
}
