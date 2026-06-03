class LayananModels {
  final int id;
  final String name;
  final int minUsage;
  final int maxUsage;
  final int price;

  LayananModels({
    required this.id,
    required this.name,
    required this.minUsage,
    required this.maxUsage,
    required this.price,
  });

  factory LayananModels.fromJson(Map<String, dynamic> json) {
    return LayananModels(
      id: json['id'],
      name: json['name'],
      minUsage: json['min_usage'],
      maxUsage: json['max_usage'],
      price: json['price'],
    );
  }
}