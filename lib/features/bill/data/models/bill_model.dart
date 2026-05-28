class BillModel {
  final int id;
  final int customerId;
  final int month;
  final int year;
  final String measurementNumber;
  final int usageValue;

  BillModel({
    required this.id,
    required this.customerId,
    required this.month,
    required this.year,
    required this.measurementNumber,
    required this.usageValue,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      month: json['month'] ?? 0,
      year: json['year'] ?? 0,
      measurementNumber: json['measurement_number'] ?? '',
      usageValue: json['usage_value'] ?? 0,
    );
  }
}
