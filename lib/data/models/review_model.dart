class ReviewModel {
  final String id;
  final String productId;
  final String buyerId;
  final String buyerName;
  final String buyerAvatar;
  final String orderId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.buyerId,
    required this.buyerName,
    required this.buyerAvatar,
    required this.orderId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // Populate từ backend: buyerId có thể là object
    final buyer = json['buyerId'] is Map<String, dynamic> 
        ? json['buyerId'] 
        : <String, dynamic>{};
        
    return ReviewModel(
      id: json['_id'] ?? '',
      productId: json['productId']?.toString() ?? '',
      buyerId: buyer['_id']?.toString() ?? json['buyerId']?.toString() ?? '',
      buyerName: buyer['fullName'] ?? 'Người dùng ẩn danh',
      buyerAvatar: buyer['avatar'] ?? '',
      orderId: json['orderId']?.toString() ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
    };
  }
}
