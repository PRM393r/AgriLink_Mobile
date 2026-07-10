import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceElevated,
      appBar: AppBar(
        title: const Text('Chính sách bảo mật'),
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
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: Colors.white, size: 40),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Thông tin của bạn được bảo vệ',
                          style: AppTextStyles.subtitle.copyWith(
                              color: Colors.white, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('AgriLink cam kết bảo mật dữ liệu cá nhân của bạn.',
                          style: AppTextStyles.caption
                              .copyWith(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _PrivacySection(
            icon: Icons.person_outline,
            color: Color(0xFF2563EB),
            title: 'Thông tin chúng tôi thu thập',
            content:
                '• Họ tên, số điện thoại, email khi đăng ký\n'
                '• Địa chỉ giao hàng bạn cung cấp\n'
                '• Lịch sử đơn hàng và giao dịch\n'
                '• Vị trí GPS (chỉ khi bạn dùng tính năng theo dõi đơn hàng)\n'
                '• Thông tin thiết bị và hệ điều hành',
          ),
          const _PrivacySection(
            icon: Icons.how_to_reg_outlined,
            color: Color(0xFF16A34A),
            title: 'Chúng tôi dùng thông tin để làm gì?',
            content:
                '• Xử lý đơn hàng và giao hàng\n'
                '• Gửi thông báo về trạng thái đơn hàng\n'
                '• Cải thiện trải nghiệm sử dụng ứng dụng\n'
                '• Hỗ trợ khách hàng khi có vấn đề\n'
                '• Ngăn chặn gian lận và vi phạm',
          ),
          const _PrivacySection(
            icon: Icons.share_outlined,
            color: Color(0xFFD97706),
            title: 'Chúng tôi có chia sẻ thông tin không?',
            content:
                'AgriLink KHÔNG bán thông tin của bạn cho bên thứ ba.\n\n'
                'Thông tin chỉ được chia sẻ với:\n'
                '• Người bán: để xử lý đơn hàng của bạn\n'
                '• Đơn vị vận chuyển: để giao hàng đến địa chỉ của bạn\n'
                '• Cơ quan pháp luật: khi có yêu cầu hợp lệ theo pháp luật Việt Nam',
          ),
          const _PrivacySection(
            icon: Icons.lock_outline,
            color: Color(0xFF7C3AED),
            title: 'Bảo mật thông tin',
            content:
                '• Mật khẩu được mã hóa bcrypt — AgriLink không thể đọc mật khẩu của bạn\n'
                '• Kết nối HTTPS mã hóa toàn bộ dữ liệu truyền\n'
                '• Token đăng nhập hết hạn sau 15 phút, refresh sau 7 ngày\n'
                '• Dữ liệu lưu trên server đặt tại Việt Nam',
          ),
          const _PrivacySection(
            icon: Icons.manage_accounts_outlined,
            color: Color(0xFFDC2626),
            title: 'Quyền của bạn',
            content:
                'Bạn có quyền:\n'
                '• Xem và chỉnh sửa thông tin cá nhân bất cứ lúc nào\n'
                '• Yêu cầu xóa tài khoản và toàn bộ dữ liệu\n'
                '• Từ chối nhận email quảng cáo\n'
                '• Tắt quyền truy cập GPS trong cài đặt thiết bị\n\n'
                'Để yêu cầu xóa dữ liệu, liên hệ: privacy@agrilink.vn',
          ),
          const _PrivacySection(
            icon: Icons.cookie_outlined,
            color: Color(0xFF0891B2),
            title: 'Cookie & Dữ liệu cục bộ',
            content:
                'Ứng dụng lưu một số dữ liệu trên điện thoại của bạn:\n'
                '• Token đăng nhập (được mã hóa)\n'
                '• Cài đặt ứng dụng\n'
                '• Cache sản phẩm để tải nhanh hơn\n\n'
                'Bạn có thể xóa bằng cách gỡ và cài lại ứng dụng.',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(
              'Cập nhật lần cuối: 10/07/2026\n'
              'Liên hệ về bảo mật: privacy@agrilink.vn',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.muted, height: 1.6),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String content;

  const _PrivacySection({
    required this.icon,
    required this.color,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.07),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(title,
                        style: AppTextStyles.subtitle.copyWith(
                            color: color, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(content,
                  style: AppTextStyles.body.copyWith(
                      fontSize: 14, height: 1.7, color: AppColors.body)),
            ),
          ],
        ),
      ),
    );
  }
}
