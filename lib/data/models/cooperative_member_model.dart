class CooperativeMemberModel {
  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String status; // 'pending' | 'approved' | 'rejected'
  final DateTime? joinedAt;

  const CooperativeMemberModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.status,
    this.joinedAt,
  });

  factory CooperativeMemberModel.fromJson(Map<String, dynamic> json) {
    return CooperativeMemberModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      joinedAt: json['joinedAt'] != null ? DateTime.tryParse(json['joinedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'phone': phone,
      'status': status,
      'joinedAt': joinedAt?.toIso8601String(),
    };
  }
}
