import 'package:flutter/foundation.dart';

import '../models/market_price_model.dart';
import '../services/market_price_service.dart';

class MarketPriceProvider extends ChangeNotifier {
  MarketPriceProvider(this._service);

  final MarketPriceService _service;
  List<MarketPriceModel> _items = [];
  List<String> _categories = [];
  List<String> _regions = [];
  String? _selectedCategory;
  String? _selectedRegion;
  String? _errorMessage;
  bool _isLoading = false;

  List<MarketPriceModel> get items => List.unmodifiable(_items);
  List<String> get categories => List.unmodifiable(_categories);
  List<String> get regions => List.unmodifiable(_regions);
  String? get selectedCategory => _selectedCategory;
  String? get selectedRegion => _selectedRegion;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> fetchPrices() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _service.fetchPrices(
        category: _selectedCategory,
        region: _selectedRegion,
      );
      _items = result.items;
      _categories = result.categories;
      _regions = result.regions;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception:', '').trim();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectCategory(String? value) async {
    _selectedCategory = value;
    await fetchPrices();
  }

  Future<void> selectRegion(String? value) async {
    _selectedRegion = value;
    await fetchPrices();
  }
}
