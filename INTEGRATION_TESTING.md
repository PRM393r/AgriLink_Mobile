# AgriLink Mobile — Interaction / Integration Testing

> **Mục đích:** Checklist chạy app thật (manual interaction testing) cho **toàn bộ luồng** hiện có trên `develop`.  
> **Không phải** unit test tự động — tester thao tác UI + ghi Pass/Fail.  
> **Ngày:** 19/07/2026 · Stack: Flutter mobile + Express BE (`localhost:5000/api/v1`)

---

## 0. Chuẩn bị môi trường

### 0.1 Backend

```bash
cd AgriLink_Mobile_BE
npm install
# Kiểm tra .env: PORT=5000, MONGODB_URI, JWT_SECRET, REFRESH_SECRET
# MongoDB phải đang chạy
npm run seed
npm start
# hoặc: npm run dev
```

**Smoke BE**

| # | Việc | Kỳ vọng | ☐ |
|---|---|---|---|
| B0.1 | Mở terminal BE, thấy log listen port 5000 | `http://localhost:5000/api/v1` | ☐ |
| B0.2 | Browser/Postman: `GET http://localhost:5000/api/v1/products` | JSON list (hoặc empty có statusCode) — **không** connection refused | ☐ |
| B0.3 | `npm run seed` chạy lại không crash | Seed users + products + prices + trace | ☐ |

### 0.2 Mobile

```bash
cd agrilink
flutter pub get
# Chrome (dev nhanh):
flutter run -d chrome
# Android emulator (API host = 10.0.2.2):
flutter run
```

| # | Việc | Kỳ vọng | ☐ |
|---|---|---|---|
| M0.1 | App mở Splash → Login (nếu chưa token) | Không màn trắng / crash | ☐ |
| M0.2 | Chrome: base URL `localhost:5000` | Login seed được | ☐ |
| M0.3 | Android emulator | Login seed được (10.0.2.2) | ☐ |

### 0.3 Tài khoản seed (mật khẩu: `demo123`)

| Email | Role | Dùng cho |
|---|---|---|
| `customer1@agrilink.vn` | customer | Mua hàng, wishlist, review |
| `farmer1@agrilink.vn` | farmer | CRUD SP, xử lý đơn bán |
| `supplier1@agrilink.vn` | supplier | Tương tự farmer |
| Quick login trên màn Login | Buyer / Farmer / Supplier | Test nhanh (cùng password `demo123`) |

### 0.4 Hằng số demo

| Mục | Giá trị |
|---|---|
| Dev OTP email (không SMTP) | `123456` |
| Trace codes | `AGL-TOMATO-001`, `AGL-DURIAN-001` |
| Payment | **Demo only** — xác nhận QR **luôn thành công** |
| Cart | Local + SharedPreferences (persist) |

### 0.5 Quy ước ghi kết quả

Với mỗi case ghi:

```text
[Pass] / [Fail] / [Skip]
Ghi chú: ...
Screenshot (nếu Fail): ...
```

**Fail** = crash, màn trắng, API lỗi chặn flow, UI không đúng kỳ vọng chính.

---

## 1. Auth — Email first

### IT-AUTH-01 · Splash & session

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Mở app lần đầu (clear data / chưa login) | Splash → **Login** | ☐ |
| 2 | Login seed customer → Home → kill app → mở lại | Splash → **Home** (còn session) | ☐ |
| 3 | Logout → kill app → mở lại | Splash → **Login** | ☐ |

### IT-AUTH-02 · Login seed 3 role

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Quick **Buyer** hoặc `customer1@…` / `demo123` | Home **customer** (tab: Trang chủ, Khám phá, Giỏ, Đơn, Tài khoản) | ☐ |
| 2 | Logout → Quick **Farmer** | Home **farmer** (Tổng quan, Sản phẩm, Đơn, Tài khoản) | ☐ |
| 3 | Logout → Quick **Supplier** | Home **supplier** | ☐ |
| 4 | Sai mật khẩu | SnackBar lỗi, không vào Home | ☐ |

### IT-AUTH-03 · Register → OTP → Login → Role

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Login → **Đăng ký ngay** | Màn Register | ☐ |
| 2 | Email mới + password ≥ 6 + fullName → Đăng ký | Sang **Verify email** | ☐ |
| 3 | OTP `123456` (dev) → Xác thực | Message success → **Login**, email **prefill** | ☐ |
| 4 | Nhập password → Đăng nhập | **RolePicker** (role rỗng) | ☐ |
| 5 | Chọn **customer** → Lưu | Home customer | ☐ |
| 6 | Logout → login lại user vừa tạo | Home **không** bắt RolePicker lại | ☐ |

