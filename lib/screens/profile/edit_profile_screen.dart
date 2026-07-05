import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/services/auth_provider.dart';
import '../../widgets/common/agri_button.dart';
import '../../widgets/common/agri_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _fullNameController.text = user?.fullName ?? '';
    _emailController.text = user?.email ?? '';
    _avatarUrlController.text = user?.avatarUrl ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập họ tên';
    }
    if (value.trim().length < 2) {
      return 'Họ tên quá ngắn';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return null;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? _validateAvatarUrl(String? value) {
    final avatarUrl = value?.trim() ?? '';
    if (avatarUrl.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(avatarUrl);
    if (uri == null || !uri.isAbsolute || uri.host.isEmpty) {
      return 'Đường dẫn ảnh không hợp lệ';
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return 'Đường dẫn ảnh phải bắt đầu bằng http hoặc https';
    }
    return null;
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final avatarUrl = _avatarUrlController.text.trim();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    authProvider.updateProfile(
      fullName: fullName,
      email: email.isEmpty ? null : email,
      avatarUrl: avatarUrl.isEmpty ? null : avatarUrl,
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật hồ sơ thành công!')),
        );
        Navigator.pop(context);
      },
      onError: (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: AppColors.error),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final avatarUrl = _avatarUrlController.text.trim();
    final avatarUri = Uri.tryParse(avatarUrl);
    final canPreviewAvatar =
        avatarUri != null &&
        avatarUri.isAbsolute &&
        avatarUri.host.isNotEmpty &&
        (avatarUri.scheme == 'http' || avatarUri.scheme == 'https');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chỉnh sửa hồ sơ',
          style: TextStyle(color: AppColors.ink),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: AppColors.primaryUltraLight,
                    backgroundImage: canPreviewAvatar
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: canPreviewAvatar
                        ? null
                        : const Icon(
                            Icons.person,
                            size: 54,
                            color: AppColors.primary,
                          ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Thông tin cá nhân',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 16),
                AgriTextField(
                  controller: _fullNameController,
                  hintText: 'Họ và tên',
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.muted,
                  ),
                  validator: _validateFullName,
                ),
                const SizedBox(height: 16),
                AgriTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColors.muted,
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                AgriTextField(
                  controller: _avatarUrlController,
                  hintText: 'Đường dẫn ảnh đại diện',
                  keyboardType: TextInputType.url,
                  prefixIcon: const Icon(
                    Icons.image_outlined,
                    color: AppColors.muted,
                  ),
                  validator: _validateAvatarUrl,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload ảnh thật sẽ được xử lý ở task Avatar Upload. Hiện tại bạn có thể dùng URL ảnh hợp lệ.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 32),
                AgriButton(
                  text: 'Lưu thay đổi',
                  onPressed: _saveProfile,
                  isLoading: authProvider.isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
