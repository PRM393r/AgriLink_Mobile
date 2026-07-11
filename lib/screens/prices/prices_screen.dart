import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/market_price_model.dart';
import '../../data/providers/market_price_provider.dart';
import '../../widgets/common/agri_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/shimmer_loading.dart';

class PricesScreen extends StatefulWidget {
  const PricesScreen({super.key});

  @override
  State<PricesScreen> createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<MarketPriceProvider>().fetchPrices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MarketPriceProvider>();
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(title: const Text('Giá cả thị trường')),
      body: RefreshIndicator(
        onRefresh: provider.fetchPrices,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _Filters(provider: provider)),
            if (provider.isLoading && provider.items.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList.separated(
                  itemCount: 5,
                  itemBuilder: (_, __) => const ShimmerLoading(height: 112),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                ),
              )
            else if (provider.errorMessage != null && provider.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: 'Không tải được bảng giá',
                  message: provider.errorMessage!,
                  actionLabel: 'Thử lại',
                  onActionPressed: provider.fetchPrices,
                ),
              )
            else if (provider.items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.query_stats_rounded,
                  title: 'Không có dữ liệu phù hợp',
                  message: 'Hãy chọn danh mục hoặc khu vực khác.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                sliver: SliverList.builder(
                  itemCount: provider.items.length,
                  itemBuilder: (_, index) => _PriceTile(item: provider.items[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.provider});
  final MarketPriceProvider provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bảng giá mới nhất', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 4),
          Text('Dữ liệu tổng hợp từ các chợ và đơn vị thị trường', style: AppTextStyles.caption),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Tất cả'),
                  selected: provider.selectedCategory == null,
                  onSelected: (_) => provider.selectCategory(null),
                ),
                ...provider.categories.map((category) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: provider.selectedCategory == category,
                    onSelected: (_) => provider.selectCategory(category),
                  ),
                )),
              ],
            ),
          ),
          if (provider.regions.isNotEmpty) ...[
            const SizedBox(height: 10),
            DropdownButtonFormField<String?>(
              initialValue: provider.selectedRegion,
              decoration: const InputDecoration(
                labelText: 'Khu vực',
                prefixIcon: Icon(Icons.location_on_outlined),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('Tất cả khu vực')),
                ...provider.regions.map((region) => DropdownMenuItem<String?>(value: region, child: Text(region))),
              ],
              onChanged: provider.selectRegion,
            ),
          ],
        ],
      ),
    );
  }
}

class _PriceTile extends StatelessWidget {
  const _PriceTile({required this.item});
  final MarketPriceModel item;

  @override
  Widget build(BuildContext context) {
    final isUp = item.change > 0;
    final isDown = item.change < 0;
    final color = isUp ? AppColors.success : isDown ? AppColors.error : AppColors.muted;
    final icon = isUp ? Icons.trending_up : isDown ? Icons.trending_down : Icons.trending_flat;
    return AgriCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text('${item.province} · ${item.region}', style: AppTextStyles.caption),
                ],
              )),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${_money(item.price)}/${item.unit}', style: AppTextStyles.price.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 3),
                  Row(children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 3),
                    Text('${item.changePercent.abs().toStringAsFixed(1)}%', style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w700)),
                  ]),
                ],
              ),
            ],
          ),
          const Divider(height: 22),
          Text('Nguồn: ${item.source}', style: AppTextStyles.overline),
          if (item.recordedAt != null)
            Text('Cập nhật ${DateFormat('dd/MM/yyyy HH:mm').format(item.recordedAt!.toLocal())}', style: AppTextStyles.overline),
        ],
      ),
    );
  }

  String _money(double value) => NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(value);
}