### IT-AUTH-04 · Role rỗng không lọt customer giả

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | (Nếu có user role `''` trên BE) login user đó | Luôn **RolePicker**, không Home customer | ☐ |

### IT-AUTH-05 · Logout

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Profile → Đăng xuất → Xác nhận | Về Login, back không vào Home | ☐ |

---

## 2. Customer — Marketplace & Product

### IT-MKT-01 · Danh sách & search

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Login customer → tab **Khám phá** / Marketplace | List SP (seed) hoặc empty có UI | ☐ |
| 2 | Loading lần đầu | Có indicator/shimmer, không treo vô hạn | ☐ |
| 3 | Search từ khóa có trong seed | List lọc / còn kết quả hợp lý | ☐ |
| 4 | Search từ khóa không tồn tại | Empty state | ☐ |
| 5 | Filter chip category | List đổi theo category | ☐ |
| 6 | Pull-to-refresh (nếu có) | Reload không crash | ☐ |

### IT-MKT-02 · Product detail

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Mở 1 SP | Tên, giá, mô tả, ảnh (nếu có) | ☐ |
| 2 | Thêm giỏ (+ qty) | SnackBar/ok; badge giỏ tăng | ☐ |
| 3 | Tim / wishlist trên detail | Tim active | ☐ |
| 4 | Section Reviews | List hoặc “Chưa có đánh giá” | ☐ |
| 5 | Viết đánh giá **chưa mua** | Cảnh báo cần nhận hàng / không gửi mù | ☐ |

---

## 3. Customer — Cart & Checkout

### IT-CART-01 · Giỏ hàng

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Giỏ trống | Empty + CTA mua sắm | ☐ |
| 2 | Có item | Đúng tên, giá, qty, total | ☐ |
| 3 | Đổi qty + / − | Total cập nhật | ☐ |
| 4 | Qty về 0 / xóa / swipe delete | Item biến mất | ☐ |
| 5 | Xóa tất cả | Giỏ trống | ☐ |

### IT-CART-02 · Persist

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Add 2 SP khác nhau | Giỏ có 2 dòng | ☐ |
| 2 | **Kill app hoàn toàn** → mở lại → login (nếu cần) | Giỏ **còn** item (SharedPreferences) | ☐ |
| 3 | Checkout COD thành công | Giỏ **trống** sau clear | ☐ |

### IT-CHK-01 · Checkout COD

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Giỏ có hàng → Checkout | Form địa chỉ; prefill tên/SĐT/địa chỉ nếu profile có | ☐ |
| 2 | Bỏ trống bắt buộc → Đặt hàng | Validation lỗi | ☐ |
| 3 | Điền đủ + **COD** → Xác nhận | Loading → **Order Success** + **mã đơn** | ☐ |
| 4 | Xem đơn hàng / Về trang chủ | Điều hướng ổn, không stack lỗi | ☐ |
| 5 | Farmer/Supplier mở checkout (nếu vào được) | Không đặt được / message chỉ customer | ☐ |

### IT-CHK-02 · Checkout chuyển khoản (demo payment)

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Checkout + **Chuyển khoản** | Màn Payment QR (demo banner) | ☐ |
| 2 | QR lỗi mạng (optional) | Vẫn có nút xác nhận demo | ☐ |
| 3 | Bấm **Xác nhận thanh toán demo** | **Luôn** vào success (kể cả BE lỗi) | ☐ |
| 4 | Multi-seller cart (2 seller) | Có thể nhiều đơn / nhiều bước QR | ☐ |

### IT-CHK-03 · Checkout guard

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Vào checkout khi giỏ trống | Empty “giỏ trống”, không form đặt | ☐ |

---

## 4. Customer — Orders

### IT-ORD-01 · History

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Tab Đơn hàng / Lịch sử | Tabs: Tất cả, Chờ, Đang giao, Hoàn thành, Đã hủy | ☐ |
| 2 | Sau COD | Đơn mới ở **Chờ xác nhận** / Tất cả | ☐ |
| 3 | Pull-to-refresh | Reload OK | ☐ |
| 4 | Empty tab | Empty UI, không crash | ☐ |

### IT-ORD-02 · Detail & cancel

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Mở detail đơn pending | Code, items, địa chỉ, status timeline | ☐ |
| 2 | Customer **Hủy đơn** khi pending | Status cancelled; có thể hoàn kho (BE) | ☐ |
| 3 | Hủy khi đã shipping (nếu UI cho) | BE từ chối / không cho | ☐ |

### IT-ORD-03 · Tracking

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Đơn shipping → Tracking (nếu có nút) | Map/timeline; shipper có thể mock | ☐ |
| 2 | Không crash khi thiếu GPS | UI fallback | ☐ |

