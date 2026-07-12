import 'package:flutter/foundation.dart';

import '../models/trace_model.dart';
import '../services/trace_service.dart';

class TraceProvider extends ChangeNotifier {
  TraceProvider(this._service);
  final TraceService _service;

  TraceModel? _trace;
  bool _isLoading = false;
  String? _errorMessage;

  TraceModel? get trace => _trace;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> lookup(String code) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _trace = await _service.getByCode(code);
      return true;
    } catch (error) {
      _trace = null;
      _errorMessage = error.toString().replaceFirst('Exception:', '').trim();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
