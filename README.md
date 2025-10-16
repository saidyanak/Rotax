# 🚚 Rotax - Gelişmiş Lojistik Platformu

> Dağıtıcıları, mobil sürücüleri ve son kullanıcıları modern bir ekosistemde birleştiren mikroservis tabanlı lojistik çözümü.

## 📖 Proje Hakkında

Rotax, geleneksel kargo ve lojistik süreçlerine teknolojik bir yaklaşım getiren, ölçeklenebilir ve modern bir platformdur. E-ticaret firmaları için kargo gönderimini kolaylaştırırken, bireysel sürücüler için ek gelir fırsatları yaratır ve son kullanıcılara şeffaf, canlı takip imkanı sunar.

Bu repository, Rotax platformunun tüm bileşenlerini barındıran ana merkezdir. Mikroservis mimarisi prensiplerine göre tasarlanmış, her bir servisin kendi klasöründe organize edildiği modüler bir yapıya sahiptir.

## 🏗️ Mimari Genel Bakış

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│  Mobile App     │────────▶│   Backend API    │────────▶│   PostgreSQL    │
│  (Flutter)      │         │  (Spring Boot)   │         │                 │
└─────────────────┘         └────────┬─────────┘         └─────────────────┘
                                     │
┌─────────────────┐                  │ RabbitMQ
│   Web Panel     │                  │
│   (React)       │────────▶         ▼
└─────────────────┘         ┌────────────────────┐
                            │ Matching Service   │
                            │    (Python)        │
                            └────────────────────┘
```

## 📁 Repository Yapısı

```
rotax/
├── backend/                    # Spring Boot Ana Servisi
│   ├── src/
│   ├── Dockerfile
│   └── README.md              # 📘 Backend detaylı dokümantasyon
│
├── matching-service/          # Python Eşleştirme Servisi
│   ├── src/
│   ├── requirements.txt
│   └── README.md              # 📘 Eşleştirme servisi dokümantasyon
│
├── frontend-mobile/           # Flutter Mobil Uygulama
│   ├── lib/
│   ├── android/
│   ├── ios/
│   └── README.md              # 📘 Mobil uygulama dokümantasyon
│
├── frontend-web/              # React Web Paneli
│   ├── src/
│   ├── public/
│   └── README.md              # 📘 Web paneli dokümantasyon
│
├── docker-compose.yml         # Altyapı servisleri (PostgreSQL, RabbitMQ)
└── README.md                  # 📄 Bu dosya
```

## 🚀 Hızlı Başlangıç

### Ön Gereksinimler

- Docker ve Docker Compose
- Java 21+ (Backend için)
- Python 3.10+ (Matching Service için)
- Node.js 18+ (Web paneli için)
- Flutter SDK (Mobil uygulama için)

### Tüm Altyapıyı Başlatma

Projenin altyapı servislerini (PostgreSQL, RabbitMQ) tek komutla başlatabilirsiniz:

```bash
docker-compose up -d
```

Bu komut aşağıdaki servisleri başlatır:
- **PostgreSQL** (Port: 5432)
- **RabbitMQ** (Port: 5672, Management UI: 15672)

### Servisleri Ayrı Ayrı Çalıştırma

Her bir bileşenin detaylı kurulum ve çalıştırma talimatları için ilgili README dosyalarına bakın:

| Bileşen | Klasör | Dokümantasyon |
|---------|--------|---------------|
| Backend API | `Rotax/` | [backend/README.md](./Rotax/README.md) |
| Eşleştirme Servisi | `matching-service/` | [matching-service/README.md](./matching-service/README.md) |
| Mobil Uygulama | `frontend-mobile/` | [frontend-mobile/README.md](./RotaxFront/rotax/README.md) |
| Web Paneli | `frontend-web/` | [frontend-web/README.md](./RotaxFront/rotax/README.md) |

## 🛠️ Teknoloji Stack

| Katman | Teknolojiler |
|--------|-------------|
| **Backend** | Java 21, Spring Boot 3.5.6, Spring Security, JWT |
| **Eşleştirme** | Python 3.10+, FastAPI, Pika |
| **Mobil** | Flutter, Dart |
| **Web** | React, TypeScript |
| **Veritabanı** | PostgreSQL 15+ |
| **Message Broker** | RabbitMQ |
| **DevOps** | Docker, Docker Compose |

## ✨ Ana Özellikler

### 📦 Dağıtıcılar İçin
- Hızlı kargo oluşturma ve yönetimi
- Anlık durum takibi
- Sürücü değerlendirme sistemi
- Bakiye ve ödeme yönetimi

### 🚗 Sürücüler İçin
- Akıllı kargo eşleştirme
- Esnek çalışma saatleri
- Kazanç takibi
- Performans metrikleri

### 📱 Son Kullanıcılar İçin
- Üyeliksiz, güvenli kargo takibi
- Canlı konum güncellemeleri
- Teslimat notları
- Sürücü değerlendirme

## 📚 Detaylı Dokümantasyon

Her servisin kendi detaylı dokümantasyonu bulunmaktadır:

- **[Backend README](./backend/README.md)** - API endpoint'leri, veritabanı şeması, güvenlik yapılandırması
- **[Matching Service README](./matching-service/README.md)** - Eşleştirme algoritması, RabbitMQ entegrasyonu
- **[Mobile App README](./frontend-mobile/README.md)** - Flutter kurulumu, build ve deployment
- **[Web Panel README](./frontend-web/README.md)** - React uygulaması, state management, API entegrasyonu

## 🔗 Faydalı Bağlantılar

- **RabbitMQ Management UI**: http://localhost:15672 (Kullanıcı: guest, Şifre: guest)
- **Backend API**: http://localhost:8080
- **Matching Service**: http://localhost:8000
- **Web Panel**: http://localhost:3000

## 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz! Lütfen bir özellik eklemeden veya hata düzeltmesi yapmadan önce bir issue açın.

## 📄 Lisans

Bu proje MIT Lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

**Not:** Her bir servisin bağımsız olarak çalıştırılabilmesi için yukarıdaki altyapı servislerinin (PostgreSQL ve RabbitMQ) aktif olması gerekmektedir.
