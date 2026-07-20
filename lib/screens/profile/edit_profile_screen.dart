import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/services/auth_provider.dart';
import '../../data/services/storage_service.dart';
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
  final _addressController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _bankAccountNameController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _isUploadingAvatar = false;
  String? _bankCode;

  static const _banks = <String, String>{
    'MB': 'MB Bank',
    'VCB': 'Vietcombank',
    'BIDV': 'BIDV',
    'ICB': 'VietinBank',
    'TCB': 'Techcombank',
    'ACB': 'ACB',
    'VPB': 'VPBank',
    'TPB': 'TPBank',
    'VBA': 'Agribank',
  };

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _fullNameController.text = user?.fullName ?? '';
    _emailController.text = user?.email ?? '';
    _avatarUrlController.text = user?.avatarUrl ?? '';
    _addressController.text = user?.address ?? '';
    _bankCode = user?.bankInfo.bankCode.isNotEmpty == true
        ? user!.bankInfo.bankCode
        : null;
    _bankAccountController.text = user?.bankInfo.accountNumber ?? '';
    _bankAccountNameController.text = user?.bankInfo.accountName ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _avatarUrlController.dispose();
    _addressController.dispose();
    _bankAccountController.dispose();
    _bankAccountNameController.dispose();
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

  String? _validateAvatarUrl(String? value) {
    final avatarUrl = value?.trim() ?? '';
    if (avatarUrl.isEmpty) return null;

    final uri = Uri.tryParse(avatarUrl);
    if (uri == null || !uri.isAbsolute || uri.host.isEmpty) {
      return 'Đường dẫn ảnh không hợp lệ';
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return 'Đường dẫn ảnh phải bắt đầu bằng http hoặc https';
    }
    return null;
  }

  Future<void> _pickAndUploadAvatar() async {
    final apiService = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).apiService;
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (picked == null) return;

    setState(() => _isUploadingAvatar = true);
    try {
      final storageService = StorageService(apiService);
      final url = await storageService.uploadImage(picked);
      if (!mounted) return;

      setState(() => _avatarUrlController.text = url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tải ảnh đại diện thành công!')),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceAll('Exception:', '').trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isSeller = authProvider.currentUser?.isFarmer == true ||
        authProvider.currentUser?.isSupplier == true;
    authProvider.updateProfile(
      fullName: _fullNameController.text.trim(),
      avatarUrl: _avatarUrlController.text.trim().isEmpty
          ? null
          : _avatarUrlController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      bankInfo: isSeller
          ? {
              'bankCode': _bankCode ?? '',
              'accountNumber': _bankAccountController.text.trim(),
              'accountName': _bankAccountNameController.text.trim().toUpperCase(),
            }
          : null,
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
    final isSeller = authProvider.currentUser?.isFarmer == true ||
        authProvider.currentUser?.isSupplier == true;
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
                  child: Column(
                    children: [
                      CircleAvatar(
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
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _isUploadingAvatar
                            ? null
                            : _pickAndUploadAvatar,
                        icon: _isUploadingAvatar
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.upload_rounded),
                        label: Text(
                          _isUploadingAvatar
                              ? 'Đang tải ảnh...'
                              : 'Tải ảnh lên',
                        ),
                      ),
                    ],
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
                  readOnly: true,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Email dùng để đăng nhập nên chưa chỉnh sửa trong MVP.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.muted),
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
                  'Bạn có thể tải ảnh từ thiết bị hoặc dán URL ảnh hợp lệ.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 16),
                AgriTextField(
                  controller: _addressController,
                  hintText: 'Địa chỉ',
                  keyboardType: TextInputType.streetAddress,
                  maxLines: 2,
                  prefixIcon: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.muted,
                  ),
                ),
                if (isSeller) ...[
                  const SizedBox(height: 28),
                  Text(
                    'Thông tin nhận chuyển khoản',
                    style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thông tin này được dùng để tạo VietQR khi khách thanh toán đơn hàng của bạn.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _bankCode,
                    decoration: const InputDecoration(
                      labelText: 'Ngân hàng',
                      prefixIcon: Icon(Icons.account_balance_outlined),
                    ),
                    items: _banks.entries
                        .map((entry) => DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _bankCode = value),
                    validator: (value) {
                      final hasAny = _bankAccountController.text.trim().isNotEmpty ||
                          _bankAccountNameController.text.trim().isNotEmpty;
                      if (hasAny && value == null) return 'Vui lòng chọn ngân hàng';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AgriTextField(
                    controller: _bankAccountController,
                    hintText: 'Số tài khoản',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.numbers_rounded, color: AppColors.muted),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      final hasAny = _bankCode != null ||
                          _bankAccountNameController.text.trim().isNotEmpty;
                      if (!hasAny && text.isEmpty) return null;
                      if (!RegExp(r'^\d{6,20}$').hasMatch(text)) {
                        return 'Số tài khoản phải gồm 6-20 chữ số';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AgriTextField(
                    controller: _bankAccountNameController,
                    hintText: 'Tên chủ tài khoản',
                    prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.muted),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      final hasAny = _bankCode != null ||
                          _bankAccountController.text.trim().isNotEmpty;
                      if (hasAny && text.isEmpty) return 'Vui lòng nhập tên chủ tài khoản';
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 32),
                AgriButton(
                  text: 'Lưu thay đổi',
                  onPressed: _isUploadingAvatar ? null : _saveProfile,
                  isLoading: authProvider.isLoading || _isUploadingAvatar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
