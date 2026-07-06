class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;       // optional — backend mới không dùng phone
  final String role;
  final String? avatarUrl;
  final String? address;
  final bool isVerified;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    this.avatarUrl,
    this.address,
    this.isVerified = false,
  });

  bool get isFarmer   => role == 'farmer';
  bool get isSupplier => role == 'supplier';
  bool get isCustomer => role == 'customer';
  bool get isValidRole => isFarmer || isSupplier || isCustomer;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // MongoDB trả '_id', backend cũ trả 'id'
    final id = (json['_id'] ?? json['id'] ?? '') as String;
    return UserModel(
      id:         id,
      fullName:   json['fullName']  as String? ?? '',
      email:      json['email']     as String? ?? '',
      phone:      json['phone']     as String?,
      role:       json['role']      as String? ?? 'customer',
      avatarUrl:  json['avatarUrl'] as String?,
      address:    json['address']   as String?,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':         id,
    'fullName':   fullName,
    'email':      email,
    'phone':      phone,
    'role':       role,
    'avatarUrl':  avatarUrl,
    'address':    address,
    'isVerified': isVerified,
  };

  UserModel copyWith({
    String?  id,
    String?  fullName,
    String?  email,
    String?  phone,
    String?  role,
    String?  avatarUrl,
    String?  address,
    bool?    isVerified,
  }) => UserModel(
    id:         id         ?? this.id,
    fullName:   fullName   ?? this.fullName,
    email:      email      ?? this.email,
    phone:      phone      ?? this.phone,
    role:       role       ?? this.role,
    avatarUrl:  avatarUrl  ?? this.avatarUrl,
    address:    address    ?? this.address,
    isVerified: isVerified ?? this.isVerified,
  );
}
