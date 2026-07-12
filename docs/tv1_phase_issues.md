# TV1 Sprint Tracker & Phase Implementation Status

Tài liệu này theo dõi và cập nhật chi tiết các nhiệm vụ thuộc **TV1 (Auth, Profile, Infrastructure)** trong dự án AgriLink Mobile, bám sát theo danh sách 9 task trong Sprint Tracker từ 03/07 – 17/07/2026.

---

## 1. Bảng Trạng Thái & Độ Ưu Tiên Các Nhiệm Vụ (Phân Theo Phase)

### 🔴 Phase 1: Core Auth, Session & Role Integration (Ưu tiên: RẤT CAO)
Mục tiêu: Đảm bảo luồng đăng ký bằng SĐT, xác thực Firebase OTP, đồng bộ tài khoản với Backend, tự động duy trì phiên đăng nhập và phân quyền hoạt động ổn định.

| # | Task | API Endpoint | Files liên quan | Trạng thái | Độ ưu tiên | Ghi chú |
|---|---|---|---|---|---|---|
| **9** | **Sync Firebase → Express BE** | `POST /auth/sync` | `api_service.dart`, `auth_provider.dart`, `auth.controller.js` | <span style="color:green">**DONE**</span> | **Rất cao** | Đã triển khai endpoint sync Firebase ID Token và trả về JWT accessToken/refreshToken |
| **8** | **Firebase Phone Auth thật** | Firebase API | `auth_provider.dart`, `otp_screen.dart` | <span style="color:green">**DONE**</span> | **Cao** | Hỗ trợ luồng `verifyPhoneNumber` thật kèm cơ chế Mock bypass tự động trên Web/Dev |
| **3** | **Refresh token / Retry 401** | `POST /auth/refresh` | `api_service.dart`, `token_storage.dart` | <span style="color:green">**DONE**</span> | **Cao** | Interceptor của Dio tự động chặn 401, làm mới token và gọi lại request bị lỗi |
| **5** | **PUT /users/me/role** | `PUT /users/me/role` | `role_picker_screen.dart`, `users.controller.js` | <span style="color:green">**DONE**</span> | **Cao** | Đã hoàn thiện API cập nhật vai trò trên cả Backend lẫn Mobile cho các tài khoản mới sync |
| **4** | **Logout API** | `POST /auth/logout` | `auth_provider.dart`, `auth.controller.js` | <span style="color:green">**DONE**</span> | **Trung bình** | Thu hồi session trên backend và xóa sạch token dưới bộ nhớ cache thiết bị |

---

### 🟡 Phase 2: Profile Edit & Storage Service (Ưu tiên: CAO)
Mục tiêu: Quản lý thông tin tài khoản nông dân/đại lý và tích hợp upload ảnh đại diện/ảnh sản phẩm.

| # | Task | API Endpoint | Files liên quan | Trạng thái | Độ ưu tiên | Ghi chú |
|---|---|---|---|---|---|---|
| **1** | **Profile edit screen** | `PATCH /users/me` | `edit_profile_screen.dart`, `profile_screen.dart` | <span style="color:green">**DONE**</span> | **Cao** | Cho phép sửa tên, địa chỉ, đổi ảnh đại diện và lưu trực tiếp lên DB |
| **2** | **Avatar upload (StorageService)** | `POST /storage/images/upload` | `storage_service.dart`, `edit_profile_screen.dart` | <span style="color:green">**DONE**</span> | **Cao** | Viết dưới dạng multipart-form upload để TV2 dùng chung cho luồng upload ảnh sản phẩm |

---

### 🔵 Phase 3: Shared Components & Geography Dropdown (Ưu tiên: TRUNG BÌNH)
Mục tiêu: Tối ưu UI code, tạo widget tái sử dụng và hỗ trợ nhập địa chỉ qua danh mục Tỉnh/Huyện.

