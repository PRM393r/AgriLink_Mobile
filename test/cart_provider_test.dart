import 'package:flutter_test/flutter_test.dart';
import 'package:agrilink/data/providers/cart_provider.dart';
import 'package:agrilink/data/models/product_model.dart';

ProductModel _makeProduct({
  String id = 'p1',
  String name = 'Cà chua',
  double price = 35000,
  String unit = 'kg',
}) =>
    ProductModel(
      id: id,
      name: name,
      description: 'Test product',
      pricePerUnit: price,
      unit: unit,
      availableQuantity: 100,
      minOrderQuantity: 1,
      farmingType: 'organic',
      status: 'active',
      viewCount: 0,
      sellerId: 'seller1',
      sellerType: 'farmer',
      images: const [],
      certifications: const [],
      category: 'Rau củ',
    );

void main() {
  group('CartProvider', () {
    late CartProvider cart;

    setUp(() {
      cart = CartProvider();
    });

    test('starts empty', () {
      expect(cart.items, isEmpty);
      expect(cart.totalItems, 0);
      expect(cart.totalPrice, 0.0);
    });

    test('addItem adds product', () {
      cart.addItem(_makeProduct(), 2);
      expect(cart.items.length, 1);
      expect(cart.totalItems, 2);
      expect(cart.totalPrice, 70000.0);
    });

    test('addItem same product merges quantity', () {
      final p = _makeProduct();
      cart.addItem(p, 1);
      cart.addItem(p, 3);
      expect(cart.items.length, 1);
      expect(cart.totalItems, 4);
    });

    test('addItem different products creates separate entries', () {
      cart.addItem(_makeProduct(id: 'p1'), 1);
      cart.addItem(_makeProduct(id: 'p2', name: 'Bưởi'), 2);
      expect(cart.items.length, 2);
      expect(cart.totalItems, 3);
    });

    test('removeItem deletes product', () {
      cart.addItem(_makeProduct(id: 'p1'), 2);
      cart.addItem(_makeProduct(id: 'p2', name: 'Bưởi'), 1);
      cart.removeItem('p1');
      expect(cart.items.length, 1);
      expect(cart.items.first.productId, 'p2');
    });

    test('removeItem non-existent product does nothing', () {
      cart.addItem(_makeProduct(), 1);
      cart.removeItem('nonexistent');
      expect(cart.items.length, 1);
    });

    test('updateQuantity changes quantity', () {
      cart.addItem(_makeProduct(), 2);
      cart.updateQuantity('p1', 5);
      expect(cart.totalItems, 5);
    });

    test('updateQuantity to 0 removes item', () {
      cart.addItem(_makeProduct(), 2);
      cart.updateQuantity('p1', 0);
      expect(cart.items, isEmpty);
    });

    test('updateQuantity negative removes item', () {
      cart.addItem(_makeProduct(), 2);
      cart.updateQuantity('p1', -1);
      expect(cart.items, isEmpty);
    });

    test('clearCart empties everything', () {
      cart.addItem(_makeProduct(id: 'p1'), 1);
      cart.addItem(_makeProduct(id: 'p2', name: 'Bưởi'), 3);
      cart.clearCart();
      expect(cart.items, isEmpty);
      expect(cart.totalItems, 0);
      expect(cart.totalPrice, 0.0);
    });

    test('totalPrice calculates correctly with multiple items', () {
      cart.addItem(_makeProduct(id: 'p1', price: 35000), 2); // 70000
      cart.addItem(_makeProduct(id: 'p2', price: 20000), 3); // 60000
      expect(cart.totalPrice, 130000.0);
    });

    test('notifies listeners on addItem', () {
      int notifyCount = 0;
      cart.addListener(() => notifyCount++);
      cart.addItem(_makeProduct(), 1);
      expect(notifyCount, 1);
    });

    test('notifies listeners on removeItem', () {
      cart.addItem(_makeProduct(), 1);
      int notifyCount = 0;
      cart.addListener(() => notifyCount++);
      cart.removeItem('p1');
      expect(notifyCount, 1);
    });

    test('notifies listeners on clearCart', () {
      cart.addItem(_makeProduct(), 1);
      int notifyCount = 0;
      cart.addListener(() => notifyCount++);
      cart.clearCart();
      expect(notifyCount, 1);
    });
  });
}

