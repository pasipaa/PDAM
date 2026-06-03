class CustomerRegisterModel {
  final String username;
  final String password;
  final String name;
  final String phone;

  CustomerRegisterModel({
    required this.username,
    required this.password,
    required this.name,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "password": password,
      "name": name,
      "phone": phone,
    };
  }
}