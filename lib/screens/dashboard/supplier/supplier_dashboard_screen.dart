import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class SupplierDashboardScreen extends StatelessWidget {
  const SupplierDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tổng quan Nhà Cung Cấp')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chào Nhà Cung Cấp', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 16),
            const Card(
              child: ListTile(
                leading: Icon(Icons.inventory, color: AppColors.primary),
                title: Text('Kho vật tư đầu vào'),
                subtitle: Text('Số lượng tồn kho và thông tin hóa chất'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
