class AppStrings {
  const AppStrings._();

  // App
  static const String appName = 'AgriLink';

  // Authentication
  static const String loginTitle = 'Chào mừng đến với AgriLink';
  static const String loginSubtitle = 'Kết nối nông nghiệp Việt';
  static const String phoneLabel = 'Số điện thoại';
  static const String phoneHint = 'Nhập số điện thoại của bạn';
  static const String passwordLabel = 'Mật khẩu';
  static const String passwordHint = 'Nhập mật khẩu của bạn';
  static const String loginWithPassword = 'Đăng nhập bằng mật khẩu';
  static const String loginWithOtp = 'Đăng nhập bằng OTP';
  static const String sendOtpButton = 'Gửi mã OTP';
  static const String loginButton = 'Đăng nhập';
  static const String otpTitle = 'Xác thực mã OTP';
  static const String otpSubtitle = 'Mã OTP đã được gửi đến số';
  static const String otpHint = 'Nhập 6 chữ số';
  static const String verifyButton = 'Xác nhận';
  static const String resendOtpPrompt = 'Chưa nhận được mã?';
  static const String resendOtpButton = 'Gửi lại';
  static const String seconds = 'giây';

  // Role Picker
  static const String rolePickerTitle = 'Bạn là ai?';
  static const String rolePickerSubtitle = 'Chọn vai trò phù hợp nhất để chúng tôi tối ưu hóa trải nghiệm của bạn';
  static const String roleFarmer = 'Nông dân';
  static const String roleFarmerDesc = 'Đăng bán nông sản và theo dõi giá thị trường.';
  static const String roleCooperative = 'Hợp tác xã';
  static const String roleCooperativeDesc = 'Quản lý thành viên, vùng trồng và lịch thu hoạch.';
  static const String roleBuyer = 'Người mua';
  static const String roleBuyerDesc = 'Tìm kiếm nguồn cung nông sản chất lượng cao.';
  static const String roleSupplier = 'Nhà cung cấp';
  static const String roleSupplierDesc = 'Cung cấp phân bón, hạt giống và vật tư.';
  static const String roleEnterprise = 'Doanh nghiệp';
  static const String roleEnterpriseDesc = 'Thu mua & chế biến nông sản';
  static const String roleState = 'Cơ quan Nhà nước';
  static const String roleStateDesc = 'Quản lý & giám sát thị trường';
  static const String roleLogistics = 'Đơn vị Vận chuyển';
  static const String roleLogisticsDesc = 'Vận chuyển & kho lạnh';

  // Dashboards & Home
  static const String welcome = 'Xin chào';
  static const String logout = 'Đăng xuất';
  static const String confirmLogout = 'Bạn có chắc chắn muốn đăng xuất?';
  static const String cancel = 'Hủy';
  static const String marketplace = 'Chợ nông sản';
  static const String marketPrices = 'Giá cả thị trường';
  static const String traceability = 'Truy xuất nguồn gốc';
  static const String notifications = 'Thông báo';
  
  // Errors
  static const String errorInvalidPhone = 'Số điện thoại không hợp lệ';
  static const String errorInvalidOtp = 'Mã OTP không hợp lệ';
  static const String errorSomethingWentWrong = 'Đã có lỗi xảy ra. Vui lòng thử lại!';
  static const String errorNetwork = 'Lỗi kết nối mạng';
}
