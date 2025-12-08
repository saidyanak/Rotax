# Rotax Frontend - Flutter Lojistik Uygulaması

Rotax lojistik platformunun mobil ve web uygulaması. Flutter ile geliştirilmiştir.

## 🚀 Özellikler

### Kullanıcı Rolleri

#### 🚗 Sürücü (Driver)
- Dashboard ile günlük/aylık istatistikler
- Aktif/Pasif durum kontrolü
- Kargo tekliflerini görüntüleme ve kabul etme
- Kargo durumu güncelleme (Alındı/Teslim Edildi)
- Profil yönetimi

#### 📦 Distribütör (Distributor)
- Dashboard ile kargo istatistikleri
- Yeni kargo oluşturma (çok adımlı form)
- Kargo listesi ve filtreleme
- Kargo detay ve takip
- Kargo iptal etme
- Profil ve şirket bilgileri yönetimi

#### 💰 Cüzdan (Wallet)
- Bakiye görüntüleme
- Para yükleme
- Para çekme (IBAN ile)
- İşlem geçmişi

#### 🔍 Herkese Açık
- Takip kodu ile kargo sorgulama
- Teslimat durumu takibi
- Teslimat notu ekleme

## 📁 Proje Yapısı

```
lib/
├── main.dart                         # Uygulama giriş noktası
├── core/
│   ├── constants/
│   │   ├── api_constants.dart        # API endpoint'leri
│   │   ├── app_colors.dart           # Tema renkleri
│   │   └── app_theme.dart            # Material theme
│   └── services/
│       ├── api_service.dart          # HTTP client (JWT destekli)
│       ├── storage_service.dart      # Token & local storage
│       ├── auth_service.dart         # Authentication işlemleri
│       ├── driver_service.dart       # Sürücü API'leri
│       ├── distributor_service.dart  # Distribütör API'leri
│       └── wallet_service.dart       # Cüzdan API'leri
├── models/
│   ├── user.dart                     # Kullanıcı modeli
│   ├── location.dart                 # Lokasyon modeli
│   ├── measure.dart                  # Ölçü modeli
│   ├── cargo.dart                    # Kargo modeli
│   ├── wallet.dart                   # Cüzdan modeli
│   └── transaction.dart              # İşlem modeli
├── providers/
│   ├── auth_provider.dart            # Auth state yönetimi
│   ├── wallet_provider.dart          # Cüzdan state yönetimi
│   ├── driver_provider.dart          # Sürücü state yönetimi
│   └── distributor_provider.dart     # Distribütör state yönetimi
├── widgets/
│   ├── rotax_app_bar.dart            # Özel AppBar
│   ├── rotax_button.dart             # Özel Button
│   ├── rotax_text_field.dart         # Özel Input
│   ├── rotax_card.dart               # Özel Card
│   └── cargo_status_badge.dart       # Kargo durum badge'i
└── screens/
    ├── splash/
    │   └── splash_screen.dart        # Açılış ekranı
    ├── auth/
    │   ├── login_screen.dart         # Giriş ekranı
    │   └── register_screen.dart      # Kayıt ekranı
    ├── driver/
    │   ├── driver_home_screen.dart   # Sürücü ana ekranı
    │   ├── driver_offers_screen.dart # Teklifler
    │   └── driver_profile_screen.dart# Profil
    ├── distributor/
    │   ├── distributor_home_screen.dart    # Distribütör ana ekranı
    │   ├── distributor_cargos_screen.dart  # Kargolarım
    │   ├── create_cargo_screen.dart        # Kargo oluştur
    │   ├── cargo_detail_screen.dart        # Kargo detay
    │   └── distributor_profile_screen.dart # Profil
    ├── wallet/
    │   ├── wallet_screen.dart        # Cüzdan ekranı
    │   ├── deposit_screen.dart       # Para yükle
    │   └── withdraw_screen.dart      # Para çek
    └── public/
        └── tracking_screen.dart      # Kargo takip
```

## 🛠️ Teknolojiler

