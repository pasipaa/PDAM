class CustomerModel {
  final int id;
  final String name;
  final String username; 
  final String customerNumber;
  final String phone;
  final String address;
  final ServiceModel? service;

  CustomerModel({
    required this.id,
    required this.name,
    required this.username, 
    required this.customerNumber,
    required this.phone,
    required this.address,
    this.service,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    ServiceModel? parsedService;
    
    if (json['service'] != null) {
      if (json['service'] is Map) {
        parsedService = ServiceModel.fromJson(Map<String, dynamic>.from(json['service']));
      } else {
        parsedService = ServiceModel(
          id: int.tryParse(json['service_id']?.toString() ?? '0') ?? 0, 
          name: json['service'].toString(), 
          price: 0,
        );
      }
    }

    return CustomerModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '-',
      username: json['username']?.toString() ?? '-',
      customerNumber: json['customer_number']?.toString() ?? json['customerNumber']?.toString() ?? '-',
      phone: json['phone']?.toString() ?? '-',
      address: json['address']?.toString() ?? '-',
      service: parsedService,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'customer_number': customerNumber,
      'phone': phone,
      'address': address,
      'service': service?.toJson(),
    };
  }
}

class ServiceModel {
  final int id; 
  final String name;
  final int price;

  ServiceModel({
    required this.id, 
    required this.name, 
    required this.price,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0, 
      name: json['name']?.toString() ?? 'Layanan',
      price: int.tryParse(json['price']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }
}