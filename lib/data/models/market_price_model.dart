class MarketPriceModel {
  const MarketPriceModel({
    required this.id,
    required this.productName,
    required this.category,
    required this.region,
    required this.province,
    required this.unit,
    required this.price,
    required this.previousPrice,
    required this.source,
    this.recordedAt,
  });

  final String id;
  final String productName;
  final String category;
  final String region;
  final String province;
  final String unit;
  final double price;
  final double previousPrice;
  final String source;
  final DateTime? recordedAt;

  double get change => price - previousPrice;
  double get changePercent => previousPrice == 0 ? 0 : change / previousPrice * 100;

  factory MarketPriceModel.fromJson(Map<String, dynamic> json) {
    return MarketPriceModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      productName: json['productName'] as String? ?? '',
      category: json['category'] as String? ?? '',
      region: json['region'] as String? ?? '',
      province: json['province'] as String? ?? '',
      unit: json['unit'] as String? ?? 'kg',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      previousPrice: (json['previousPrice'] as num?)?.toDouble() ?? 0,
      source: json['source'] as String? ?? '',
      recordedAt: DateTime.tryParse(json['recordedAt']?.toString() ?? ''),
    );
  }
}
