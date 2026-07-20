# AgriLink Mobile

Flutter client for AgriLink (PRM393) — marketplace nông sản 3 role: **customer / farmer / supplier**.

## Auth (email-first)

Product auth path (no phone OTP UI):

```text
Register (email + password + fullName)
  → POST /auth/register
Verify email OTP
  → POST /auth/verify-email
Login
  → POST /auth/login → JWT
  → if role empty → RolePicker → PUT /users/me/role
  → Home
```

- **Dev OTP:** when BE has no SMTP (`MAIL_USER` empty), OTP is always `123456`.
- **Demo seed accounts** (password `demo123`):
  - `customer1@agrilink.vn`
  - `farmer1@agrilink.vn`
  - `supplier1@agrilink.vn`

## Backend

- Base URL: `http://localhost:5000/api/v1` (Android emulator uses `10.0.2.2`)
- Repo: `AgriLink_Mobile_BE` (Express + MongoDB)

## Run

```bash
flutter pub get
flutter run -d chrome
# or Android emulator
flutter run
```

## Payment (demo only)

Payment **không** integrate cổng production (VNPay/PayOS).  
Luồng demo:

- **COD** — tạo đơn xong là success  
- **Chuyển khoản / QR** — màn Payment QR; bấm xác nhận **luôn thành công** (best-effort gọi BE `payment-confirm`, lỗi API vẫn cho qua)

## Demo & testing

- **[DEMO_SCRIPT.md](./DEMO_SCRIPT.md)** — kịch bản demo 5–8 phút  
- **[INTEGRATION_TESTING.md](./INTEGRATION_TESTING.md)** — checklist interaction/integration test **toàn luồng**

Trace seed: `AGL-TOMATO-001`, `AGL-DURIAN-001`.

## Tests

```bash
flutter test
```
