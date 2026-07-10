import 'package:dio/dio.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class OrderRepository {
  final ApiService _apiService;

  OrderRepository(this._apiService);

  Future<OrderModel> createOrder(CreateOrderRequest request) async {
    try {
      final response = await _apiService.post(
        ApiConstants.orders,
        data: request.toJson(),
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        return OrderModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Tạo đơn hàng thất bại');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Đặt hàng thất bại');
    }
  }

  Future<List<OrderModel>> getMyOrders({String? status}) async {
    try {
      final params = <String, dynamic>{'limit': 50};
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
}
