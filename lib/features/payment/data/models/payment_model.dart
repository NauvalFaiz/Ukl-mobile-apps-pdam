class PaymentModel {
  final int id;
  final int billId;
  final int customerId;
  final String file;
  final bool verified;
  final int? adminId;
  final String createdAt;
  final String updatedAt;

  PaymentModel({
    required this.id,
    required this.billId,
    required this.customerId,
    required this.file,
    required this.verified,
    this.adminId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? 0,
      billId: json['bill_id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      file: json['payment_proof'] ?? json['file'] ?? '',
      verified: json['verified'] ?? false,
      adminId: json['admin_id'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}