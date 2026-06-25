import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/common/agri_card.dart';

class PricesScreen extends StatelessWidget {
  const PricesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giá cả thị trường'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Bảng giá hôm nay (25/06/2026)',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: 12),
          _buildPriceItem('Cà chua Lâm Đồng', '25,000đ/kg', '+1,500đ', true),
          _buildPriceItem('Khoai tây Đà Lạt', '32,000đ/kg', '-500đ', false),
          _buildPriceItem('Sầu riêng Ri6', '125,000đ/kg', '0đ', null),
          _buildPriceItem('Ớt chuông đỏ', '65,000đ/kg', '+2,000đ', true),
          _buildPriceItem('Bắp cải trắng', '12,000đ/kg', '-1,000đ', false),
        ],
      ),
    );
  }

  Widget _buildPriceItem(String name, String price, String change, bool? isUp) {
    Color changeColor = AppColors.body;
    IconData? icon;
    if (isUp == true) {
      changeColor = AppColors.primary;
      icon = Icons.trending_up;
    } else if (isUp == false) {
      changeColor = AppColors.error;
      icon = Icons.trending_down;
    }

    return AgriCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Khu vực: Tây Nguyên', style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: changeColor),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    change,
                    style: AppTextStyles.caption.copyWith(color: changeColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
