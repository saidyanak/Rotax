# Rotax
E-ticaret firmaları ve bağımsız sürücüleri bir araya getiren, yapay zeka destekli kargo dağıtım sistemi.
# Kargo Uygulaması Mikro Servis Mimarisi

cargo-microservices/
├── README.md
├── docker-compose.yml
├── docker-compose.dev.yml
├── .gitignore
├── .env.example
├── docs/
│   ├── api-documentation.md
│   ├── architecture.md
│   └── setup-guide.md
├── scripts/
│   ├── start-all.sh
│   ├── stop-all.sh
│   └── build-all.sh
├── infrastructure/
│   ├── nginx/
│   │   └── nginx.conf
│   ├── kafka/
│   │   └── kafka-setup.yml
│   └── monitoring/
│       ├── prometheus.yml
│       └── grafana/
├── services/
│   ├── user-service/
│   │   ├── src/
│   │   ├── Dockerfile
│   │   ├── pom.xml
│   │   └── README.md
│   ├── cargo-service/
│   │   ├── src/
│   │   ├── Dockerfile
│   │   ├── pom.xml
│   │   └── README.md
│   ├── driver-service/
│   │   ├── src/
│   │   ├── Dockerfile
│   │   ├── pom.xml
│   │   └── README.md
│   ├── distributor-service/
│   ├── matching-service/
│   ├── location-service/
│   ├── notification-service/
│   ├── payment-service/
│   ├── rating-service/
│   ├── pickup-point-service/
│   └── qr-code-service/
├── shared/
│   ├── common-models/
│   │   └── src/main/java/com/cargo/models/
│   ├── common-utils/
│   │   └── src/main/java/com/cargo/utils/
│   └── common-configs/
│       └── src/main/java/com/cargo/config/
├── frontend/
│   ├── mobile-app/
│   ├── web-app/
│   └── admin-panel/
└── database/
    ├── migrations/
    ├── seeds/
    └── schemas/

## Ana Mikro Servisler

### 1. **User Service** (Port: 8081)
**Ana Sorumluluk:** Tüm kullanıcı türleri için kimlik doğrulama ve profil yönetimi

#### Temel Görevleri:
- **Kimlik Doğrulama İşlemleri:**
  - Kullanıcı kaydı (Driver, Distributor, Son Kullanıcı olarak)
  - Giriş yapma ve çıkış yapma
  - JWT token oluşturma ve doğrulama
  - Şifre sıfırlama işlemleri
  - Email doğrulama

- **Profil Yönetimi:**
  - Kullanıcı bilgilerini görüntüleme ve güncelleme
  - Role göre özel profil bilgileri yönetimi
  - Hesap durumu yönetimi (aktif, pasif, askıya alınmış)

- **İlk Kayıt İşlemleri:**
  - Driver kaydında sürücü özel bilgilerini oluşturma
  - Distributor kaydında firma bilgilerini oluşturma
  - Temel kullanıcı bilgilerini kaydetme

#### Veri Saklama:
PostgreSQL kullanarak kullanıcı temel bilgileri, driver profilleri ve distributor profillerini saklar.

---

### 2. **Driver Service** (Port: 8082)
**Ana Sorumluluk:** Sürücülere özel tüm işlemler ve durum yönetimi

#### Temel Görevleri:
- **Durum Yönetimi:**
  - Aktif bekleyiş durumu
  - Belirli yöne gitme durumu
  - Meşgul durumu (kargo taşıyor)
  - Çevrimdışı durumu

- **Kargo İşlemleri:**
  - Uygun kargoları listeleme
  - Kargo tekliflerini kabul etme veya reddetme
  - Kargoyu teslim alma işlemleri
  - Kargoyu son alıcıya teslim etme

- **Konum ve Hareket:**
  - Anlık konum bilgisini güncelleme
  - Hareket rotası bilgilerini paylaşma
  - Coğrafi sınırlar içinde kontrollerini yapma

