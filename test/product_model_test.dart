import 'package:flutter_test/flutter_test.dart';
import 'package:agrilink/data/models/product_model.dart';

void main() {
  group('ProductModel.fromJson', () {
    test('parses _id field from MongoDB', () {
      final json = _baseJson({'_id': '6abc123', 'name': 'Cà chua'});
      final p = ProductModel.fromJson(json);
      expect(p.id, '6abc123');
    });

    test('falls back to id field if _id absent', () {
      final json = <String, dynamic>{
        'id': 'fallback_id', 'name': 'Cà chua',
        'pricePerUnit': 10000, 'unit': 'kg',
        'availableQuantity': 10, 'minOrderQuantity': 1,
        'farmingType': 'organic', 'status': 'active',
        'viewCount': 0, 'sellerId': 's1', 'sellerType': 'farmer',
        'images': <dynamic>[], 'certifications': <dynamic>[], 'category': 'Rau củ',
      };
      final p = ProductModel.fromJson(json);
      expect(p.id, 'fallback_id');
    });

    test('parses pricePerUnit as double from int', () {
      final json = _baseJson({'pricePerUnit': 35000});
      final p = ProductModel.fromJson(json);
      expect(p.pricePerUnit, 35000.0);
    });

    test('parses images array of objects {url, isPrimary}', () {
      final json = _baseJson({
        'images': [
          {'url': 'https://example.com/a.jpg', 'isPrimary': true},
          {'url': 'https://example.com/b.jpg', 'isPrimary': false},
        ],
      });
      final p = ProductModel.fromJson(json);
      expect(p.images, ['https://example.com/a.jpg', 'https://example.com/b.jpg']);
    });

    test('filters empty image URLs', () {
      final json = _baseJson({
        'images': [
          {'url': '', 'isPrimary': false},
          {'url': 'https://example.com/real.jpg', 'isPrimary': true},
        ],
      });
      final p = ProductModel.fromJson(json);
      expect(p.images, ['https://example.com/real.jpg']);
    });

    test('parses certifications array of objects {name}', () {
      final json = _baseJson({
        'certifications': [
          {'name': 'VietGAP'},
          {'name': 'Organic'},
        ],
      });
      final p = ProductModel.fromJson(json);
      expect(p.certifications, ['VietGAP', 'Organic']);
    });

    test('parses sellerId from populated object', () {
      final json = _baseJson({
        'sellerId': {'_id': 'seller_123', 'fullName': 'Nguyen Van An'},
      });
      final p = ProductModel.fromJson(json);
      expect(p.sellerId, 'seller_123');
      expect(p.sellerName, 'Nguyen Van An');
    });

    test('parses sellerId as string when not populated', () {
      final json = _baseJson({'sellerId': 'seller_456'});
      final p = ProductModel.fromJson(json);
      expect(p.sellerId, 'seller_456');
      expect(p.sellerName, isNull);
    });

    test('parses province field', () {
      final json = _baseJson({'province': 'Lâm Đồng'});
      final p = ProductModel.fromJson(json);
      expect(p.province, 'Lâm Đồng');
    });

    test('viewCount casts num to int', () {
      final json = _baseJson({'viewCount': 42});
      final p = ProductModel.fromJson(json);
      expect(p.viewCount, 42);
    });

    test('defaults empty list for images when null', () {
      final json = _baseJson({});
      final p = ProductModel.fromJson(json);
      expect(p.images, isEmpty);
      expect(p.certifications, isEmpty);
    });

    test('defaults to empty string for missing fields', () {
      final p = ProductModel.fromJson({'_id': 'x'});
      expect(p.name, '');
      expect(p.unit, '');
      expect(p.category, '');
    });
  });
}

Map<String, dynamic> _baseJson([Map<String, dynamic>? overrides]) => {
  '_id':              'test_id',
  'name':             'Test Product',
  'description':      'Test',
  'pricePerUnit':     10000,
  'unit':             'kg',
  'availableQuantity': 50,
  'minOrderQuantity': 1,
  'farmingType':      'organic',
  'status':           'active',
  'viewCount':        0,
  'sellerId':         'seller1',
  'sellerType':       'farmer',
  'images':           <dynamic>[],
  'certifications':   <dynamic>[],
  'category':         'Rau củ',
  ...?overrides,
};
