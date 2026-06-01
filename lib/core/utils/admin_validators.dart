class AdminValidators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor HP tidak boleh kosong';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username Belum terisi';
    }
    return null;
  }
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password Belum terisi';
    }
    return null;
  }

  static String? validateConfirmPassword(
    String? password,
    String? confirmPassword,
  ) {
    if (password != null && password.isNotEmpty) {
      if (confirmPassword == null || confirmPassword.isEmpty) {
        return 'Konfirmasi password harus diisi';
      }
      if (password != confirmPassword) {
        return 'Password tidak cocok';
      }
    }
    return null;
  }
}
