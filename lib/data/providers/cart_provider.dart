import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item_model.dart';
import '../models/product_model.dart';

/// Local cart with SharedPreferences persistence (MVP — no BE cart API).
class CartProvider extends ChangeNotifier {
  static const String _storageKey = 'agrilink_cart_v1';

  final Map<String, CartItem> _items = {};
  bool _loaded = false;
  bool _isLoading = false;

  bool get isLoaded => _loaded;
  bool get isLoading => _isLoading;

  List<CartItem> get items => _items.values.toList();

  int get totalItems {
    var total = 0;
    for (final item in _items.values) {
      total += item.quantity;
    }
    return total;
  }

  double get totalPrice {
    var total = 0.0;
    for (final item in _items.values) {
      total += item.price * item.quantity;
    }
    return total;
  }

  bool get isEmpty => _items.isEmpty;

  /// Load cart from disk. Safe to call multiple times; only first load applies.
  Future<void> load() async {
    if (_loaded) return;
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _items.clear();
          for (final entry in decoded) {
            if (entry is! Map) continue;
            try {
              final item = CartItem.fromJson(Map<String, dynamic>.from(entry));
              if (item.productId.isEmpty || item.quantity <= 0) continue;
              _items[item.productId] = item;
            } catch (e) {
              debugPrint('CartProvider: skip corrupt item: $e');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('CartProvider.load failed: $e');
    } finally {
      _loaded = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload =
          _items.values.map((item) => item.toJson()).toList(growable: false);
      await prefs.setString(_storageKey, jsonEncode(payload));
    } catch (e) {
      debugPrint('CartProvider.persist failed: $e');
    }
  }

  void addItem(ProductModel product, int quantity) {
    if (quantity <= 0) return;
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existing) => existing.copyWith(
          quantity: existing.quantity + quantity,
        ),
      );
    } else {
      _items[product.id] = CartItem(
        productId: product.id,
        productName: product.name,
        price: product.pricePerUnit,
        unit: product.unit,
        quantity: quantity,
        imageUrl: product.images.isNotEmpty ? product.images.first : null,
      );
    }
    notifyListeners();
    _persist();
  }

  void removeItem(String productId) {
    if (!_items.containsKey(productId)) return;
    _items.remove(productId);
    notifyListeners();
    _persist();
  }

  void updateQuantity(String productId, int quantity) {
    if (!_items.containsKey(productId)) return;

    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    _items.update(
      productId,
      (existing) => existing.copyWith(quantity: quantity),
    );
    notifyListeners();
    _persist();
  }

  void clearCart() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
    _persist();
  }
}
