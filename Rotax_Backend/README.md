# 🚚 Rotax Backend - Gelişmiş Lojistik Platformu

> Dağıtıcıları, mobil sürücüleri ve son kullanıcıları modern ve verimli bir ekosistemde birleştiren mikroservis tabanlı bir lojistik çözümü.

## 📖 Proje Hakkında

Bu proje, geleneksel kargo ve lojistik süreçlerine teknolojik bir yaklaşım getirmeyi amaçlamaktadır. E-ticaret firmaları (Dağıtıcılar) için kargo gönderimini kolaylaştırırken, bireysel sürücüler için ek gelir fırsatları yaratır. Tüm süreç, son kullanıcının kargosunu canlı olarak takip edebildiği ve geri bildirimde bulunabildiği şeffaf bir yapı üzerine kurulmuştur.

Proje, ölçeklenebilirlik ve bakım kolaylığı sağlamak amacıyla **Spring Boot** (ana iş mantığı) ve **Python** (akıllı eşleştirme) servisleri olmak üzere iki ana bileşenden oluşan bir mikroservis mimarisi kullanmaktadır.

## 🚀 Hızlı Başlangıç (Docker ile)

### Ön Gereksinimler
- Docker ve Docker Compose
- Git

### 1. Projeyi Klonlayın
```bash
git clone https://github.com/saidyanak/Rotax.git
cd Rotax/Rotax_Backend
```

### 2. Environment Dosyasını Oluşturun
```bash
cp .env-example .env
```

`.env` dosyasını açın ve aşağıdaki değerleri kendi bilgilerinizle doldurun:
```bash
# PostgreSQL
POSTGRES_DB=rotax
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password

# Database Connection
DATABASE_URL=jdbc:postgresql://db:5432/rotax
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=your_secure_password

# JWT Secret (min 256-bit key)
JWT_SECRET=your_super_secret_jwt_key_min_32_characters

# Gmail SMTP (Opsiyonel - mail gönderimi için)
GMAIL_APP_PASSWORD=your_gmail_app_password

# Frontend URL
FRONTEND_URL=http://localhost:3000

# Internal API Key
INTERNAL_API_KEY=rotax-internal-api-key
```

### 3. Docker ile Çalıştırın
```bash
# Tüm servisleri başlat (backend + PostgreSQL)
docker compose up -d

# Logları takip et
docker compose logs -f

# Servisleri durdur
docker compose down

# Servisleri durdur ve verileri sil
docker compose down -v
```

### 4. API'ye Erişin
- **API Base URL:** http://localhost:8080
- **Swagger UI:** http://localhost:8080/swagger-ui.html
- **API Docs:** http://localhost:8080/v3/api-docs

## Özellikler

### Dağıtıcı (Distributor) Özellikleri
- Güvenli kullanıcı kaydı ve profil yönetimi
- Sisteme bakiye yükleme ve harcama geçmişini görüntüleme
- Detaylı kargo bilgilerini (adres, boyut, fotoğraf) sisteme yükleme
- Gönderilen kargoların durumunu anlık olarak takip etme
- Teslimatlar sonrası sürücülere puan ve yorum yapma

### Sürücü (Driver) Özellikleri
- Mobil uygulama üzerinden kolay kayıt ve belge (kimlik, ruhsat) yükleme
- Anlık konum ve uygunluk durumunu (Aktif/Pasif) bildirme
- Yakınındaki veya rotası üzerindeki kargo tekliflerini bildirim olarak alma
- Teklif detaylarını (ücret, mesafe, rota sapması) görüntüleyip kabul/reddetme
- Kazanç geçmişini ve performans metriklerini (puan ortalaması vb.) görme

### Son Kullanıcı (Alıcı) Özellikleri
- Üyelik gerektirmeyen, SMS ile gönderilen güvenli link üzerinden kargo takibi
- Harita üzerinde kargonun anlık konumunu ve tahmini varış süresini görme
- "Komşuma bırak" gibi teslimat notları ekleme
- Teslimat sonrası sürücüye puan ve yorum bırakma

### Admin Özellikleri
- Sürücü ve dağıtıcıların kimlik/belge doğrulamalarını yapma (onay/ret)
- Tüm kullanıcıları, kargoları ve işlemleri yönetme
- Sistem sağlığını ve genel istatistikleri izleme

## Mimari

Sistem, görevlerin net bir şekilde ayrıldığı mikroservis mimarisine dayanmaktadır.

