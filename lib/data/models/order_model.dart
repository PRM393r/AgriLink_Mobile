class StatusHistoryEntry {
  final String status;
  final DateTime changedAt;
  const StatusHistoryEntry({required this.status, required this.changedAt});
  factory StatusHistoryEntry.fromJson(Map<String, dynamic> json) =>
      StatusHistoryEntry(
        status: json['status'] as String? ?? '',
        changedAt: json['changedAt'] != null
            ? DateTime.tryParse(json['changedAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}

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
  final Map<String, dynamic>? paymentRecipient;
  final String? note;
  final String? cancelledReason;
  final String? cancelReason;
  final List<OrderItemModel> items;
  final Map<String, dynamic>? shippingAddressSnapshot;
  final List<StatusHistoryEntry> statusHistory;
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
    this.paymentRecipient,
    this.note,
    this.cancelledReason,
    this.cancelReason,
    required this.items,
    this.shippingAddressSnapshot,
    this.statusHistory = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      orderCode: json['orderCode'] as String? ?? '',
      buyerId: (json['buyerId'] is Map ? json['buyerId']['_id'] : json['buyerId'])?.toString() ?? '',
      sellerId: (json['sellerId'] is Map ? json['sellerId']['_id'] : json['sellerId'])?.toString() ?? '',
      status: json['status'] as String? ?? 'pending',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] as String?,
      paymentStatus: json['paymentStatus'] as String? ?? 'unpaid',
      paymentRecipient: json['paymentRecipient'] is Map
          ? Map<String, dynamic>.from(json['paymentRecipient'] as Map)
          : null,
      note: json['note'] as String?,
      cancelledReason: json['cancelledReason'] as String?,
      cancelReason: json['cancelReason'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      shippingAddressSnapshot: json['shippingAddressSnapshot'] as Map<String, dynamic>?,
      statusHistory: (json['statusHistory'] as List<dynamic>?)
              ?.map((e) => StatusHistoryEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
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
    // Backend productSnapshot stores imageUrl as string
    final url = productSnapshot['imageUrl'];
    if (url is String && url.isNotEmpty) return url;
    // Fallback: images array format
    final imgs = productSnapshot['images'];
    if (imgs is List && imgs.isNotEmpty) {
      final first = imgs.first;
      return first is Map ? first['url'] as String? : first as String?;
    }
    return null;
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      productId: (json['productId'] is Map ? json['productId']['_id'] : json['productId'])?.toString(),
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
