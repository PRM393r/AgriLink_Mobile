import 'package:flutter_test/flutter_test.dart';
import 'package:agrilink/data/models/user_model.dart';

void main() {
  group('UserModel role parsing (email-first auth)', () {
    test('empty role stays empty and is not a valid role', () {
      final user = UserModel.fromJson({
        'id': 'u1',
        'fullName': 'New User',
        'email': 'new@agrilink.vn',
        'role': '',
      });

      expect(user.role, '');
      expect(user.isValidRole, isFalse);
      expect(user.isCustomer, isFalse);
    });

    test('missing role does not default to customer', () {
      final user = UserModel.fromJson({
        '_id': 'u2',
        'fullName': 'No Role',
        'email': 'norole@agrilink.vn',
      });

      expect(user.role, '');
      expect(user.isValidRole, isFalse);
    });

    test('valid roles are recognized', () {
      for (final role in ['customer', 'farmer', 'supplier']) {
        final user = UserModel.fromJson({
          'id': 'u-$role',
          'email': '$role@agrilink.vn',
          'role': role,
        });
        expect(user.isValidRole, isTrue, reason: role);
      }
    });
  });
}
