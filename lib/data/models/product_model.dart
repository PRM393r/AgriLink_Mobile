class ProductModel {
  final String id;
  final String name;
  final String description;
  final double pricePerUnit;
  final String unit;
  final double availableQuantity;
  final double minOrderQuantity;
  final String farmingType;
  final String status;
  final int viewCount;
  final DateTime? harvestDate;
  final DateTime? expiryDate;
  final String sellerId;
  final String sellerType;
  final List<String> images;
  final List<String> certifications;
  final String category;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerUnit,
    required this.unit,
    required this.availableQuantity,
    required this.minOrderQuantity,
    required this.farmingType,
    required this.status,
    required this.viewCount,
    this.harvestDate,
    this.expiryDate,
    required this.sellerId,
    required this.sellerType,
    required this.images,
    required this.certifications,
    required this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pricePerUnit: (json['pricePerUnit'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      availableQuantity: (json['availableQuantity'] as num?)?.toDouble() ?? 0.0,
      minOrderQuantity: (json['minOrderQuantity'] as num?)?.toDouble() ?? 1.0,
      farmingType: json['farmingType'] as String? ?? 'conventional',
      status: json['status'] as String? ?? 'active',
      viewCount: json['viewCount'] as int? ?? 0,
      harvestDate: json['harvestDate'] != null ? DateTime.tryParse(json['harvestDate'] as String) : null,
      expiryDate: json['expiryDate'] != null ? DateTime.tryParse(json['expiryDate'] as String) : null,
      sellerId: json['sellerId'] as String? ?? '',
      sellerType: json['sellerType'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e is Map ? (e['url'] as String? ?? '') : e as String)
              .where((url) => url.isNotEmpty)
              .toList() ??
          const [],
      certifications: (json['certifications'] as List<dynamic>?)
              ?.map((e) => e is Map ? (e['name'] as String? ?? '') : e as String)
              .where((s) => s.isNotEmpty)
              .toList() ??
          const [],
      category: json['category'] is Map
          ? ((json['category'] as Map)['name'] as String? ?? '')
          : (json['category'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pricePerUnit': pricePerUnit,
      'unit': unit,
      'availableQuantity': availableQuantity,
      'minOrderQuantity': minOrderQuantity,
      'farmingType': farmingType,
      'status': status,
      'viewCount': viewCount,
      'harvestDate': harvestDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'sellerId': sellerId,
      'sellerType': sellerType,
      'images': images,
      'certifications': certifications,
      'category': category,
    };
  }
}
