import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/trace_model.dart';
import '../../data/providers/trace_provider.dart';
import '../../widgets/common/agri_card.dart';

class TraceDetailScreen extends StatelessWidget {
  const TraceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trace = context.watch<TraceProvider>().trace;
    if (trace == null) {
      return const Scaffold(body: Center(child: Text('Không có dữ liệu truy xuất')));
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(title: const Text('Chi tiết nguồn gốc')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          _Header(trace: trace),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Thông tin sản phẩm', style: AppTextStyles.sectionTitle),
                const SizedBox(height: 10),
                AgriCard(
                  child: Column(children: [
                    _InfoRow(icon: Icons.eco_outlined, label: 'Nông trại', value: trace.farmName),
                    _InfoRow(icon: Icons.person_outline, label: 'Người sản xuất', value: trace.farmerName),
                    _InfoRow(icon: Icons.location_on_outlined, label: 'Xuất xứ', value: trace.origin),
                    _InfoRow(icon: Icons.agriculture_outlined, label: 'Phương pháp', value: trace.farmingMethod),
                    if (trace.certification.isNotEmpty)
                      _InfoRow(icon: Icons.verified_outlined, label: 'Chứng nhận', value: trace.certification),
                    _InfoRow(icon: Icons.event_outlined, label: 'Thu hoạch', value: _date(trace.harvestDate)),
                    if (trace.expiryDate != null)
                      _InfoRow(icon: Icons.hourglass_bottom_rounded, label: 'Hạn sử dụng', value: _date(trace.expiryDate)),
                  ]),
                ),
                const SizedBox(height: 22),
                Text('Hành trình sản phẩm', style: AppTextStyles.sectionTitle),
                const SizedBox(height: 12),
                ...trace.timeline.asMap().entries.map((entry) => _TimelineItem(
                  event: entry.value,
                  isLast: entry.key == trace.timeline.length - 1,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _date(DateTime? value) => value == null ? '—' : DateFormat('dd/MM/yyyy').format(value.toLocal());
}

class _Header extends StatelessWidget {
  const _Header({required this.trace});
  final TraceModel trace;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: AppColors.primaryGradient),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: trace.imageUrl.isEmpty
              ? Container(width: 92, height: 92, color: AppColors.primaryUltraLight, child: const Icon(Icons.eco, size: 42))
              : Image.network(trace.imageUrl, width: 92, height: 92, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 92, height: 92, color: AppColors.primaryUltraLight, child: const Icon(Icons.eco, size: 42))),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(trace.productName, style: AppTextStyles.sectionTitle.copyWith(color: Colors.white)),
            const SizedBox(height: 6),
            Text('Lô: ${trace.batchCode}', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
            Text('Mã: ${trace.traceCode}', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
          ],
        )),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 10),
        SizedBox(width: 100, child: Text(label, style: AppTextStyles.caption)),
        Expanded(child: Text(value, style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.event, required this.isLast});
  final TraceEventModel event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final date = event.occurredAt == null ? '' : DateFormat('dd/MM/yyyy').format(event.occurredAt!.toLocal());
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(width: 28, child: Column(children: [
          Container(width: 14, height: 14, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
          if (!isLast) Expanded(child: Container(width: 2, color: AppColors.primarySoft)),
        ])),
        const SizedBox(width: 10),
        Expanded(child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(event.title, style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w700))),
              Text(date, style: AppTextStyles.overline),
            ]),
            const SizedBox(height: 4),
            Text(event.description, style: AppTextStyles.caption),
            if (event.location.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('📍 ${event.location}', style: AppTextStyles.overline),
            ],
          ]),
        )),
      ]),
    );
  }
}
