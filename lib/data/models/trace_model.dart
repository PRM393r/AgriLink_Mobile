class TraceEventModel {
  const TraceEventModel({
    required this.title,
    required this.description,
    required this.location,
    required this.occurredAt,
  });

  final String title;
  final String description;
  final String location;
  final DateTime? occurredAt;

  factory TraceEventModel.fromJson(Map<String, dynamic> json) => TraceEventModel(
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        location: json['location'] as String? ?? '',
        occurredAt: DateTime.tryParse(json['occurredAt']?.toString() ?? ''),
      );
}

class TraceModel {
  const TraceModel({
    required this.traceCode,
    required this.productName,
    required this.batchCode,
    required this.imageUrl,
    required this.farmerName,
    required this.farmName,
    required this.origin,
    required this.farmingMethod,
    required this.certification,
    required this.harvestDate,
    required this.expiryDate,
    required this.timeline,
  });

  final String traceCode;
  final String productName;
  final String batchCode;
  final String imageUrl;
  final String farmerName;
  final String farmName;
  final String origin;
  final String farmingMethod;
  final String certification;
  final DateTime? harvestDate;
  final DateTime? expiryDate;
  final List<TraceEventModel> timeline;

  factory TraceModel.fromJson(Map<String, dynamic> json) => TraceModel(
        traceCode: json['traceCode'] as String? ?? '',
        productName: json['productName'] as String? ?? '',
        batchCode: json['batchCode'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ?? '',
        farmerName: json['farmerName'] as String? ?? '',
        farmName: json['farmName'] as String? ?? '',
        origin: json['origin'] as String? ?? '',
        farmingMethod: json['farmingMethod'] as String? ?? '',
        certification: json['certification'] as String? ?? '',
        harvestDate: DateTime.tryParse(json['harvestDate']?.toString() ?? ''),
        expiryDate: DateTime.tryParse(json['expiryDate']?.toString() ?? ''),
        timeline: (json['timeline'] as List? ?? const [])
            .whereType<Map>()
            .map((item) => TraceEventModel.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
      );
}
