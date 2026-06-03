class ProfileModel {
  final int id;
  final String username;
  final String name;
  final String phone;
  final String? createdAt;

  ProfileModel({
    required this.id,
    required this.username,
    required this.name,
    required this.phone,
    this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      createdAt: json['created_at'],
    );
  }

  get customerNumber => null;

  get address => null;

  get image => null;
}