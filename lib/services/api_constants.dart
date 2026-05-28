class ApiConstants {
  static const String baseUrl = 'https://learn.smktelkom-mlg.sch.id/pdam';
/// app-key
  static const String ownerAuth = '/app-owners/auth';

  /// POST — Login Admin/Customer → menghasilkan JWT TOKEN
  /// Header wajib: app-key: owner_token
  /// Body: { "username": "...", "password": "..." }
  /// Response: { "success": true, "message": "...", "token": "JWT", "role": "ADMIN|CUSTOMER" }
  static const String userAuth = '/auth';

  /// GET — Daftar semua tagihan (Admin only)
  static const String bills = '/bills';

  /// GET — Tagihan milik customer yang sedang login (Customer only)
  static const String myBills = '/bills/me';

  /// GET — Daftar semua pembayaran (Admin only)
  static const String payments = '/payments';

  /// GET — Pembayaran milik customer yang sedang login (Customer only)
  static const String myPayments = '/payments/me';
}
