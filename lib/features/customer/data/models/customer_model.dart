class CustomerModel {
  final int id;
  final int userId;
  final String customerNumber;
  final String name;
  final String phone;
  final String address;
  final int serviceId;
  final String? username;

  CustomerModel({
    required this.id,
    required this.userId,
    required this.customerNumber,
    required this.name,
    required this.phone,
    required this.address,
    required this.serviceId,
    this.username,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      customerNumber: json['customer_number'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      serviceId: json['service_id'] ?? 0,
      username: json['user'] != null ? json['user']['username'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'customer_number': customerNumber,
      'name': name,
      'phone': phone,
      'address': address,
      'service_id': serviceId,
    };
  }
}
