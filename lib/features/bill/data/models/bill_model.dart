class BillModel {
  final int id;
  final int customerId;
  final int? adminId;
  final int month;
  final int year;
  final String measurementNumber;
  final int usageValue;
  final int price;
  final int serviceId;
  final bool paid;
  final String createdAt;
  final String updatedAt;

  BillModel({
    required this.id,
    required this.customerId,
    this.adminId,
    required this.month,
    required this.year,
    required this.measurementNumber,
    required this.usageValue,
    required this.price,
    required this.serviceId,
    required this.paid,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      adminId: json['admin_id'],
      month: json['month'] ?? 0,
      year: json['year'] ?? 0,
      measurementNumber: json['measurement_number'] ?? '',
      usageValue: json['usage_value'] ?? 0,
      price: json['price'] ?? 0,
      serviceId: json['service_id'] ?? 0,
      paid: json['paid'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
