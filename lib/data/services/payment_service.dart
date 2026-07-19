/// Demo-only payment helpers.
///
/// Product decision: payment is **not** going to production VNPay/PayOS.
/// Every non-error path returns [PaymentResult.success] so demo flows always complete.
enum PaymentResult { success, failed, cancelled }

class PaymentService {
  /// Demo flag — keep true for the course MVP.
  static const bool isDemoMode = true;

  static const _supportedMethods = ['cod', 'bank_transfer', 'vnpay', 'payos'];

  static bool isSupported(String method) => _supportedMethods.contains(method);

  /// Always succeeds in demo mode (after a short delay for UX).
  static Future<PaymentResult> processPayment({
    required String orderId,
    required double amount,
    required String method,
  }) async {
    if (method == 'cod') {
      return PaymentResult.success;
    }

    // Simulate network for bank_transfer / mock gateways
    await Future.delayed(const Duration(milliseconds: 600));

    // Demo policy: never fail payment on client.
    if (isDemoMode) return PaymentResult.success;

    return PaymentResult.success;
  }

  static String getDemoBannerText() =>
      'Chế độ demo: bấm xác nhận thanh toán sẽ luôn thành công '
      '(không kết nối cổng thanh toán thật).';

  static String getBankInfo() {
    return 'Ngân hàng: Vietcombank\n'
        'Số TK: 1234567890\n'
        'Chủ TK: CONG TY AGRILINK VIETNAM\n'
        'Nội dung: [Mã đơn hàng]';
  }

  static String getMethodLabel(String method) {
    switch (method) {
      case 'cod':
        return 'Tiền mặt khi nhận hàng';
      case 'bank_transfer':
        return 'Chuyển khoản ngân hàng (demo)';
      case 'vnpay':
        return 'VNPay (demo)';
      case 'payos':
        return 'PayOS (demo)';
      default:
        return method;
    }
  }
}
