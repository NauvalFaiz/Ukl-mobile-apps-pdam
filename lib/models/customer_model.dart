class CustomerModel {
  final int id;
  final String username;
  final String customerNumber;
  final String address;
  final int serviceId;
  final String name;
  final String phone;
  final String role;

  CustomerModel({
    required this.id,
    required this.username,
    required this.customerNumber,
    required this.address,
    required this.serviceId,
    required this.name,
    required this.phone,
    required this.role,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      customerNumber: json['customer_number'] ?? '',
      address: json['address'] ?? '',
      serviceId: json['service_id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'CUSTOMER',
    );
  }
}
