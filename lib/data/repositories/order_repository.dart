import 'package:dio/dio.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class OrderRepository {
  final ApiService _apiService;

  OrderRepository(this._apiService);

  // Backend gộp items theo sellerId; giỏ hàng nhiều seller → nhiều order được tạo.
  Future<List<OrderModel>> createOrder(CreateOrderRequest request) async {
    try {
      final response = await _apiService.post(
        ApiConstants.orders,
        data: request.toJson(),
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        final inner = data['data'];
        if (inner is List) {
          return inner
              .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [OrderModel.fromJson(inner as Map<String, dynamic>)];
      }
      throw Exception('Tạo đơn hàng thất bại');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Đặt hàng thất bại');
    }
  }

  Future<List<OrderModel>> getMyOrders({String? status}) async {
    try {
      // role=buyer: farmer/supplier cũng có thể xem đơn họ đã mua
      final params = <String, dynamic>{'limit': 50, 'role': 'buyer'};
      if (status != null && status != 'all') params['status'] = status;

      final response = await _apiService.get(
        ApiConstants.orders,
        queryParameters: params,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final inner = data['data'];
        List? list;
        if (inner is List) {
          list = inner;
        } else if (inner is Map && inner['items'] is List) {
          list = inner['items'] as List;
        }
        if (list != null) {
          return list
              .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Lấy đơn hàng thất bại');
    }
  }

  Future<OrderModel> getOrderById(String id) async {
    try {
      final response = await _apiService.get('${ApiConstants.orders}/$id');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        return OrderModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Không tìm thấy đơn hàng');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Lấy chi tiết đơn hàng thất bại');
    }
  }

  Future<OrderModel> updateOrderStatus(String id, String status, {String? cancelReason}) async {
    try {
      final body = <String, dynamic>{'status': status};
      if (cancelReason != null && cancelReason.isNotEmpty) body['cancelReason'] = cancelReason;
      final response = await _apiService.patch(
        '${ApiConstants.orders}/$id/status',
        data: body,
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        return OrderModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Cập nhật trạng thái thất bại');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Cập nhật thất bại');
    }
  }

  Future<List<OrderModel>> getSellerOrders({String? status}) async {
    try {
      final params = <String, dynamic>{'role': 'seller', 'limit': 50};
      if (status != null && status != 'all') params['status'] = status;

      final response = await _apiService.get(
        ApiConstants.orders,
        queryParameters: params,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final inner = data['data'];
        List? list;
        if (inner is List) {
          list = inner;
        } else if (inner is Map && inner['items'] is List) {
          list = inner['items'] as List;
        }
        if (list != null) {
          return list
              .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Lấy đơn hàng thất bại');
    }
  }
  Future<Map<String, dynamic>> getSellerStats() async {
    try {
      final response = await _apiService.get('${ApiConstants.orders}/seller-stats');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        return data['data'] as Map<String, dynamic>;
      }
      return {'totalRevenue': 0, 'totalOrders': 0, 'pendingOrders': 0, 'totalProducts': 0};
    } catch (_) {
      return {'totalRevenue': 0, 'totalOrders': 0, 'pendingOrders': 0, 'totalProducts': 0};
    }
  }

  Future<List<Map<String, dynamic>>> getMonthlyRevenue({String type = 'monthly'}) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.orders}/seller-stats/monthly',
        queryParameters: {'type': type},
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
