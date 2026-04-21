# 📱 Presensi MARSA — Flutter WebView App

Aplikasi Android untuk sistem presensi **SMK Ma'arif 9 Kebumen** berbasis WebView dengan splash screen, permission handling (lokasi, kamera, notifikasi), dan akses langsung ke `smk-maarif9kebumen.com/present/public`.

---

## 📁 Struktur Proyek

```
flutter_webview_presensi/
├── android/
│   └── app/
│       ├── build.gradle                     # Konfigurasi build Android
│       └── src/main/
│           ├── AndroidManifest.xml          # Permissions & konfigurasi app
│           └── res/
│               └── xml/
│                   └── network_security_config.xml
│
├── assets/
│   └── images/
│       └── logo.png                         # ← Taruh logo sekolah di sini
│
├── lib/
│   ├── main.dart                            # Entry point
│   │
│   ├── screens/
│   │   ├── splash_screen.dart               # Splash animasi (3.5 detik)
│   │   ├── permission_screen.dart           # Halaman izin
│   │   └── webview_screen.dart              # WebView utama
│   │
│   ├── services/
│   │   ├── permission_service.dart          # Handler permission
│   │   └── notification_service.dart        # Notifikasi lokal
│   │
│   └── utils/
│       └── app_constants.dart               # URL & konstanta
│
└── pubspec.yaml                             # Dependencies
```

---

## 🚀 Alur Aplikasi

```
Buka App
    ↓
SplashScreen (3.5 detik)
  - Logo animasi scale + fade
  - Progress bar loading
    ↓
Cek Permission (otomatis)
    ↓
Semua izin sudah ✅      Belum semua izin ❌
    ↓                           ↓
WebViewScreen          PermissionScreen
                         (Lokasi / Kamera / Notif)
                                ↓
                          Izinkan → WebViewScreen
                          Lewati  → WebViewScreen
```

---

## ⚙️ Setup & Instalasi

### 1. Clone / salin proyek
```bash
cd /path/to/projects
# Salin folder ini
```

### 2. Tambahkan logo sekolah
Taruh file logo PNG di:
```
assets/images/logo.png
```
> Ukuran ideal: **512×512 px**, background transparan/putih

### 3. Install dependencies
```bash
flutter pub get
```

### 4. Generate launcher icon (opsional)
```bash
flutter pub run flutter_launcher_icons
```

### 5. Jalankan di device
```bash
flutter run
```

### 6. Build APK release
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔐 Permissions yang Diminta

| Izin | Android | Kegunaan |
|------|---------|---------|
| `ACCESS_FINE_LOCATION` | Wajib | Verifikasi lokasi saat absen |
| `CAMERA` | Wajib | Scan QR code presensi |
| `POST_NOTIFICATIONS` | Android 13+ | Pengingat jadwal presensi |
| `INTERNET` | Auto | Akses server presensi |

---

## 🌐 URL Konfigurasi

Edit di `lib/utils/app_constants.dart`:
```dart
static const String loginUrl =
    'https://smk-maarif9kebumen.com/present/public';
```

---

## 📦 Dependencies Utama

| Package | Versi | Kegunaan |
|---------|-------|---------|
| `webview_flutter` | ^4.7.0 | WebView engine |
| `permission_handler` | ^11.3.0 | Manajemen izin |
| `flutter_local_notifications` | ^17.2.2 | Notifikasi lokal |
| `geolocator` | ^12.0.0 | Akses GPS |
| `camera` | ^0.10.5 | Akses kamera |
| `connectivity_plus` | ^6.0.3 | Cek koneksi internet |

---

## 🛠️ Troubleshooting

**WebView tidak load?**
- Pastikan `smk-maarif9kebumen.com` menggunakan HTTPS
- Cek `network_security_config.xml`

**Izin ditolak permanen?**
- Aplikasi akan buka Settings > App Permissions secara otomatis

**Notifikasi tidak muncul di Android 13+?**
- Permission `POST_NOTIFICATIONS` harus diminta secara eksplisit (sudah ditangani)

---

## 📝 Info Sekolah

- **Sekolah**: SMK Ma'arif 9 Kebumen
- **Server**: smk-maarif9kebumen.com
- **App Package**: `com.marsa9.presensi`
- **Min Android**: 5.0 (API 21)
