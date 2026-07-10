import 'package:flutter_test/flutter_test.dart';
import 'package:agrilink/data/models/order_model.dart';

void main() {
  group('OrderModel', () {
    final baseJson = {
      'id':        'order_1',
      'orderCode': 'AGL-20260710-001',
      'buyerId':   'buyer_1',
      'sellerId':  'seller_1',
      'status':    'pending',
      'subtotal':  70000.0,
      'shippingFee': 0.0,
      'totalAmount': 70000.0,
      'paymentMethod': 'cod',
      'paymentStatus': 'unpaid',
      'items': [
        {
          '_id':      'item_1',
          'productId': 'prod_1',
          'productSnapshot': {'name': 'Cà chua', 'unit': 'kg'},
          'quantity':   2,
          'unitPrice':  35000.0,
          'totalPrice': 70000.0,
        },
      ],
      'shippingAddressSnapshot': {
        'recipientName': 'Buyer',
        'phone': '0901234567',
        'address': 'HCM',
      },
      'createdAt': '2026-07-10T08:00:00.000Z',
      'updatedAt': '2026-07-10T08:00:00.000Z',
    };

    test('fromJson parses correctly', () {
      final order = OrderModel.fromJson(baseJson);
      expect(order.id, 'order_1');
      expect(order.orderCode, 'AGL-20260710-001');
      expect(order.status, 'pending');
      expect(order.totalAmount, 70000.0);
      expect(order.items.length, 1);
    });

    test('statusLabel returns Vietnamese label', () {
      final statuses = {
        'pending':   'Chờ xác nhận',
        'confirmed': 'Đã xác nhận',
        'preparing': 'Đang chuẩn bị',
        'shipping':  'Đang giao hàng',
        'delivered': 'Đã giao',
        'cancelled': 'Đã hủy',
      };
      for (final entry in statuses.entries) {
        final order = OrderModel.fromJson({...baseJson, 'status': entry.key});
        expect(order.statusLabel, entry.value,
            reason: 'status ${entry.key} should map to ${entry.value}');
      }
    });

    test('isPending returns true only for pending', () {
      final pending   = OrderModel.fromJson({...baseJson, 'status': 'pending'});
      final confirmed = OrderModel.fromJson({...baseJson, 'status': 'confirmed'});
      expect(pending.isPending, isTrue);
      expect(confirmed.isPending, isFalse);
    });

    test('items parsed correctly', () {
      final order = OrderModel.fromJson(baseJson);
      final item = order.items.first;
      expect(item.quantity, 2);
      expect(item.unitPrice, 35000.0);
      expect(item.totalPrice, 70000.0);
      expect(item.productSnapshot['name'], 'Cà chua');
    });

    test('createdAt parsed as DateTime', () {
      final order = OrderModel.fromJson(baseJson);
      expect(order.createdAt, isA<DateTime>());
      expect(order.createdAt.year, 2026);
    });
  });

  group('CreateOrderRequest', () {
    test('toJson serializes correctly', () {
      final req = CreateOrderRequest(
        items: [CreateOrderItem(productId: 'p1', quantity: 2)],
        deliveryName: 'Buyer',
        deliveryPhone: '0901234567',
        address: '123 HCM',
        paymentMethod: 'cod',
        note: 'Giao buổi sáng',
      );

      final json = req.toJson();
      expect(json['paymentMethod'], 'cod');
      expect(json['note'], 'Giao buổi sáng');
      expect((json['items'] as List).first['quantity'], 2);
      expect(json['shippingAddressSnapshot']['recipientName'], 'Buyer');
      expect(json['shippingAddressSnapshot']['phone'], '0901234567');
    });

    test('toJson includes note as null when not provided', () {
      final req = CreateOrderRequest(
        items: [CreateOrderItem(productId: 'p1', quantity: 1)],
        deliveryName: 'Buyer',
        deliveryPhone: '0901234567',
        address: 'HCM',
        paymentMethod: 'bank_transfer',
      );
      final json = req.toJson();
      expect(json['paymentMethod'], 'bank_transfer');
      expect(json['note'], isNull);
    });
  });
}

