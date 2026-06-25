class CartItem {
  final String productId;
  final String productName;
  final double price;
  final String unit;
  final int quantity;
  final String? imageUrl;

  const CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.unit,
    required this.quantity,
    this.imageUrl,
  });

  CartItem copyWith({
    String? productId,
    String? productName,
    double? price,
    String? unit,
    int? quantity,
    String? imageUrl,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'unit': unit,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      unit: json['unit'] as String,
      quantity: json['quantity'] as int,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
