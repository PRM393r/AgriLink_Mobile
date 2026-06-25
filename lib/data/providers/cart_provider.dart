import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get totalItems {
    int total = 0;
    _items.forEach((key, item) {
      total += item.quantity;
    });
    return total;
  }

  double get totalPrice {
    double total = 0.0;
    _items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  void addItem(ProductModel product, int quantity) {
    if (_items.containsKey(product.id)) {
      // update quantity
      _items.update(
        product.id,
        (existing) => existing.copyWith(
          quantity: existing.quantity + quantity,
        ),
      );
    } else {
      // add new item
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          productId: product.id,
          productName: product.name,
          price: product.pricePerUnit,
          unit: product.unit,
          quantity: quantity,
          imageUrl: product.images.isNotEmpty ? product.images.first : null,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (!_items.containsKey(productId)) return;

    if (quantity <= 0) {
      removeItem(productId);
    } else {
      _items.update(
        productId,
        (existing) => existing.copyWith(quantity: quantity),
      );
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