```
+----------------+      +---------------------+      +----------------+
|                |      |                     |      |                |
|   Clients      |----->| Spring Boot (API)   |----->|   PostgreSQL   |
| (Flutter/React)|      | (Ana İş Mantığı)    |      |  (Veritabanı)  |
|                |      |                     |      |                |
+----------------+      +---------+-----------+      +----------------+
                                  |
                                  | (RabbitMQ)
                                  v
+----------------+      +---------+-----------+
|                |      |                     |
| Python Service |<-----|      RabbitMQ       |
| (Eşleştirme    |      |   (Mesaj Kuyruğu)   |
|  Algoritması)  |----->|                     |
|                |      |                     |
|                |      +---------------------+
+----------------+
```

### Bileşenler

**Spring Boot Ana Servisi**: Sistemin kalbidir. Tüm API isteklerini karşılar, veritabanı işlemlerini yönetir ve ana iş akışlarını kontrol eder.

**Python Eşleştirme Servisi**: Tek bir göreve odaklanmıştır: Gelen kargo talepleri için en verimli sürücüyü bulmak.

**RabbitMQ**: İki servis arasındaki asenkron iletişimi sağlar, sistemin esnekliğini ve dayanıklılığını artırır.

**PostgreSQL**: Tüm verilerin kalıcı olarak saklandığı merkezi veritabanıdır.

**Admin Paneli**: Appsmith/Retool gibi hazır bir araç ile veritabanına bağlanarak operasyonel işlemlerin yönetildiği arayüzdür.

## Teknoloji Yığını

| Kategori | Teknolojiler |
|----------|-------------|
| **Backend (Ana Servis)** | Java 21, Spring Boot 3.5.6, Spring Data JPA, Spring Security (JWT), Hibernate |
| **Backend (Eşleştirme Servisi)** | Python 3.10+, FastAPI, Pika (RabbitMQ Client) |
| **Veritabanı** | PostgreSQL 15+ |
| **Mesajlaşma** | RabbitMQ |
| **Mobil Uygulama** | Flutter *(Planlanan)* |
| **Web Arayüzleri** | React *(Planlanan)* |
| **DevOps** | Docker, Docker Compose |

## Paket Yapısı (Spring Boot)

Proje, bakım kolaylığı ve ölçeklenebilirlik için standart katmanlı mimari prensiplerini takip eder:

```
com.yourcompany.deliveryapp
├── config/                  // Spring Security, WebSocket, RabbitMQ ayarları
├── controller/
│   ├── api/                 // Dış dünyaya açık, istemci API'leri (Distributor, Driver vb.)
│   └── internal/            // Servisler arası (internal) iletişim API'leri (Python için)
├── dto/                     // Request/Response ve Mesajlaşma DTO'ları
├── entity/                  // Veritabanı tablolarını temsil eden JPA Entity'leri
├── enums/                   // Proje genelindeki Enum'lar (UserType, CargoStatus vb.)
├── exception/               // Özel exception sınıfları ve Global Exception Handler
├── messaging/               // RabbitMQ Producer ve Consumer sınıfları
├── repository/              // Veritabanı erişim katmanı (JPA Repositories)
├── security/                // JWT token yönetimi ve güvenlik filtreleri
└── service/                 // Tüm iş mantığının bulunduğu katman
```

## API Endpoint'leri

API, kullanıcı rollerine ve erişim seviyelerine göre mantıksal gruplara ayrılmıştır.

> 📘 **Swagger UI:** Tüm endpoint'lerin detaylı dokümantasyonu için [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html) adresini ziyaret edin.

### 🔐 Kimlik Doğrulama (`/api/auth`)

| Metot | URL | Açıklama |
|-------|-----|----------|
| POST | `/api/auth/register` | Yeni Sürücü veya Dağıtıcı kaydı oluşturur (multipart/form-data) |
| POST | `/api/auth/login` | Kullanıcı girişi yapar ve JWT döndürür |
| GET | `/api/auth/me` | Mevcut kullanıcı bilgilerini getirir |
| POST | `/api/auth/logout` | Kullanıcı oturumunu sonlandırır |
| POST | `/api/auth/forgot-password` | Şifre sıfırlama maili gönderir |
| POST | `/api/auth/reset-password` | Token ile şifre sıfırlar |
| POST | `/api/auth/change-password` | Mevcut şifreyi değiştirir |
| POST | `/api/auth/validate-reset-token` | Şifre sıfırlama token'ını doğrular |
| GET | `/api/auth/validate-reset-token/{token}` | URL ile token doğrulama |

### 📦 Dağıtıcı Endpoint'leri (`/api/distributor`)

