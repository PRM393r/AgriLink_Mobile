import 'package:flutter/material.dart';
import '../services/wishlist_service.dart';

class WishlistProvider with ChangeNotifier {
  final WishlistService _wishlistService;
  final Set<String> _wishlistProductIds = {};

  WishlistProvider(this._wishlistService);

  Set<String> get wishlistProductIds => _wishlistProductIds;

  bool isWishlisted(String productId) => _wishlistProductIds.contains(productId);

  Future<void> fetchWishlistIds() async {
    try {
      final ids = await _wishlistService.getWishlistIds();
      _wishlistProductIds.clear();
      _wishlistProductIds.addAll(ids);
      notifyListeners();
    } catch (e) {
      // Ignore for MVP, maybe handle later
    }
  }

  Future<void> toggleWishlist(String productId) async {
    final isCurrentlyWishlisted = isWishlisted(productId);
    
    // Optimistic UI update
    if (isCurrentlyWishlisted) {
      _wishlistProductIds.remove(productId);
    } else {
      _wishlistProductIds.add(productId);
    }
    notifyListeners();

    try {
      final isWishlistedOnServer = await _wishlistService.toggleWishlist(productId);
      if (isWishlistedOnServer != !isCurrentlyWishlisted) {
        // Revert if server state is different
        if (isWishlistedOnServer) {
          _wishlistProductIds.add(productId);
        } else {
          _wishlistProductIds.remove(productId);
        }
        notifyListeners();
      }
    } catch (_) {
      // Revert on error
      if (isCurrentlyWishlisted) {
        _wishlistProductIds.add(productId);
      } else {
        _wishlistProductIds.remove(productId);
      }
      notifyListeners();
    }
  }

  void clear() {
    _wishlistProductIds.clear();
    notifyListeners();
  }
}
