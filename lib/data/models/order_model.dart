class OrderModel {
  final String id;
  final String orderCode;
  final String buyerId;
  final String sellerId;
  final String status;
  final double subtotal;
  final double shippingFee;
  final double totalAmount;
  final String? paymentMethod;
  final String paymentStatus;
  final String? note;
  final String? cancelledReason;
  final List<OrderItemModel> items;
  final Map<String, dynamic>? shippingAddressSnapshot;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderModel({
    required this.id,
    required this.orderCode,
    required this.buyerId,
    required this.sellerId,
    required this.status,
    required this.subtotal,
    required this.shippingFee,
    required this.totalAmount,
    this.paymentMethod,
    required this.paymentStatus,
    this.note,
    this.cancelledReason,
    required this.items,
    this.shippingAddressSnapshot,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String? ?? '',
      orderCode: json['orderCode'] as String? ?? '',
      buyerId: json['buyerId'] as String? ?? '',
      sellerId: json['sellerId'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] as String?,
      paymentStatus: json['paymentStatus'] as String? ?? 'unpaid',
      note: json['note'] as String?,
      cancelledReason: json['cancelledReason'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      shippingAddressSnapshot: json['shippingAddressSnapshot'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Chờ xác nhận';
      case 'confirmed': return 'Đã xác nhận';
      case 'preparing': return 'Đang chuẩn bị';
      case 'handed_to_logistics': return 'Đã giao vận chuyển';
      case 'shipping': return 'Đang giao hàng';
      case 'delivered': return 'Đã giao';
      case 'cancelled': return 'Đã hủy';
      case 'disputed': return 'Tranh chấp';
      default: return status;
    }
  }

  bool get isPending => status == 'pending';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isActive => ['confirmed', 'preparing', 'handed_to_logistics', 'shipping'].contains(status);
}

class OrderItemModel {
  final String id;
  final String? productId;
  final Map<String, dynamic> productSnapshot;
  final double quantity;
  final double unitPrice;
  final double totalPrice;

  const OrderItemModel({
    required this.id,
    this.productId,
    required this.productSnapshot,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  String get productName => productSnapshot['name'] as String? ?? 'Sản phẩm';
  String get productUnit => productSnapshot['unit'] as String? ?? '';
  String? get productImageUrl {
    final imgs = productSnapshot['images'];
    if (imgs is List && imgs.isNotEmpty) {
      final first = imgs.first;
      return first is Map ? first['url'] as String? : first as String?;
    }
    return null;
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String?,
      productSnapshot: json['productSnapshot'] as Map<String, dynamic>? ?? {},
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CreateOrderRequest {
  final List<CreateOrderItem> items;
  final String deliveryName;
  final String deliveryPhone;
  final String address;
  final String? note;
  final String paymentMethod;

  const CreateOrderRequest({
    required this.items,
    required this.deliveryName,
    required this.deliveryPhone,
    required this.address,
    this.note,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
        'items': items.map((i) => i.toJson()).toList(),
        'shippingAddressSnapshot': {
          'recipientName': deliveryName,
          'phone': deliveryPhone,
          'address': address,
        },
        'note': note,
        'paymentMethod': paymentMethod,
      };
}

class CreateOrderItem {
  final String productId;
  final int quantity;

  const CreateOrderItem({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {'productId': productId, 'quantity': quantity};
}
