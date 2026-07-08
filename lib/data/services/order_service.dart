import '../models/order_model.dart';
import '../repositories/order_repository.dart';

class OrderService {
  final OrderRepository _orderRepository;

  OrderService(this._orderRepository);

  Future<OrderModel> createOrder(CreateOrderRequest request) {
    return _orderRepository.createOrder(request);
  }

  Future<List<OrderModel>> getMyOrders({String? status}) {
    return _orderRepository.getMyOrders(status: status);
  }

  Future<OrderModel> getOrderById(String id) {
    return _orderRepository.getOrderById(id);
  }

  Future<List<OrderModel>> getSellerOrders({String? status}) {
    return _orderRepository.getSellerOrders(status: status);
  }

  Future<OrderModel> updateOrderStatus(String id, String status) {
    return _orderRepository.updateOrderStatus(id, status);
  }

  Future<Map<String, dynamic>> getSellerStats() {
    return _orderRepository.getSellerStats();
  }

  Future<List<Map<String, dynamic>>> getMonthlyRevenue({String type = 'monthly'}) {
    return _orderRepository.getMonthlyRevenue(type: type);
  }
}
