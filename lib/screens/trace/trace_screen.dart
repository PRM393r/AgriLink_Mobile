import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/providers/trace_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/common/agri_button.dart';

class TraceScreen extends StatefulWidget {
  const TraceScreen({super.key});

  @override
  State<TraceScreen> createState() => _TraceScreenState();
}

class _TraceScreenState extends State<TraceScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _lookup([String? scannedCode]) async {
    final code = scannedCode ?? _codeController.text;
    if (scannedCode != null) _codeController.text = scannedCode;
    final found = await context.read<TraceProvider>().lookup(code);
    if (found && mounted) {
      Navigator.pushNamed(context, AppRouter.traceDetail);
    }
  }

  Future<void> _openScanner() async {
    final code = await Navigator.pushNamed<String>(context, AppRouter.qrScanner);
    if (code != null && mounted) await _lookup(code);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TraceProvider>();
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(title: const Text('Truy xuất nguồn gốc')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                color: AppColors.primaryUltraLight,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(Icons.qr_code_scanner_rounded, size: 78, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text('Kiểm tra hành trình sản phẩm', style: AppTextStyles.sectionTitle, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Quét mã QR trên nhãn hoặc nhập mã để xem nơi sản xuất, chứng nhận và toàn bộ quá trình canh tác.',
              style: AppTextStyles.body.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              onSubmitted: (_) => _lookup(),
              decoration: const InputDecoration(
                labelText: 'Mã truy xuất',
                hintText: 'Ví dụ: AGL-TOMATO-001',
                prefixIcon: Icon(Icons.tag_rounded),
              ),
            ),
            if (provider.errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(provider.errorMessage!, style: AppTextStyles.caption.copyWith(color: AppColors.error)),
            ],
            const SizedBox(height: 20),
            AgriButton(
              text: provider.isLoading ? 'Đang tra cứu...' : 'Tra cứu mã',
              onPressed: provider.isLoading ? null : _lookup,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: provider.isLoading ? null : _openScanner,
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Quét bằng camera'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text('Mã demo: AGL-TOMATO-001', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
