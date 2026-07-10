import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  int? _openIndex;

  static const _faqs = [
    _FaqItem(
      category: 'Đặt hàng',
      icon: Icons.shopping_cart_outlined,
      color: Color(0xFF16A34A),
      question: 'Làm sao để đặt mua nông sản?',
      answer:
          '1. Vào mục "Chợ nông sản" ở trang chủ\n'
          '2. Chọn sản phẩm bạn muốn mua\n'
          '3. Chọn số lượng rồi nhấn "Thêm vào giỏ"\n'
          '4. Vào giỏ hàng, kiểm tra lại rồi nhấn "Đặt hàng"\n'
          '5. Điền địa chỉ nhận hàng và chọn cách thanh toán\n'
          '6. Nhấn "Xác nhận đặt hàng" là xong!',
    ),
    _FaqItem(
      category: 'Đặt hàng',
      icon: Icons.shopping_cart_outlined,
      color: Color(0xFF16A34A),
      question: 'Đặt hàng tối thiểu bao nhiêu?',
      answer:
          'Mỗi sản phẩm có số lượng đặt tối thiểu khác nhau, được ghi rõ trên trang sản phẩm. '
          'Ví dụ: "Đặt tối thiểu 5 kg". Nếu bạn đặt ít hơn, app sẽ báo lỗi để bạn điều chỉnh.',
    ),
    _FaqItem(
      category: 'Đặt hàng',
      icon: Icons.shopping_cart_outlined,
      color: Color(0xFF16A34A),
      question: 'Tôi có thể hủy đơn hàng không?',
      answer:
          'Bạn chỉ có thể hủy đơn khi đơn hàng đang ở trạng thái "Chờ xác nhận". '
          'Sau khi người bán đã xác nhận thì không hủy được nữa. '
          'Vào "Lịch sử đơn hàng" → chọn đơn → nhấn "Hủy đơn" nếu còn trong thời gian cho phép.',
    ),
    _FaqItem(
      category: 'Thanh toán',
      icon: Icons.payment_outlined,
      color: Color(0xFF2563EB),
      question: 'Có những hình thức thanh toán nào?',
      answer:
          '• COD (trả tiền mặt khi nhận hàng): An toàn nhất, được khuyên dùng\n'
          '• Chuyển khoản ngân hàng: Chuyển trước khi giao\n'
          '• VNPay: Thanh toán qua ví điện tử\n\n'
          'Với nông dân lần đầu dùng, chúng tôi khuyên chọn COD cho dễ.',
    ),
    _FaqItem(
      category: 'Thanh toán',
      icon: Icons.payment_outlined,
      color: Color(0xFF2563EB),
      question: 'COD là gì?',
      answer:
          'COD là viết tắt của "Cash On Delivery" — nghĩa là bạn chỉ trả tiền khi hàng đã giao đến tay. '
          'Shipper (người giao hàng) sẽ thu tiền mặt khi giao. '
          'Đây là hình thức an toàn và phổ biến nhất ở nông thôn.',
    ),
    _FaqItem(
      category: 'Giao hàng',
      icon: Icons.local_shipping_outlined,
      color: Color(0xFFD97706),
      question: 'Mất bao lâu để nhận được hàng?',
      answer:
          'Thời gian giao hàng tùy vào khoảng cách và địa điểm:\n'
          '• Cùng tỉnh: 1–2 ngày\n'
          '• Khác tỉnh gần: 2–3 ngày\n'
          '• Vùng xa, nông thôn: 3–5 ngày\n\n'
          'Bạn có thể theo dõi đơn hàng trong mục "Lịch sử đơn hàng".',
    ),
    _FaqItem(
      category: 'Giao hàng',
      icon: Icons.local_shipping_outlined,
      color: Color(0xFFD97706),
      question: 'Làm sao để theo dõi đơn hàng?',
      answer:
          '1. Vào "Tài khoản" → "Lịch sử đơn hàng"\n'
          '2. Chọn đơn hàng muốn theo dõi\n'
          '3. Khi đơn ở trạng thái "Đang giao hàng", nhấn nút "Theo dõi" để xem vị trí thực tế trên bản đồ.',
    ),
    _FaqItem(
      category: 'Tài khoản',
      icon: Icons.person_outline,
      color: Color(0xFF7C3AED),
      question: 'Tôi quên mật khẩu thì làm thế nào?',
      answer:
          '1. Ở màn hình đăng nhập, nhấn "Quên mật khẩu"\n'
          '2. Nhập email đã đăng ký\n'
          '3. Hệ thống gửi mã OTP 6 số về email\n'
          '4. Nhập mã OTP rồi đặt mật khẩu mới\n\n'
          'Lưu ý: Kiểm tra thư mục Spam nếu không thấy email.',
    ),
    _FaqItem(
      category: 'Tài khoản',
      icon: Icons.person_outline,
      color: Color(0xFF7C3AED),
      question: 'Tôi muốn bán nông sản trên AgriLink thì làm sao?',
      answer:
          '1. Đăng ký tài khoản mới\n'
          '2. Chọn vai trò "Nông dân" hoặc "Nhà cung cấp"\n'
          '3. Hoàn thiện hồ sơ và thông tin trang trại\n'
          '4. Vào Dashboard → "Thêm sản phẩm" để đăng sản phẩm\n'
          '5. Chờ hệ thống duyệt (thường trong 24 giờ)',
    ),
    _FaqItem(
      category: 'Sự cố',
      icon: Icons.report_outlined,
      color: Color(0xFFDC2626),
      question: 'Tôi nhận được hàng kém chất lượng thì phải làm gì?',
      answer:
          '1. Chụp ảnh hàng kém chất lượng ngay khi nhận\n'
          '2. Vào đơn hàng đó → nhấn "Báo cáo vấn đề"\n'
          '3. Mô tả vấn đề và đính kèm ảnh\n'
          '4. Đội hỗ trợ AgriLink sẽ liên hệ trong vòng 24 giờ\n\n'
          'Bạn có thể yêu cầu hoàn tiền hoặc đổi hàng tùy tình huống.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<_FaqEntry>>{};
    for (int i = 0; i < _faqs.length; i++) {
      final f = _faqs[i];
      grouped.putIfAbsent(f.category, () => []);
      grouped[f.category]!.add(_FaqEntry(index: i, item: f));
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceElevated,
      appBar: AppBar(
        title: const Text('Câu hỏi thường gặp'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Header banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B4332), Color(0xFF40916C)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent, color: Colors.white, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chúng tôi luôn sẵn sàng hỗ trợ!',
                            style: AppTextStyles.subtitle.copyWith(
                                color: Colors.white, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('Tìm câu trả lời nhanh cho các thắc mắc phổ biến.',
                            style: AppTextStyles.caption.copyWith(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Grouped FAQ
          ...grouped.entries.map((entry) {
            final category = entry.key;
            final items = entry.value;
            final first = items.first.item;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Icon(first.icon, color: first.color, size: 18),
                      const SizedBox(width: 8),
                      Text(category,
                          style: AppTextStyles.overline.copyWith(
                              color: first.color,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: items.asMap().entries.map((e) {
                        final isLast = e.key == items.length - 1;
                        final entry2 = e.value;
                        final isOpen = _openIndex == entry2.index;
                        return Column(
                          children: [
                            InkWell(
                              onTap: () => setState(() =>
                                  _openIndex = isOpen ? null : entry2.index),
                              borderRadius: BorderRadius.vertical(
                                top: e.key == 0
                                    ? const Radius.circular(14)
                                    : Radius.zero,
                                bottom: isLast
                                    ? const Radius.circular(14)
                                    : Radius.zero,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        entry2.item.question,
                                        style: AppTextStyles.body.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isOpen
                                              ? first.color
                                              : AppColors.ink,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    AnimatedRotation(
                                      turns: isOpen ? 0.5 : 0,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: isOpen
                                            ? first.color
                                            : AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AnimatedCrossFade(
                              firstChild: const SizedBox.shrink(),
                              secondChild: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: first.color.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: first.color
                                            .withValues(alpha: 0.15)),
                                  ),
                                  child: Text(
                                    entry2.item.answer,
                                    style: AppTextStyles.body.copyWith(
                                      fontSize: 13,
                                      color: AppColors.body,
                                      height: 1.7,
                                    ),
                                  ),
                                ),
                              ),
                              crossFadeState: isOpen
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 200),
                            ),
                            if (!isLast)
                              Divider(
                                  height: 1,
                                  indent: 16,
                                  color: const Color(0xFFE5E7EB)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          }),

          // Contact footer
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.headset_mic_outlined,
                      color: AppColors.primary, size: 32),
                  const SizedBox(height: 10),
                  Text('Vẫn chưa tìm được câu trả lời?',
                      style: AppTextStyles.subtitle
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('Liên hệ hỗ trợ: support@agrilink.vn',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text('Hotline: 1800 xxxx (miễn phí, 8h–17h)',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.muted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String category;
  final IconData icon;
  final Color color;
  final String question;
  final String answer;
  const _FaqItem({
    required this.category,
    required this.icon,
    required this.color,
    required this.question,
    required this.answer,
  });
}

class _FaqEntry {
  final int index;
  final _FaqItem item;
  const _FaqEntry({required this.index, required this.item});
}
