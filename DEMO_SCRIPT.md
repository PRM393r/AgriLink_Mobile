# AgriLink Mobile — Demo script (5–8 phút)

> Cập nhật sau Phase 4–7. Payment **chỉ demo** (luôn thành công).

## Chuẩn bị (trước buổi demo)

1. **BE** (`AgriLink_Mobile_BE`):
   ```bash
   npm install
   # .env: PORT=5000, MONGODB_URI, JWT secrets
   npm run seed
   npm start   # hoặc npm run dev
   ```
2. **Mobile** (`agrilink`):
   ```bash
   flutter pub get
   flutter run -d chrome
   # hoặc Android emulator (API dùng 10.0.2.2:5000)
   ```
3. Seed accounts (password **`demo123`**):
   - `customer1@agrilink.vn` — buyer  
   - `farmer1@agrilink.vn` — seller  
   - `supplier1@agrilink.vn` — supplier  

4. Trace demo codes: **`AGL-TOMATO-001`**, **`AGL-DURIAN-001`**  
5. Dev OTP email (nếu chưa cấu hình SMTP): **`123456`**

---

## Kịch bản demo

| # | Actor | Việc | Pass |
|---|---|---|---|
| 1 | Customer | Login quick **Buyer** | Dashboard customer |
| 2 | Customer | Marketplace → mở SP → thả tim | Tim active; Profile → Yêu thích có SP |
| 3 | Customer | Add cart → kill app (optional) → cart còn | Cart persist |
| 4 | Customer | Checkout **COD** | Success + mã đơn |
| 5 | Customer | Order history → detail | Thấy đơn pending |
| 6 | Customer | (Tuỳ chọn) Checkout **chuyển khoản** → bấm xác nhận demo | Luôn success |
| 7 | Farmer | Login **Farmer** → Sản phẩm → Thêm SP | Tạo SP OK (ảnh optional) |
| 8 | Farmer | Đơn hàng → Xác nhận → … → Đã giao | Status pipeline |
| 9 | Customer | Login lại → đơn delivered → **Đánh giá** | Review form gửi được |
| 10 | Any | Profile → Giá thị trường / Trace chip demo | API + seed |

---

## Auth email (nếu chấm đăng ký)

```text
Register → OTP 123456 → Login (email prefilled) → RolePicker → Home
```

---

## Definition of Done (mobile MVP)

- [x] Phase 1 Auth email-first  
- [x] Phase 2 Cart persist + checkout  
- [x] Phase 3 Seller + payment demo always-success  
- [x] Phase 4 Profile / Wishlist / Review paths  
- [x] Phase 5 Notif / Prices / Trace demo chips  
- [x] Phase 6–7 Polish + this script  

**Cắt scope:** VNPay/PayOS production, cart BE sync, Phone Auth, shipper thật.
