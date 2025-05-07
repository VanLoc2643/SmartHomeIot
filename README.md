# Smart Home IoT - Flutter Firebase App

## 📱 Giới thiệu

Đây là ứng dụng Flutter kết hợp Firebase phục vụ cho hệ thống **IoT cảnh báo, giám sát và điều khiển nhà thông minh**. Ứng dụng hỗ trợ:
- Giám sát trạng thái cảm biến (nhiệt độ, khói, khí gas, chuyển động, v.v.)
- Điều khiển thiết bị IoT từ xa (quạt, đèn, máy bơm, cửa cuốn,...)
- Nhận cảnh báo cháy, khói qua **Firebase Cloud Messaging** và **Telegram Bot**
- Đăng nhập bằng Google, Facebook, GitHub
- Nhắn tin, tìm bạn bè, kết bạn qua **Firestore**

## 🔧 Công nghệ sử dụng
- Flutter + Dart (ngôn ngữ chính)
- Firebase:
  - Authentication (xác thực người dùng)
  - Firestore (lưu thông tin người dùng, bạn bè, tin nhắn)
  - Realtime Database (đồng bộ trạng thái thiết bị IoT)
  - Cloud Messaging (gửi thông báo cảnh báo)
- Telegram Bot (gửi cảnh báo khẩn cấp)
- Provider (quản lý trạng thái theo mô hình MVVM)

## ⚙️ Cài đặt

### 1. Clone source code
```bash
git clone [https://github.com/your-username/smart-home-flutter.git](https://github.com/VanLoc2643/SmartHomeIot)
cd vanlocapp 
```
### 2. Cài đặt thư viện Flutter
```bash
flutter pub get
```
### 3. Kết nối Firebase
- Tạo project Firebase tại https://console.firebase.google.com/
- Tải tệp `google-services.json` (Android) hoặc `GoogleService-Info.plist` (iOS)
- Thêm vào thư mục tương ứng trong dự án Flutter
### 4. Tạo Bot Telegram
- Tạo bot mới qua BotFather
- Lấy `token`, dán vào source NodeMCU hoặc phần cảnh báo server
---
## 🛠 Tính năng chính
- ✅ Đăng nhập Google/Facebook/GitHub
- ✅ Giám sát cảm biến theo thời gian thực
- ✅ Gửi cảnh báo khẩn cấp qua FCM & Telegram
- ✅ Điều khiển thiết bị IoT
- ✅ Giao diện biểu đồ trực quan (fl_chart, syncfusion)
- ✅ Nhắn tin bạn bè, kết bạn qua Firestore
- ✅ Dark Mode / Light Mode

## 👨‍💻 Liên hệ 
Email: vanlocdev@gmail.com
