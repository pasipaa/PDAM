class CustomerPayment {
  final int id;
  final int billId;
  final String status; // 'pending', 'verified', 'rejected'
  final String? proofImage;

  CustomerPayment({
    required this.id,
    required this.billId,
    required this.status,
    this.proofImage,
  });

  factory CustomerPayment.fromJson(Map<String, dynamic> json) {
    // FIX: API tidak punya field 'status' — yang ada 'verified' (bool)
    // verified: true  → 'verified'
    // verified: false → 'pending'
    String status;
    if (json['status'] != null) {
      // kalau suatu saat backend nambah field status, tetap bisa baca
      status = json['status'].toString().toLowerCase().trim();
    } else {
      final bool verified = json['verified'] == true;
      status = verified ? 'verified' : 'pending';
    }

    return CustomerPayment(
      id: json['id'] ?? 0,
      billId: json['bill_id'] ?? 0,
      status: status,
      // FIX: API pakai 'payment_proof', bukan 'proof_image' atau 'file'
      proofImage: json['payment_proof'] ?? json['proof_image'] ?? json['file'],
    );
  }
}

class CustomerBill {
  final int id;
  final int customerId;
  final int month;
  final int year;
  final String measurementNumber;
  final int usageValue;
  final int totalPrice;
  String status;

  CustomerBill({
    required this.id,
    required this.customerId,
    required this.month,
    required this.year,
    required this.measurementNumber,
    required this.usageValue,
    required this.totalPrice,
    this.status = 'belum_bayar',
  });

  factory CustomerBill.fromJson(Map<String, dynamic> json) {
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
      status: 'belum_bayar',
    );
  }
}

// FIX: baca 'verified' bool, bukan 'status' string
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
    String status;
    if (json['status'] != null) {
      status = json['status'].toString().toLowerCase().trim();
    } else {
      final bool verified = json['verified'] == true;
      status = verified ? 'verified' : 'pending';
    }

    return PaymentModel(
      id: json['id'] ?? 0,
      billId: int.tryParse(json['bill_id'].toString()) ?? 0,
      status: status,
    );
  }
}