### IT-ORD-04 · Review từ đơn delivered

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Seller đẩy đơn → **delivered** | Customer thấy Hoàn thành | ☐ |
| 2 | Detail → **Đánh giá [tên SP]** | Review form mở đúng productId/orderId | ☐ |
| 3 | Chọn sao + comment → Gửi | Success; reviews trên product detail tăng | ☐ |
| 4 | Gửi lại / chưa đủ điều kiện | Message lỗi rõ (nếu BE chặn) | ☐ |

---

## 5. Customer — Wishlist & Profile

### IT-WISH-01 · Wishlist

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Tim SP → Profile → **Yêu thích** | SP xuất hiện | ☐ |
| 2 | Bỏ tim trên list wishlist | Item biến mất | ☐ |
| 3 | Empty wishlist | Empty + CTA marketplace | ☐ |
| 4 | Pull refresh | OK | ☐ |
| 5 | Logout | Wishlist provider clear (tim reset sau login user khác) | ☐ |

### IT-PROF-01 · Profile & edit

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Profile hiển thị name, email, role badge | Đúng seed user | ☐ |
| 2 | Chỉnh sửa hồ sơ: fullName, address | Save → profile cập nhật | ☐ |
| 3 | Upload avatar (optional) | URL mới hoặc lỗi upload không crash form | ☐ |
| 4 | Farmer: bank STK (MB/VCB…) | Save bankInfo; banner STK biến mất nếu đủ | ☐ |
| 5 | Menu: FAQ, Terms, Privacy, How to buy | Mở màn support | ☐ |
| 6 | Giá thị trường / Trace từ profile | Mở đúng màn | ☐ |

---

## 6. Seller — Products (Farmer / Supplier)

### IT-SEL-P-01 · My Products

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Login farmer → tab **Sản phẩm** | List SP của seller (seed/me) | ☐ |
| 2 | Empty | Empty + FAB/Thêm SP | ☐ |
| 3 | Lỗi mạng (tắt BE) | Error empty + Thử lại | ☐ |

### IT-SEL-P-02 · Create / Edit / Delete

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Thêm SP: tên, giá > 0, qty, unit, category | Đăng bán success | ☐ |
| 2 | Không chọn category | Validate | ☐ |
| 3 | Có ảnh: upload Cloudinary fail | Vẫn tạo SP được (ảnh optional demo) | ☐ |
| 4 | Sửa SP | Cập nhật success; list refresh | ☐ |
| 5 | Xóa SP → confirm | Biến mất khỏi list | ☐ |
| 6 | Customer marketplace | Thấy SP mới (status active) | ☐ |

---

## 7. Seller — Orders

### IT-SEL-O-01 · Pipeline status

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Customer tạo đơn SP của farmer | Farmer tab **Chờ xác nhận** có đơn | ☐ |
| 2 | **Xác nhận đơn** | → confirmed | ☐ |
| 3 | **Bắt đầu chuẩn bị** | → preparing | ☐ |
| 4 | **Bàn giao / đang giao** | → shipping | ☐ |
| 5 | **Đã giao hàng** | → delivered | ☐ |
| 6 | Customer history cập nhật | Tabs/status khớp | ☐ |

### IT-SEL-O-02 · Từ chối / stats

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Đơn pending → Từ chối / Hủy (seller) | cancelled | ☐ |
| 2 | Stats bar (chờ / hôm nay / doanh thu) | Số hợp lý, không NaN | ☐ |
| 3 | Customer mở Seller Orders | Redirect / không quản lý đơn bán | ☐ |

---

## 8. Notifications

### IT-NOTIF-01

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Sau đặt hàng | Badge / list có notif order (nếu BE tạo) | ☐ |
| 2 | Mở Notifications | List + loading/empty | ☐ |
| 3 | Tap notif có orderId | Mở order detail | ☐ |
| 4 | Mark read / read-all | Unread giảm | ☐ |
| 5 | Pull refresh | OK | ☐ |

---

## 9. Market prices

### IT-PRICE-01

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Profile → Giá cả thị trường | List giá seed (sau `npm run seed`) | ☐ |
| 2 | Filter category/region (nếu có) | Lọc đúng | ☐ |
| 3 | Pull refresh | OK | ☐ |
| 4 | DB trống | Empty + gợi ý seed | ☐ |

---

## 10. Trace / QR

