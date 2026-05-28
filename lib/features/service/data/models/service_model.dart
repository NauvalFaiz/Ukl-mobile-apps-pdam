class ServiceModel {
  final int id;
  final String name;
  final int minUsage;
  final int maxUsage;
  final int price;

  ServiceModel({
    required this.id,
    required this.name,
    required this.minUsage,
    required this.maxUsage,
    required this.price,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      minUsage: json['min_usage'] ?? 0,
      maxUsage: json['max_usage'] ?? 0,
      price: json['price'] ?? 0,
    );
  }
}
