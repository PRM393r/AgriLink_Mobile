import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class HowToBuyScreen extends StatefulWidget {
  const HowToBuyScreen({super.key});

  @override
  State<HowToBuyScreen> createState() => _HowToBuyScreenState();
}

class _HowToBuyScreenState extends State<HowToBuyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceElevated,
      appBar: AppBar(
        title: const Text('Hướng dẫn sử dụng'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.muted,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Hướng dẫn mua'),
            Tab(text: 'Hướng dẫn bán'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBuyGuide(),
          _buildSellGuide(),
        ],
      ),
    );
  }

  Widget _buildBuyGuide() {
    const steps = [
      _Step(
        step: 1,
        icon: Icons.search_rounded,
        title: 'Tìm sản phẩm',
        description:
            'Vào mục "Chợ nông sản" ở trang chủ. '
            'Bạn có thể tìm kiếm theo tên, lọc theo loại (rau, củ, quả, nông cụ...) '
            'hoặc xem tất cả sản phẩm đang bán.',
        tip: 'Mẹo: Dùng bộ lọc để tìm sản phẩm ở tỉnh gần bạn, giao hàng nhanh hơn!',
        color: Color(0xFF2563EB),
      ),
      _Step(
        step: 2,
        icon: Icons.info_outline_rounded,
        title: 'Xem chi tiết sản phẩm',
        description:
            'Nhấn vào sản phẩm để xem:\n'
            '• Giá tiền (đồng/kg hoặc đồng/cái)\n'
            '• Số lượng còn trong kho\n'
            '• Số lượng đặt tối thiểu\n'
            '• Chứng nhận chất lượng (VietGAP, Organic...)\n'
            '• Thông tin nhà vườn và tỉnh thành',
        tip: 'Mẹo: Chọn sản phẩm có chứng nhận VietGAP hoặc Organic để đảm bảo chất lượng.',
        color: Color(0xFF16A34A),
      ),
      _Step(
        step: 3,
        icon: Icons.add_shopping_cart_rounded,
        title: 'Thêm vào giỏ hàng',
        description:
            'Chọn số lượng bạn muốn mua (chú ý số lượng tối thiểu), '
            'sau đó nhấn nút "Thêm vào giỏ" màu xanh ở dưới cùng. '
            'Bạn có thể thêm nhiều sản phẩm từ nhiều nhà vườn vào giỏ.',
        tip: 'Lưu ý: Nếu đặt dưới số lượng tối thiểu, app sẽ báo lỗi — hãy tăng số lượng lên.',
        color: Color(0xFFD97706),
      ),
      _Step(
        step: 4,
        icon: Icons.shopping_bag_outlined,
        title: 'Kiểm tra giỏ hàng',
        description:
            'Nhấn vào biểu tượng giỏ hàng (góc trên phải). '
            'Kiểm tra lại:\n'
            '• Tên sản phẩm đúng chưa\n'
            '• Số lượng đúng chưa\n'
            '• Tổng tiền phù hợp chưa\n\n'
            'Rồi nhấn "Đặt hàng".',
        tip: '',
        color: Color(0xFF7C3AED),
      ),
      _Step(
        step: 5,
        icon: Icons.location_on_outlined,
        title: 'Điền địa chỉ giao hàng',
        description:
            'Điền đầy đủ:\n'
            '• Họ tên người nhận\n'
            '• Số điện thoại (để shipper gọi khi đến)\n'
            '• Địa chỉ: số nhà, đường, xã/phường, huyện/quận, tỉnh/thành\n\n'
            'Địa chỉ càng chi tiết, giao hàng càng nhanh!',
        tip: 'Mẹo: Ghi thêm ghi chú "Gọi trước khi đến" nếu nhà khó tìm.',
        color: Color(0xFFDC2626),
      ),
      _Step(
        step: 6,
        icon: Icons.payment_outlined,
        title: 'Chọn thanh toán',
        description:
            'Có 3 cách thanh toán:\n'
            '• COD: Trả tiền mặt khi nhận hàng (khuyên dùng)\n'
            '• Chuyển khoản: Chuyển trước vào tài khoản người bán\n'
            '• VNPay: Thanh toán qua ví điện tử\n\n'
            'Nếu lần đầu mua, chọn COD là an toàn nhất!',
        tip: '',
        color: Color(0xFF0891B2),
      ),
      _Step(
        step: 7,
        icon: Icons.check_circle_outline_rounded,
        title: 'Xác nhận và theo dõi',
        description:
            'Nhấn "Xác nhận đặt hàng". Sau đó:\n'
            '• Người bán xác nhận trong 1–2 giờ\n'
            '• Bạn nhận thông báo khi đơn được xác nhận\n'
            '• Theo dõi tiến trình giao hàng trong "Lịch sử đơn hàng"\n'
            '• Khi hàng đang giao, nhấn "Theo dõi" để xem vị trí trên bản đồ',
        tip: 'Bật thông báo để không bỏ lỡ cập nhật đơn hàng!',
        color: Color(0xFF16A34A),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _GuideHeader(
          icon: Icons.shopping_cart_outlined,
          title: 'Mua hàng dễ dàng chỉ 7 bước',
          subtitle: 'Hướng dẫn chi tiết cho người mua lần đầu',
        ),
        const SizedBox(height: 20),
        ...steps.map((s) => _StepCard(step: s)),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSellGuide() {
    const steps = [
      _Step(
        step: 1,
        icon: Icons.person_add_outlined,
        title: 'Đăng ký tài khoản người bán',
        description:
            'Khi đăng ký, chọn vai trò:\n'
            '• "Nông dân": Bán nông sản, rau củ quả\n'
            '• "Nhà cung cấp": Bán nông cụ, vật tư nông nghiệp\n\n'
            'Điền đầy đủ thông tin: tên, số điện thoại, địa chỉ trang trại/kho hàng.',
        tip: '',
        color: Color(0xFF2563EB),
      ),
      _Step(
        step: 2,
        icon: Icons.add_box_outlined,
        title: 'Đăng sản phẩm',
        description:
            'Vào Dashboard → nhấn "Thêm sản phẩm":\n'
            '• Chụp ảnh sản phẩm rõ nét (nhiều góc)\n'
            '• Đặt tên mô tả rõ ràng\n'
            '• Nhập giá và đơn vị (kg, cái, bó...)\n'
            '• Nhập số lượng trong kho\n'
            '• Chọn danh mục phù hợp\n'
            '• Thêm chứng nhận nếu có (VietGAP, Organic...)',
        tip: 'Mẹo: Ảnh đẹp và mô tả chi tiết giúp bán được hàng nhanh hơn!',
        color: Color(0xFF16A34A),
      ),
      _Step(
        step: 3,
        icon: Icons.notifications_outlined,
        title: 'Nhận và xác nhận đơn hàng',
        description:
            'Khi có đơn mới, bạn nhận thông báo ngay lập tức. '
            'Vào "Quản lý đơn hàng" → tab "Chờ xác nhận":\n'
            '• Xem thông tin người mua và địa chỉ\n'
            '• Nhấn "Xác nhận" để chấp nhận đơn\n'
            '• Hoặc "Từ chối" nếu hết hàng',
        tip: 'Xác nhận đơn trong 2 giờ để tạo uy tín tốt!',
        color: Color(0xFFD97706),
      ),
      _Step(
        step: 4,
        icon: Icons.inventory_2_outlined,
        title: 'Chuẩn bị và đóng gói',
        description:
            'Sau khi xác nhận:\n'
            '• Chuyển đơn sang "Đang chuẩn bị"\n'
            '• Đóng gói hàng cẩn thận\n'
            '• Ghi địa chỉ người nhận rõ ràng\n'
            '• Liên hệ đơn vị vận chuyển để lấy hàng',
        tip: '',
        color: Color(0xFF7C3AED),
      ),
      _Step(
        step: 5,
        icon: Icons.local_shipping_outlined,
        title: 'Giao hàng và hoàn tất',
        description:
            'Khi đã giao cho shipper:\n'
            '• Chuyển đơn sang "Đang giao hàng"\n'
            '• Người mua sẽ thấy tiến trình trên bản đồ\n'
            '• Khi giao xong, chuyển sang "Đã giao"\n'
            '• Tiền sẽ được thanh toán theo thỏa thuận',
        tip: 'Bật thông báo để cập nhật trạng thái đơn hàng kịp thời!',
        color: Color(0xFF0891B2),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _GuideHeader(
          icon: Icons.storefront_outlined,
          title: 'Bắt đầu bán hàng trên AgriLink',
          subtitle: 'Hướng dẫn cho nông dân và nhà cung cấp',
        ),
        const SizedBox(height: 20),
        ...steps.map((s) => _StepCard(step: s)),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _GuideHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _GuideHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF40916C)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.subtitle.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: AppTextStyles.caption
                        .copyWith(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Step {
  final int step;
  final IconData icon;
  final String title;
  final String description;
  final String tip;
  final Color color;

  const _Step({
    required this.step,
    required this.icon,
    required this.title,
    required this.description,
    required this.tip,
    required this.color,
  });
}

class _StepCard extends StatelessWidget {
  final _Step step;

  const _StepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number + connector
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: step.color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('${step.step}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(step.icon, color: step.color, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(step.title,
                            style: AppTextStyles.subtitle.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(step.description,
                      style: AppTextStyles.body.copyWith(
                          fontSize: 14, height: 1.7, color: AppColors.body)),
                  if (step.tip.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: step.color.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: step.color.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline,
                              color: step.color, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(step.tip,
                                style: AppTextStyles.caption.copyWith(
                                    color: step.color,
                                    fontSize: 12,
                                    height: 1.5)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
