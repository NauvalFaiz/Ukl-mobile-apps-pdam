import 'package:intl/intl.dart';

final currencyFormat = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

String getNamaBulan(int monthNumber) {
  const daftarBulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  if (monthNumber >= 1 && monthNumber <= 12) {
    return daftarBulan[monthNumber - 1];
  }
  return monthNumber.toString();
}
