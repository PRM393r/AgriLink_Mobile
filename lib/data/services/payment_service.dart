import 'dart:async';

enum PaymentResult { success, failed, cancelled }

class PaymentService {
  static const _supportedMethods = ['cod', 'bank_transfer', 'vnpay', 'payos'];

  static bool isSupported(String method) => _supportedMethods.contains(method);

  /// Mock payment — simulates async payment flow.
  /// Real VNPay/PayOS integration: replace body with deep-link or WebView flow.
  static Future<PaymentResult> processPayment({
    required String orderId,
    required double amount,
    required String method,
  }) async {
    if (method == 'cod') {
      // COD không cần xử lý online
      return PaymentResult.success;
    }

    if (method == 'bank_transfer') {
      // Chuyển khoản: hiện thông tin tài khoản, không cần xử lý thêm
      return PaymentResult.success;
    }

    // VNPay / PayOS mock: simulate 1s network delay
    await Future.delayed(const Duration(seconds: 1));
    return PaymentResult.success;
  }

  static String getBankInfo() {
    return 'Ngân hàng: Vietcombank\n'
        'Số TK: 1234567890\n'
        'Chủ TK: CONG TY AGRILINK VIETNAM\n'
        'Nội dung: [Mã đơn hàng]';
  }

  static String getMethodLabel(String method) {
    switch (method) {
      case 'cod': return 'Tiền mặt khi nhận hàng';
      case 'bank_transfer': return 'Chuyển khoản ngân hàng';
      case 'vnpay': return 'VNPay';
      case 'payos': return 'PayOS';
      default: return method;
    }
  }
}
