import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/common/agri_button.dart';

class TraceScreen extends StatelessWidget {
  const TraceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Truy xuất nguồn gốc'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Quét mã QR sản phẩm',
              style: AppTextStyles.sectionTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Quét mã QR dán trên nhãn sản phẩm để xem thông tin nguồn gốc, nhật ký canh tác và nhà sản xuất.',
              style: AppTextStyles.body.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            // Mock Scanner frame
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 4),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Container(color: Colors.black87),
                      Center(
                        child: Icon(
                          Icons.qr_code_scanner,
                          size: 120,
                          color: AppColors.primaryLight.withValues(alpha: 0.8),
                        ),
                      ),
                      // Animated scanning red line
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 120,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.error.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            AgriButton(
              text: 'Bắt đầu quét mã',
              onPressed: () {
                // Trigger scanner callback
              },
            ),
          ],
        ),
      ),
    );
  }
}
