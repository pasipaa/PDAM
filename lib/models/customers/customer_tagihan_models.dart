class CustomerBill {
  final int id;
  final int customerId;
  final int month;
  final int year;
  final String measurementNumber;
  final int usageValue;
  final int totalPrice;
  final String status;

  CustomerBill({
    required this.id,
    required this.customerId,
    required this.month,
    required this.year,
    required this.measurementNumber,
    required this.usageValue,
    required this.totalPrice,
    required this.status,
  });

  factory CustomerBill.fromJson(Map<String, dynamic> json) {
    bool isPaid = json['paid'] ?? false;
    String billStatus = json['status'] ?? (isPaid ? 'lunas' : 'belum_bayar');

    int usage = json['usage_value'] ?? 0;
    int unitPrice = json['price'] ?? 0;

    return CustomerBill(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      month: json['month'] ?? 1,
      year: json['year'] ?? 2026,
      measurementNumber: json['measurement_number'] ?? '',
      usageValue: usage,
      totalPrice: json['total_price'] ?? (usage * unitPrice),
      status: billStatus.toString().toLowerCase().trim(),
    );
  }
}