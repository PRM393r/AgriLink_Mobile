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
    final qtyRaw = json['quantity'];
    final quantity = qtyRaw is int
        ? qtyRaw
        : qtyRaw is num
            ? qtyRaw.toInt()
            : int.tryParse('$qtyRaw') ?? 0;

    return CartItem(
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? '',
      quantity: quantity,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
