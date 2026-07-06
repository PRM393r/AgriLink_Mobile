class BulkListingModel {
  final String id;
  final String cooperativeId;
  final String categoryId;
  final String title;
  final String description;
  final double totalQuantity;
  final String unit;
  final double pricePerUnit;
  final String farmingType;
  final String provinceId;
  final DateTime? harvestDateFrom;
  final DateTime? harvestDateTo;
  final String status;
  final List<dynamic> contributions;

  const BulkListingModel({
    required this.id,
    required this.cooperativeId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.totalQuantity,
    required this.unit,
    required this.pricePerUnit,
    required this.farmingType,
    required this.provinceId,
    this.harvestDateFrom,
    this.harvestDateTo,
    required this.status,
    required this.contributions,
  });

  factory BulkListingModel.fromJson(Map<String, dynamic> json) {
    return BulkListingModel(
      id: json['id'] as String? ?? '',
      cooperativeId: json['cooperativeId'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      totalQuantity: (json['totalQuantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      pricePerUnit: (json['pricePerUnit'] as num?)?.toDouble() ?? 0.0,
      farmingType: json['farmingType'] as String? ?? 'organic',
      provinceId: json['provinceId'] as String? ?? '',
      harvestDateFrom: json['harvestDateFrom'] != null
          ? DateTime.tryParse(json['harvestDateFrom'] as String)
          : null,
      harvestDateTo: json['harvestDateTo'] != null
          ? DateTime.tryParse(json['harvestDateTo'] as String)
          : null,
      status: json['status'] as String? ?? 'pending',
      contributions: json['contributions'] as List<dynamic>? ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cooperativeId': cooperativeId,
      'categoryId': categoryId,
      'title': title,
      'description': description,
      'totalQuantity': totalQuantity,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'farmingType': farmingType,
      'provinceId': provinceId,
      'harvestDateFrom': harvestDateFrom?.toIso8601String(),
      'harvestDateTo': harvestDateTo?.toIso8601String(),
      'status': status,
      'contributions': contributions,
    };
  }
}
