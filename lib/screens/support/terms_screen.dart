import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceElevated,
      appBar: AppBar(
        title: const Text('Điều khoản sử dụng'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _LastUpdated(date: 'Cập nhật: 10/07/2026'),
          SizedBox(height: 20),
          _Section(
            number: '1',
            title: 'Chấp nhận điều khoản',
            content:
                'Khi sử dụng ứng dụng AgriLink, bạn đồng ý tuân theo các điều khoản sử dụng này. '
                'Nếu bạn không đồng ý với bất kỳ phần nào, vui lòng ngừng sử dụng ứng dụng.',
          ),
          _Section(
            number: '2',
            title: 'Dịch vụ AgriLink cung cấp',
            content:
                'AgriLink là nền tảng kết nối người mua và người bán nông sản, nông cụ tại Việt Nam. '
                'Chúng tôi cung cấp:\n'
                '• Chợ nông sản trực tuyến\n'
                '• Hệ thống theo dõi đơn hàng\n'
                '• Công cụ quản lý kho cho nông dân\n'
                '• Hệ thống đánh giá và phản hồi\n\n'
                'AgriLink không phải bên bán hàng trực tiếp. Chúng tôi là nền tảng trung gian '
                'kết nối người mua và người bán.',
          ),
          _Section(
            number: '3',
            title: 'Quyền và nghĩa vụ của người dùng',
            content:
                'Người dùng cam kết:\n'
                '• Cung cấp thông tin chính xác khi đăng ký tài khoản\n'
                '• Không sử dụng app cho mục đích gian lận, lừa đảo\n'
                '• Không đăng thông tin sản phẩm giả mạo hoặc hàng nhái\n'
                '• Giữ bảo mật thông tin đăng nhập\n'
                '• Thông báo ngay khi phát hiện tài khoản bị xâm nhập',
          ),
          _Section(
            number: '4',
            title: 'Quy định về giao dịch',
            content:
                '• Giá sản phẩm do người bán quyết định\n'
                '• Phí vận chuyển tính theo khoảng cách và trọng lượng\n'
                '• Người mua có thể hủy đơn trước khi người bán xác nhận\n'
                '• Tranh chấp giao dịch sẽ được giải quyết theo quy trình hòa giải của AgriLink\n'
                '• AgriLink có quyền tạm khóa tài khoản vi phạm',
          ),
          _Section(
            number: '5',
            title: 'Chính sách hoàn tiền',
            content:
                'Người mua được hoàn tiền trong các trường hợp:\n'
                '• Hàng không đúng mô tả\n'
                '• Hàng bị hư hỏng khi giao\n'
                '• Đơn hàng không được giao sau 10 ngày\n\n'
                'Yêu cầu hoàn tiền cần gửi trong vòng 48 giờ sau khi nhận hàng, '
                'kèm ảnh chụp bằng chứng.',
          ),
          _Section(
            number: '6',
            title: 'Giới hạn trách nhiệm',
            content:
                'AgriLink không chịu trách nhiệm về:\n'
                '• Chất lượng sản phẩm do người bán cung cấp sai thông tin\n'
                '• Thiệt hại gián tiếp phát sinh từ việc sử dụng dịch vụ\n'
                '• Sự gián đoạn dịch vụ do lỗi kỹ thuật ngoài tầm kiểm soát',
          ),
          _Section(
            number: '7',
            title: 'Thay đổi điều khoản',
            content:
                'AgriLink có thể cập nhật điều khoản sử dụng vào bất kỳ lúc nào. '
                'Người dùng sẽ được thông báo qua email hoặc thông báo trong ứng dụng. '
                'Việc tiếp tục sử dụng sau khi cập nhật được coi là đồng ý với điều khoản mới.',
          ),
          _Section(
            number: '8',
            title: 'Liên hệ',
            content:
                'Mọi thắc mắc về điều khoản sử dụng, vui lòng liên hệ:\n'
                '• Email: legal@agrilink.vn\n'
                '• Hotline: 1800 xxxx\n'
                '• Địa chỉ: Việt Nam',
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String number;
  final String title;
  final String content;

  const _Section({
    required this.number,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(number,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(
              content,
              style: AppTextStyles.body.copyWith(
                  fontSize: 14, height: 1.7, color: AppColors.body),
            ),
          ),
        ],
      ),
    );
  }
}

class _LastUpdated extends StatelessWidget {
  final String date;
  const _LastUpdated({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryUltraLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Text(date,
              style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}
