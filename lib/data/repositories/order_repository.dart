import 'package:dio/dio.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class OrderRepository {
  final ApiService _apiService;

  OrderRepository(this._apiService);

  // Backend gộp items theo sellerId; giỏ hàng nhiều seller → nhiều order được tạo.
  // Response: order đơn lẻ khi 1 seller, { orders: [...] } khi nhiều seller.
  Future<List<OrderModel>> createOrder(CreateOrderRequest request) async {
    try {
      final response = await _apiService.post(
        ApiConstants.orders,
        data: request.toJson(),
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is Map) {
        final payload = Map<String, dynamic>.from(data['data'] as Map);
        if (payload['orders'] is List) {
          return (payload['orders'] as List)
              .whereType<Map>()
              .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
        return [OrderModel.fromJson(payload)];
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

  Future<OrderModel> confirmPayment(String id) async {
    try {
      final response = await _apiService.patch(
        '${ApiConstants.orders}/$id/payment-confirm',
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
        return OrderModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Xác nhận thanh toán thất bại');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Xác nhận thanh toán thất bại');
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

  // Tạo payment link PayOS cho 1 order (paymentMethod=payos). Trả về checkoutUrl để mở trình duyệt/WebView.
  Future<Map<String, dynamic>> createPayosPaymentLink(String orderId) async {
    try {
      final response = await _apiService.post('/payments/payos/orders/$orderId');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is Map) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }
      throw Exception('Không tạo được liên kết thanh toán PayOS');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không tạo được liên kết thanh toán PayOS');
    }
  }

  // Poll trạng thái thanh toán sau khi buyer quay lại app từ trình duyệt PayOS.
  Future<String> getPayosPaymentStatus(String orderId) async {
    try {
      final response = await _apiService.get('/payments/payos/orders/$orderId/status');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is Map) {
        return (data['data']['paymentStatus'] as String?) ?? 'unpaid';
      }
      return 'unpaid';
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không kiểm tra được trạng thái thanh toán');
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
