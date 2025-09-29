# Rotax - Gelişmiş Lojistik Platformu

Dağıtıcıları, mobil sürücüleri ve son kullanıcıları modern ve verimli bir ekosistemde birleştiren mikroservis tabanlı bir lojistik çözümü.

## Proje Hakkında

Bu proje, geleneksel kargo ve lojistik süreçlerine teknolojik bir yaklaşım getirmeyi amaçlamaktadır. E-ticaret firmaları (Dağıtıcılar) için kargo gönderimini kolaylaştırırken, bireysel sürücüler için ek gelir fırsatları yaratır. Tüm süreç, son kullanıcının kargosunu canlı olarak takip edebildiği ve geri bildirimde bulunabildiği şeffaf bir yapı üzerine kurulmuştur.

Proje, ölçeklenebilirlik ve bakım kolaylığı sağlamak amacıyla **Spring Boot** (ana iş mantığı) ve **Python** (akıllı eşleştirme) servisleri olmak üzere iki ana bileşenden oluşan bir mikroservis mimarisi kullanmaktadır.

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
| **Backend (Ana Servis)** | Java 17, Spring Boot 3.x, Spring Data JPA, Spring Security (JWT), Hibernate |
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

API, kullanıcı rollerine ve erişim seviyelerine göre mantıksal gruplara ayrılmıştır. (Daha detaylı dokümantasyon için Swagger/OpenAPI kullanılabilir.)

### Kimlik Doğrulama (Authentication)

| Metot | URL | Açıklama |
|-------|-----|----------|
| POST | `/api/auth/register/{userType}` | Yeni Sürücü veya Dağıtıcı kaydı oluşturur |
| POST | `/api/auth/login` | Kullanıcı girişi yapar ve JWT döndürür |

### Dağıtıcı (Distributor) Endpoint'leri

| Metot | URL | Açıklama | Yetkilendirme |
|-------|-----|----------|---------------|
| POST | `/api/cargos` | Yeni bir kargo oluşturur | DISTRIBUTOR |
| GET | `/api/distributors/dashboard` | Dağıtıcının dashboard verilerini getirir | DISTRIBUTOR |
| GET | `/api/distributors/cargos` | Dağıtıcının tüm kargolarını listeler | DISTRIBUTOR |

### Sürücü (Driver) Endpoint'leri

| Metot | URL | Açıklama | Yetkilendirme |
|-------|-----|----------|---------------|
| PUT | `/api/drivers/status` | Sürücünün durumunu günceller (ACTIVE/INACTIVE) | DRIVER |
| GET | `/api/drivers/dashboard` | Sürücünün dashboard verilerini getirir | DRIVER |
| GET | `/api/drivers/offers` | Sürücüye gelen aktif kargo tekliflerini listeler | DRIVER |
| POST | `/api/drivers/offers/{offerId}/accept` | Gelen kargo teklifini kabul eder | DRIVER |
| PUT | `/api/cargos/{cargoId}/status/picked-up` | Kargoyu teslim aldığını bildirir | DRIVER |
| PUT | `/api/cargos/{cargoId}/status/delivered` | Kargoyu teslim ettiğini bildirir | DRIVER |

### Son Kullanıcı (Public) Endpoint'leri

| Metot | URL | Açıklama | Yetkilendirme |
|-------|-----|----------|---------------|
| GET | `/api/public/track/{token}` | Güvenli token ile kargonun anlık konumunu getirir | Herkese Açık |
| POST | `/api/public/track/{token}/notes` | Son kullanıcının teslimat notu eklemesini sağlar | Herkese Açık |
| POST | `/api/public/review/{token}` | Güvenli token ile sürücüye puan ve yorum yapılmasını sağlar | Herkese Açık |

### Servisler Arası (Internal) Endpoint'ler

| Metot | URL | Açıklama | Yetkilendirme |
|-------|-----|----------|---------------|
| GET | `/api/internal/drivers/available` | Eşleştirme için uygun olan sürücüleri listeler | INTERNAL_SERVICE_KEY |

## Kurulum ve Başlatma

Projeyi yerel makinenizde çalıştırmak için aşağıdaki adımları izleyin:

### Gereksinimler

- Java 17+
- Maven veya Gradle
- Python 3.10+
- Docker ve Docker Compose

### Adımlar

1. **Repository'yi Klonlayın:**

```bash
git clone https://github.com/kullanici-adiniz/rotax.git
cd rotax
```

2. **Altyapıyı Başlatın (Veritabanı ve RabbitMQ):**

Aşağıdaki komut, Docker kullanarak PostgreSQL ve RabbitMQ servislerini başlatacaktır.

```bash
docker-compose up -d
```

3. **Backend (Spring Boot) Servisini Yapılandırın ve Çalıştırın:**

- `src/main/resources/application.properties` dosyasını açın
- Veritabanı, RabbitMQ ve JWT ayarlarınızı yapılandırın
- Uygulamayı çalıştırın:

```bash
mvn spring-boot:run
```

4. **Python Eşleştirme Servisini Yapılandırın ve Çalıştırın:**

- Python servisi dizinine gidin
- Gerekli kütüphaneleri yükleyin:

```bash
pip install -r requirements.txt
```

- RabbitMQ bağlantı bilgilerini içeren ortam değişkenlerini (environment variables) ayarlayın
- Servisi başlatın:

```bash
python main.py
```

Proje artık yerel makinenizde çalışıyor olmalı!

## Lisans

Bu proje MIT Lisansı altında lisanslanmıştır. Daha fazla bilgi için [LICENSE](LICENSE) dosyasına bakın.