| # | Task | API Endpoint | Files liên quan | Trạng thái | Độ ưu tiên | Ghi chú |
|---|---|---|---|---|---|---|
| **6** | **Shared form widgets** | — | `lib/widgets/common/form_field.dart` | <span style="color:green">**DONE**</span> | **Trung bình** | Cung cấp `AgriFormField` chuẩn hóa toàn team, kế thừa đầy đủ validator từ `AgriTextField` |
| **7** | **Geography dropdown** | `GET /geography/provinces`, `/districts` | `geography_service.dart`, `province_picker.dart` | <span style="color:green">**DONE**</span> | **Trung bình** | Bổ sung module `/geography` vào Backend Express và xây dựng Widget dropdown tỉnh/huyện trên Mobile |

---

## 2. Chi Tiết Thực Hiện & Thay Đổi Kiến Trúc

### 🛠️ Phía Backend (AgriLink_Mobile_BE)
1. **User Schema (`user.model.js`):**
   - Loại bỏ tính chất bắt buộc (`required: true`) của `email` và `passwordHash` để người dùng đăng ký bằng SĐT qua Firebase có thể đăng nhập bình thường.
   - Thêm trường `phone` và `firebaseUid` có thuộc tính `unique: true` và `sparse: true` (tránh xung đột database đối với các tài khoản không đăng ký bằng phone).
2. **Auth Controller (`auth.controller.js`):**
   - Triển khai hàm `syncFirebase`:
     - Nhận Firebase ID Token thông qua Authorization Header.
     - Phân tích token để lấy `uid` và `phone_number`.
     - Tìm kiếm hoặc tự động tạo tài khoản mới nếu chưa tồn tại (mặc định role trống `''` để yêu cầu chọn vai trò ở màn hình kế tiếp).
     - Tạo JWT Access/Refresh Token và lưu mã băm refresh token vào DB.
3. **Geography Module (`geography.controller.js` & `geography.router.js`):**
   - Triển khai mock data địa lý chính thức gồm các tỉnh thành lớn (Lâm Đồng, Hà Nội, TP. HCM, Cần Thơ, Đắk Lắk) kèm theo danh sách các quận huyện tương ứng.
   - Expose endpoints: `GET /api/v1/geography/provinces` và `GET /api/v1/geography/districts?provinceId=X`.
   - Đăng ký vào route gốc `src/app.js`.

---

### 📱 Phía Mobile (agrilink)
1. **Firebase Phone Auth (`auth_provider.dart`):**
   - Hàm `sendOtp` gọi `verifyPhoneNumber` gửi mã SMS thật.
   - Hàm `verifyOtp` sử dụng credential nhận được từ SMS code và đồng bộ hóa với backend thông qua API `syncUser`.
   - Hỗ trợ cơ chế Mock Bypass tự động trên Web/Chrome và các môi trường phát triển chưa config SHA-1 Firebase, giúp việc kiểm thử không bị gián đoạn (OTP mặc định: `123456`).
2. **Geography Integration (`geography_service.dart` & `province_picker.dart`):**
   - Cài đặt `GeographyService` kết nối trực tiếp đến các endpoint địa lý mới xây dựng trên Backend.
   - Xây dựng `ProvincePicker` widget kế thừa giao diện dropdown chuẩn của app, tự động tải danh sách quận/huyện dựa trên tỉnh/thành phố được chọn.
3. **Shared Form Widget (`form_field.dart`):**
   - Expose class `AgriFormField` phục vụ team CRUD sản phẩm và order sử dụng, đồng bộ phong cách thiết kế toàn dự án.

---

## 3. Hướng Dẫn Chạy & Bàn Giao Kỹ Thuật

### Cách chạy kiểm thử Luồng Phone Auth & Dropdown địa lý:
1. Đảm bảo Backend Express đang chạy trên cổng `5000`:
   ```bash
   npm run dev
   ```
2. Khởi chạy ứng dụng mobile:
   ```bash
   flutter run
   ```
3. Khi test ở màn hình Login, nhập SĐT và click "Gửi OTP". Trình giả lập/Web sẽ nhận diện mock hoặc gửi tin nhắn thật (nếu đã cấu hình Firebase Console). Sử dụng mã xác thực `123456` để hoàn thành quá trình sync.
4. Widget địa chỉ có thể sử dụng `ProvincePicker` để lấy dữ liệu tỉnh/huyện trực tiếp từ API thay vì nhập text thủ công.
