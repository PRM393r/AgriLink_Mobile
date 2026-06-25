import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class RolePickerScreen extends StatefulWidget {
  const RolePickerScreen({super.key});

  @override
  State<RolePickerScreen> createState() => _RolePickerScreenState();
}

class _RolePickerScreenState extends State<RolePickerScreen> {
  String _selectedRole = 'farmer';

  final List<Map<String, String>> _roles = [
    {'id': 'farmer', 'name': 'Nông dân', 'desc': 'Đăng bán nông sản'},
    {'id': 'cooperative', 'name': 'Hợp tác xã', 'desc': 'Quản lý xã viên'},
    {'id': 'buyer', 'name': 'Thương lái', 'desc': 'Thu mua nông sản'},
    {'id': 'supplier', 'name': 'Nhà cung cấp', 'desc': 'Bán vật tư nông nghiệp'},
    {'id': 'enterprise', 'name': 'Doanh nghiệp', 'desc': 'Chế biến & xuất khẩu'},
    {'id': 'state', 'name': 'Cơ quan nhà nước', 'desc': 'Giám sát nông nghiệp'},
    {'id': 'logistics', 'name': 'Vận chuyển', 'desc': 'Giao nhận nông sản'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn vai trò (7 vai trò)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Chọn vai trò của bạn:', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          ..._roles.map((role) {
            return RadioListTile<String>(
              title: Text(role['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(role['desc']!),
              value: role['id']!,
              groupValue: _selectedRole,
              onChanged: (val) {
                setState(() {
                  _selectedRole = val!;
                });
              },
            );
          }),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}