### IT-TRACE-01

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | Profile → Truy xuất nguồn gốc | Màn nhập mã + chip demo | ☐ |
| 2 | Chip **AGL-TOMATO-001** | Detail timeline đầy đủ | ☐ |
| 3 | Chip **AGL-DURIAN-001** | Detail OK | ☐ |
| 4 | Mã sai | Error message, không crash | ☐ |
| 5 | Quét camera (device/emulator có cam) | Nhận code → lookup (có thể skip trên Chrome) | ☐ |

---

## 11. Support & navigation

### IT-SUP-01

| Bước | Thao tác | Kỳ vọng | ☐ |
|---|---|---|---|
| 1 | FAQ / How to buy / Terms / Privacy | Nội dung hiện, back OK | ☐ |
| 2 | Bottom nav customer 5 tab | Switch mượt, không mất state nghiêm trọng | ☐ |
| 3 | Deep navigate Success → Home → Order | Không loop / dead end | ☐ |

---

## 12. Luồng end-to-end (bắt buộc trước chấm)

Chạy **một lần liền** (2 account):

```text
[Customer] Login
  → Browse SP
  → Wishlist
  → Add cart
  → Checkout COD
  → Thấy mã đơn + History pending
[Farmer] Login
  → Seller orders: pending → … → delivered
[Customer] Login lại
  → Order delivered
  → Viết review
  → Trace chip AGL-TOMATO-001
  → Prices
  → Logout
```

| # | E2E | ☐ Pass |
|---|---|---|
| E2E-1 | Toàn bộ chuỗi trên không crash | ☐ |
| E2E-2 | Payment bank_transfer demo always success (optional nhánh) | ☐ |
| E2E-3 | Register user mới full path (optional) | ☐ |

---

## 13. Ma trận role × màn hình

| Màn / Hành vi | Customer | Farmer | Supplier |
|---|:-:|:-:|:-:|
| Marketplace browse | ✓ | (có thể qua route) | (có thể) |
| Cart / Checkout / Create order | ✓ | ✗ order API | ✗ |
| Order history (buyer) | ✓ | ✓ nếu từng mua | ✓ |
| Seller orders | ✗ | ✓ | ✓ |
| My Products CRUD | ✗ | ✓ | ✓ |
| Wishlist | ✓ | — | — |
| Review sau delivered | ✓ | — | — |
| Notifications | ✓ | ✓ | ✓ |
| Prices / Trace | ✓ | ✓ | ✓ |
| Profile edit + bank | optional | **nên có bank** | **nên có bank** |

---

## 14. Known issues / chấp nhận demo

| Mục | Ghi chú |
|---|---|
| Payment | Không VNPay production; confirm demo luôn success |
| Cart | Chỉ local, không sync multi-device |
| Shipper tracking | Tên/SĐT có thể mock |
| Phone Auth | Không còn UI; email-only |
| Cloudinary | Upload ảnh fail → SP vẫn tạo được |
| Chrome Phone OTP | N/A (không dùng) |
| Socket notif | Tắt; dùng REST |

---

## 15. Bảng tổng hợp kết quả (copy khi báo cáo)

| Module | Case IDs | Pass | Fail | Skip | Ghi chú |
|---|---|---:|---:|---:|---|
| Env | B0.*, M0.* | | | | |
| Auth | IT-AUTH-* | | | | |
| Marketplace | IT-MKT-* | | | | |
| Cart/Checkout | IT-CART-*, IT-CHK-* | | | | |
| Orders buyer | IT-ORD-* | | | | |
| Wishlist/Profile | IT-WISH-*, IT-PROF-* | | | | |
| Seller products | IT-SEL-P-* | | | | |
| Seller orders | IT-SEL-O-* | | | | |
| Notif | IT-NOTIF-* | | | | |
| Prices | IT-PRICE-* | | | | |
| Trace | IT-TRACE-* | | | | |
| Support | IT-SUP-* | | | | |
| E2E | E2E-* | | | | |

**Tổng:** Pass ___ / Fail ___ / Skip ___  

**Tester:** ___________ · **Ngày:** ___________ · **Build:** `develop` / PR #___ · **Device:** Chrome / Android / iOS  

---

## 16. Lệnh nhanh tham chiếu

```bash
# BE
cd AgriLink_Mobile_BE && npm run seed && npm start

# Mobile
cd agrilink && flutter pub get && flutter run -d chrome

# Unit (không thay interaction test)
cd agrilink && flutter test
```

**Tài liệu liên quan**

- `DEMO_SCRIPT.md` — kịch bản demo ngắn 5–8 phút  
- `README.md` — auth email, payment demo, seed  
- `MOBILE_COMPLETION_PLAN.md` (thư mục project) — roadmap phase  

---

*File này dùng để interaction testing thủ công toàn luồng. Đánh dấu ☐ → ☑ khi pass.*
