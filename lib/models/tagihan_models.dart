class TagihanModels {
  final int id;
  final String month;
  final int year;
  final int usageValue;
  final int price;

  TagihanModels({
    required this.id,
    required this.month,
    required this.year,
    required this.usageValue,
    required this.price,
  });

  factory TagihanModels.fromJson(Map<String, dynamic> json) {
    return TagihanModels(
      id: json['id'],
      month: json['month'].toString(),
      year: json['year'],
      usageValue: json['usage_value'],
      price: json['price'] ?? 10000,
    );
  }
}

class PaymentModel {
  final int id;
  final int billId;
  final String status;

  PaymentModel({
    required this.id,
    required this.billId,
    required this.status,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      billId: int.parse(json['bill_id'].toString()),
      status: json['status'] ?? 'PENDING',
    );
  }
}