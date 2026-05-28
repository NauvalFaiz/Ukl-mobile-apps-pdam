class PaymentModel {
  final int id;
  final int billId;
  final String status;
  final String fileProof;

  PaymentModel({
    required this.id,
    required this.billId,
    required this.status,
    required this.fileProof,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? 0,
      billId: json['bill_id'] ?? 0,
      status: json['status'] ?? 'PENDING',
      fileProof: json['file'] ?? '', 
    );
  }
}
