import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl {
    if (!dotenv.isInitialized) {
      return 'https://learn.smktelkom-mlg.sch.id/pdam';
    }
    return dotenv.env['API_BASE_URL'] ?? 'https://learn.smktelkom-mlg.sch.id/pdam';
  }

  static const String ownerAuth = '/app-owners/auth';
  static const String userAuth = '/auth';
  static const String bills = '/bills';
  static const String myBills = '/bills/me';
  static const String payments = '/payments';
  static const String myPayments = '/payments/me';
}