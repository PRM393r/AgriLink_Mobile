class UserModel {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String role;
  final String? avatarUrl;
  final String status;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    required this.role,
    this.avatarUrl,
    required this.status,
  });

  bool get isFarmer => role == 'farmer';
  bool get isSupplier => role == 'supplier';
  bool get isCustomer => role == 'customer';

  bool get isValidRole => isFarmer || isSupplier || isCustomer;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      role: json['role'] as String? ?? 'customer',
      avatarUrl: json['avatarUrl'] as String?,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'role': role,
      'avatarUrl': avatarUrl,
      'status': status,
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
    String? role,
    String? avatarUrl,
    String? status,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
    );
  }
}
