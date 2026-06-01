import 'package:intl/intl.dart';
import 'package:uklmobileapps/features/bill/data/models/bill_model.dart';
// Import BillModel Anda di sini

class ChartDataTransformer {
  static List<BillModel> prepareDataForChart(List<BillModel> originalBills) {
    // 1. Buat duplikat list agar tidak mengubah state asli secara tidak sengaja
    List<BillModel> sortedBills = List.from(originalBills);

    // 2. Urutkan berdasarkan Tahun terlebih dahulu, kemudian Bulan
    sortedBills.sort((a, b) {
      if (a.year != b.year) {
        return a.year.compareTo(b.year);
      }
      return a.month.compareTo(b.month);
    });

    // 3. (Opsional) Batasi data jika hanya ingin menampilkan 6 atau 12 bulan terakhir
    // jika datanya terlalu banyak, grafik akan terlihat sangat padat.
    if (sortedBills.length > 6) {
      return sortedBills.sublist(sortedBills.length - 6);
    }

    return sortedBills;
  }

  // Helper untuk mengubah angka bulan (1-12) menjadi nama bulan singkat (Jan, Feb, Mar)
  static String getMonthName(int monthNumber) {
    try {
      final dateTime = DateTime(2026, monthNumber);
      return DateFormat('MMM').format(dateTime); // Hasil: "Jan", "Feb", dst.
    } catch (e) {
      return monthNumber.toString();
    }
  }
}