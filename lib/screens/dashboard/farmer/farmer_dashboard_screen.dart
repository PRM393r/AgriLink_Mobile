import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class FarmerDashboardScreen extends StatelessWidget {
  const FarmerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tổng quan Nông dân')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chào Nông dân', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildItem('Giá nông sản', Icons.bar_chart, AppColors.primary),
                  _buildItem('Thời tiết nông vụ', Icons.wb_sunny, AppColors.accent),
                  _buildItem('Hỏi chuyên gia', Icons.help, AppColors.harvest),
                  _buildItem('Cửa hàng vật tư', Icons.shopping_bag, AppColors.primaryLight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String title, IconData icon, Color color) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