| Metot | URL | Açıklama | Yetkilendirme |
|-------|-----|----------|---------------|
| GET | `/api/distributor/dashboard` | Dağıtıcının dashboard verilerini getirir | DISTRIBUTOR |
| PUT | `/api/distributor/profile` | Profil bilgilerini günceller | DISTRIBUTOR |
| POST | `/api/distributor/profile/picture` | Profil resmi yükler | DISTRIBUTOR |
| POST | `/api/distributor/cargos` | Yeni bir kargo oluşturur | DISTRIBUTOR |
| GET | `/api/distributor/cargos` | Dağıtıcının tüm kargolarını listeler (paginated) | DISTRIBUTOR |
| GET | `/api/distributor/cargos/{cargoId}` | Belirtilen kargo detayını getirir | DISTRIBUTOR |
| PUT | `/api/distributor/cargos/{cargoId}/cancel` | Kargoyu iptal eder | DISTRIBUTOR |

### 🚗 Sürücü Endpoint'leri (`/api/driver`)

| Metot | URL | Açıklama | Yetkilendirme |
|-------|-----|----------|---------------|
| PUT | `/api/driver/status` | Sürücü durumunu ve konumunu günceller | DRIVER |
| GET | `/api/driver/dashboard` | Sürücünün dashboard verilerini getirir | DRIVER |
| PUT | `/api/driver/profile` | Profil bilgilerini günceller | DRIVER |
| POST | `/api/driver/profile/picture` | Profil resmi yükler | DRIVER |
| GET | `/api/driver/offers` | Sürücüye gelen aktif kargo tekliflerini listeler | DRIVER |
| POST | `/api/driver/offers/{cargoId}/accept` | Kargo teklifini kabul eder | DRIVER |
| PUT | `/api/driver/cargos/{cargoId}/status/picked-up` | Kargoyu teslim aldığını bildirir | DRIVER |
| PUT | `/api/driver/cargos/{cargoId}/status/delivered` | Kargoyu teslim ettiğini bildirir | DRIVER |

### 🌐 Herkese Açık Endpoint'ler (`/api/public`)

| Metot | URL | Açıklama | Yetkilendirme |
|-------|-----|----------|---------------|
| GET | `/api/public/track/{trackingCode}` | Kargonun anlık konumunu ve durumunu getirir | Herkese Açık |
| POST | `/api/public/track/{trackingCode}/note` | Teslimat notu ekler | Herkese Açık |
| POST | `/api/public/track/{trackingCode}/review` | Sürücüye puan ve yorum ekler | Herkese Açık |

### 🔧 Admin Endpoint'leri (`/api/admin`)

| Metot | URL | Açıklama | Yetkilendirme |
|-------|-----|----------|---------------|
| GET | `/api/admin/documents/pending` | Onay bekleyen belgeleri listeler | ADMIN |
| POST | `/api/admin/documents/{documentId}/approve` | Belgeyi onaylar | ADMIN |
| POST | `/api/admin/documents/{documentId}/reject` | Belgeyi reddeder | ADMIN |

### 🔗 Servisler Arası Endpoint'ler (`/api/internal`)

| Metot | URL | Açıklama | Yetkilendirme |
|-------|-----|----------|---------------|
| GET | `/api/internal/drivers/available` | Uygun sürücüleri listeler | INTERNAL_API_KEY |

## Kurulum ve Başlatma

> ⚡ **Hızlı Başlangıç için** README'nin başındaki "Hızlı Başlangıç (Docker ile)" bölümüne bakın.

### Docker Olmadan Geliştirme

Docker kullanmadan geliştirme yapmak isterseniz:

#### Gereksinimler
- Java 21+
- Maven 3.9+
- PostgreSQL 15+
- (Opsiyonel) Python 3.10+ (Eşleştirme servisi için)

#### Adımlar

1. **Repository'yi Klonlayın:**
```bash
git clone https://github.com/saidyanak/Rotax.git
cd Rotax/Rotax_Backend
```

2. **PostgreSQL Veritabanını Oluşturun:**
```sql
CREATE DATABASE rotax;
```

3. **Environment Değişkenlerini Ayarlayın:**
```bash
export DATABASE_URL=jdbc:postgresql://localhost:5432/rotax
export DATABASE_USERNAME=postgres
export DATABASE_PASSWORD=your_password
export JWT_SECRET=your_super_secret_jwt_key_min_32_characters
```

4. **Uygulamayı Çalıştırın:**
```bash
./mvnw spring-boot:run
```

### Docker Compose Komutları

```bash
# Servisleri başlat (backend + database)
docker compose up -d

# Logları izle
docker compose logs -f auth

# Sadece database'i başlat
docker compose up -d db

# Servisleri durdur
docker compose down

# Servisleri durdur + verileri sil
docker compose down -v

# Image'ı yeniden oluştur
docker compose up -d --build
```

## Lisans

Bu proje MIT Lisansı altında lisanslanmıştır. Daha fazla bilgi için [LICENSE](LICENSE) dosyasına bakın.