- **Performans Takibi:**
  - Sürücü puanlama sistemi
  - Teslim geçmişi kayıtları
  - Kazanç hesaplamaları ve raporları

#### Veri Saklama:
PostgreSQL ve Redis kullanarak sürücü durumları, aktif kargolar, kazanç bilgileri ve performans verilerini saklar.

---

### 3. **Distributor Service** (Port: 8083)
**Ana Sorumluluk:** Kargo gönderen firmalara özel işlemler

#### Temel Görevleri:
- **Kargo Yönetimi:**
  - Yeni kargo siparişi oluşturma
  - Mevcut kargo listesini görüntüleme
  - Kargo durumunu takip etme
  - Kargo iptali işlemleri

- **Ödeme ve Bakiye:**
  - Hesap bakiyesini görüntüleme
  - Bakiye ekleme işlemleri
  - Ödeme geçmişini görüntüleme
  - Fatura oluşturma ve indirme

- **Analiz ve Raporlama:**
  - Kargo gönderim istatistikleri
  - Maliyet analizi raporları
  - Performans değerlendirmeleri
  - Başarı oranları

#### Veri Saklama:
PostgreSQL kullanarak distributor işlemleri, bakiye hareketleri ve istatistiksel verileri saklar.

---

### 4. **Cargo Service** (Port: 8084)
**Ana Sorumluluk:** Kargo yaşam döngüsünün merkezi yönetimi

#### Temel Görevleri:
- **Kargo Yaşam Döngüsü:**
  - Kargo kaydının oluşturulması
  - Durum güncellemelerinin takibi
  - Kargo geçmişinin tutulması
  - Detaylı kargo bilgilerinin saklanması

- **Takip Sistemi:**
  - Gerçek zamanlı durum takibi
  - Konum geçmişinin kaydedilmesi
  - Tahmini teslim süresinin hesaplanması
  - Otomatik bildirim tetiklemeleri

- **Kargo Özellikleri:**
  - Gönderici ve alıcı bilgileri
  - Kargo türü ve boyut bilgileri
  - Özel talimatlar
  - Fiyat hesaplamaları

#### Veri Saklama:
PostgreSQL kullanarak kargo bilgileri, durum geçmişi ve takip verilerini saklar.

---

### 5. **Matching Service** (Port: 8085)
**Ana Sorumluluk:** Kargo ve sürücü eşleştirme algoritmaları

#### Temel Görevleri:
- **Akıllı Eşleştirme:**
  - En kısa yol algoritması kullanarak optimal eşleştirme
  - Sürücü durumu ve kapasitesini kontrol etme
  - Mesafe ve maliyet optimizasyonu
  - Dinamik fiyatlandırma hesaplamaları

- **Havuz Yönetimi:**
  - Bekleyen kargo havuzunu yönetme
  - Aktif sürücü havuzunu güncel tutma
  - Eşleştirme kurallarını uygulama
  - Öncelik sıralaması yapma

- **Algoritma Kontrolü:**
  - Eşleştirme başarı oranları
  - Algoritma performans analizi
  - Kural güncellemeleri
  - A/B test yapabilme altyapısı

#### Veri Saklama:
Redis kullanarak hızlı eşleştirme işlemleri ve PostgreSQL kullanarak eşleştirme geçmişi saklar.

---

### 6. **Location Service** (Port: 8086)
**Ana Sorumluluk:** Konum yönetimi ve coğrafi işlemler

#### Temel Görevleri:
- **Gerçek Zamanlı Takip:**
  - Sürücü konumlarının sürekli güncellenmesi
  - Kargo rotasının kayıt altına alınması
  - Hareket yönü ve hız bilgilerinin tutulması

- **Coğrafi Hesaplamalar:**
  - İki nokta arası mesafe hesaplama
  - En optimal rota önerisi
  - Adres koordinat dönüşümü
  - Coğrafi sınır kontrolları

