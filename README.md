# SoftEther VPN Client for Android

یک کلاینت ساده و کاربردی برای اتصال به سرور SoftEther VPN

## تکنولوژی استفاده شده

این پروژه با **Flutter** پیاده‌سازی شده است چون:
- چند پلتفرمی است (Android و iOS)
- رابط کاربری زیبا و مدرن
- عملکرد عالی و سرعت بالا
- توسعه سریع و آسان

## ویژگی‌ها

✅ اتصال به سرور SoftEther VPN  
✅ ذخیره اطلاعات سرور  
✅ مدیریت چندین پروفایل VPN  
✅ نمایش وضعیت اتصال  
✅ قطع و وصل سریع  
✅ رابط کاربری فارسی و انگلیسی  

## پیش‌نیازها

- Flutter SDK (نسخه 3.0 یا بالاتر)
- Android Studio یا VS Code
- Android SDK

## نصب و راه‌اندازی

### 1. نصب Flutter

```bash
# دانلود Flutter از سایت رسمی
# https://flutter.dev/docs/get-started/install
```

### 2. کلون پروژه

```bash
cd Desktop/SoftEtherVPN-Client
```

### 3. نصب وابستگی‌ها

```bash
flutter pub get
```

### 4. اجرای برنامه

```bash
# اجرا روی اموlatور یا دستگاه واقعی
flutter run

# ساخت فایل APK
flutter build apk --release
```

## ساختار پروژه

```
lib/
├── main.dart                 # نقطه شروع برنامه
├── models/
│   └── vpn_profile.dart     # مدل پروفایل VPN
├── screens/
│   ├── home_screen.dart     # صفحه اصلی
│   ├── add_profile_screen.dart  # افزودن پروفایل
│   └── connection_screen.dart   # صفحه اتصال
├── services/
│   ├── vpn_service.dart     # سرویس اتصال VPN
│   └── storage_service.dart # ذخیره‌سازی داده‌ها
└── widgets/
    └── profile_card.dart    # کارت نمایش پروفایل
```

## نحوه استفاده

1. برنامه را باز کنید
2. روی دکمه "+" کلیک کنید تا پروفایل جدید اضافه کنید
3. اطلاعات سرور را وارد کنید:
   - نام پروفایل
   - آدرس سرور
   - پورت (معمولاً 443 یا 992)
   - نام کاربری
   - رمز عبور
   - نام Hub
4. پروفایل را ذخیره کنید
5. روی پروفایل کلیک کنید تا متصل شوید

## توجه

⚠️ این برنامه از VPN Service API اندروید استفاده می‌کند و نیاز به مجوز VPN دارد.

⚠️ برای اتصال به SoftEther، از پروتکل L2TP/IPsec یا OpenVPN استفاده می‌شود.

## لایسنس

MIT License - استفاده آزاد برای همه

## توسعه‌دهنده

ساخته شده توسط Cline AI Assistant 🤖