- **Flutter** 3.7.2+
- **Dart** 3.7.2+
- **State Management**: Provider
- **HTTP Client**: http, dio
- **Storage**: flutter_secure_storage, shared_preferences
- **UI**: Material Design 3

## 📦 Bağımlılıklar

```yaml
dependencies:
  http: ^1.2.0
  dio: ^5.4.0
  provider: ^6.1.1
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  flutter_spinkit: ^5.2.0
  cached_network_image: ^3.3.1
  image_picker: ^1.0.7
  intl: ^0.19.0
```

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK 3.7.2 veya üzeri
- Docker & Docker Compose (Docker kurulumu için)
- Backend API çalışıyor olmalı (localhost:8080)

### 🐳 Docker ile Çalıştırma (Önerilen)

```bash
# Frontend dizinine git
cd Rotax_Frontend

# Tüm sistemi başlat (Frontend + Backend + PostgreSQL + RabbitMQ)
docker compose up -d

# Sadece frontend'i rebuild et
docker compose up -d --build frontend

# Logları izle
docker compose logs -f frontend
```

**Erişim:**
- Frontend: http://localhost:3000
- Backend API: http://localhost:8080
- RabbitMQ Dashboard: http://localhost:15672 (guest/guest)

### 💻 Local Kurulum (Flutter SDK Gerekli)

```bash
# Repository'yi klonla
git clone https://github.com/saidyanak/Rotax.git
cd Rotax/Rotax_Frontend

# Bağımlılıkları yükle
flutter pub get

# Web için çalıştır (port 3000)
flutter run -d chrome --web-port=3000

# Android için çalıştır
flutter run -d android

# iOS için çalıştır
flutter run -d ios
```

## 🌐 API Endpoint'leri

Frontend aşağıdaki API endpoint'lerini kullanır:

### Auth
| Method | Endpoint | Açıklama |
|--------|----------|----------|
| POST | `/api/auth/login` | Giriş |
| POST | `/api/auth/register` | Kayıt |
| GET | `/api/auth/me` | Kullanıcı bilgisi |
| POST | `/api/auth/logout` | Çıkış |

### Driver
| Method | Endpoint | Açıklama |
|--------|----------|----------|
| GET | `/api/driver/dashboard` | Dashboard verileri |
| PUT | `/api/driver/status` | Durum güncelle |
| GET | `/api/driver/offers` | Teklifler |
| POST | `/api/driver/offers/{id}/accept` | Teklif kabul |

### Distributor
| Method | Endpoint | Açıklama |
|--------|----------|----------|
| GET | `/api/distributor/dashboard` | Dashboard verileri |
| GET | `/api/distributor/cargos` | Kargo listesi |
| POST | `/api/distributor/cargos` | Yeni kargo |
| DELETE | `/api/distributor/cargos/{id}/cancel` | Kargo iptal |

### Wallet
| Method | Endpoint | Açıklama |
|--------|----------|----------|
| GET | `/api/wallet` | Cüzdan bilgisi |
| POST | `/api/wallet/deposit` | Para yükle |
| POST | `/api/wallet/withdraw` | Para çek |
| GET | `/api/wallet/transactions` | İşlem geçmişi |

### Public
| Method | Endpoint | Açıklama |
|--------|----------|----------|
| GET | `/api/public/track/{code}` | Kargo takip |

## 🎨 Tema Renkleri

```dart
Primary: #DB3737 (Kırmızı)
Dark Background: #171717
Card: #FFFFFF
Text Primary: #2E1A1A
Success: #4CAF50
Warning: #FF9800
Error: #F44336
```

## 🔧 Konfigürasyon

### API URL Değiştirme

`lib/core/constants/api_constants.dart`:

```dart
class ApiConstants {
  // Docker içinde (nginx proxy)
  static const String baseUrl = 'http://localhost:8080';
  
  // Production
  // static const String baseUrl = 'https://api.rotax.com';
}
```

## 📝 Docker Dosyaları

- `Dockerfile` - Multi-stage Flutter web build
- `docker-compose.yml` - Full stack (Frontend + Backend + DB + RabbitMQ)
- `nginx.conf` - Web server config with API proxy

---

**Rotax Lojistik** © 2025