- **Takip Özellikleri:**
  - Son alıcı için görsel takip arayüzü
  - Geçmiş rota kayıtları
  - Tahmin edilen varış süreleri

#### Veri Saklama:
MongoDB kullanarak coğrafi koordinatlar, rota bilgileri ve konum geçmişi saklar.

---

### 7. **Notification Service** (Port: 8087)
**Ana Sorumluluk:** Tüm bildirim türlerinin yönetimi

#### Temel Görevleri:
- **Anında Bildirimler:**
  - Mobil cihazlara push notification
  - Web tarayıcısına anlık bildirimler
  - WebSocket ile gerçek zamanlı güncellemeler

- **Geleneksel Bildirimler:**
  - SMS mesajları
  - Email bildirimleri
  - Şablon tabanlı mesaj gönderimi

- **Bildirim Yönetimi:**
  - Kullanıcı bildirim tercihlerini saklama
  - Bildirim geçmişi tutma
  - Gönderim başarı durumları
  - Bildirim şablonları yönetimi

#### Veri Saklama:
MongoDB kullanarak bildirim kayıtları, şablonlar ve kullanıcı tercihlerini saklar.

---

### 8. **Payment Service** (Port: 8088)
**Ana Sorumluluk:** Tüm ödeme işlemlerinin yönetimi

#### Temel Görevleri:
- **Distributor Ödemeleri:**
  - Hesap bakiyesi yönetimi
  - Kargo bedeli kesimi
  - Ödeme tutma ve serbest bırakma işlemleri
  - Otomatik ücret hesaplaması

- **Sürücü Ödemeleri:**
  - Kazanç hesaplamaları
  - Ödeme transferi işlemleri
  - Komisyon hesaplamaları

- **Mali İşlemler:**
  - İşlem geçmişi kayıtları
  - Fatura oluşturma
  - Geri ödeme işlemleri
  - Mali raporlama

#### Veri Saklama:
PostgreSQL kullanarak ödeme kayıtları, işlem geçmişi ve mali raporları saklar.

---

## Servisler Arası İletişim

### Senkron İletişim:
- Kullanıcı kimlik doğrulaması için tüm servisler User Service ile iletişim kurar
- Ödeme doğrulaması için Cargo Service, Payment Service ile konuşur
- Rota hesaplama için Matching Service, Location Service ile iletişim kurar

### Asenkron İletişim (Kafka):
- Kargo oluşturulduğunda Matching Service bilgilendirilir
- Sürücü durumu değiştiğinde ilgili tüm servisler haberdar edilir
- Ödeme işlemleri tamamlandığında Cargo ve Notification servisleri bilgilendirilir
- Konum güncellemeleri tüm ilgili servislere anlık iletilir

## Veri Tabanı Stratejisi

### PostgreSQL Kullanan Servisler:
ACID özelliklerinin kritik olduğu servisler için tercih edilir:
- User Service (kullanıcı bilgileri)
- Cargo Service (kargo verileri)
- Payment Service (mali işlemler)
- Driver Service (sürücü verileri)

### MongoDB Kullanan Servisler:
Esnek yapı ve coğrafi sorguların önemli olduğu servisler için:
- Location Service (koordinat verileri)
- Notification Service (bildirim kayıtları)

### Redis Kullanan Servisler:
Hızlı erişim ve önbellek için:
- Driver Service (aktif sürücü durumları)
- Matching Service (eşleştirme havuzu)
- User Service (oturum yönetimi)

## API Gateway Yönetimi

Nginx kullanarak tüm isteklerin tek noktadan yönetilmesi:
- URL'ye göre otomatik yönlendirme
- Yük dengeleme ve önbellekleme
- Güvenlik kontrolleri
- İstek hızı sınırlaması

## Güvenlik Yaklaşımı

- JWT tabanlı kimlik doğrulama
- Role tabanlı erişim kontrolü
- API seviyesinde güvenlik kontrolleri
- Veri şifreleme ve güvenli iletişim

