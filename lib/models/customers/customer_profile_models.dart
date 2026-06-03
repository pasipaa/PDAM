/// MODEL DATA: PROFIL CUSTOMER
class CustomerProfile {
  final int id;
  final String username;
  final String name;
  final String phone;
  final String address;
  final String customerNumber;

  CustomerProfile({
    required this.id,
    required this.username,
    required this.name,
    required this.phone,
    required this.address,
    required this.customerNumber,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      customerNumber: json['customer_number'] ?? json['customerNumber'] ?? '',
    );
  }
}