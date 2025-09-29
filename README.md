Rotax - Kapsamlı Teknik Mimari ve İş Akışları Detayları
Bu doküman, projenin her bir parçasını derinlemesine inceleyerek tam bir teknik referans sunmaktadır.

Bölüm 1: Sistem Mimarisi ve Felsefesi
Proje, modern yazılım geliştirme prensipleriyle tasarlanmış bir mikroservis mimarisine sahiptir. Bu, sistemin farklı parçalarının bağımsız olarak geliştirilebilmesi, güncellenebilmesi ve ölçeklendirilebilmesi anlamına gelir.

Spring Boot Ana Servisi (Sistemin Kalbi): Tüm kullanıcı etkileşimlerini, veri tutarlılığını ve temel iş kurallarını yöneten ana omurgadır. Güvenilir ve sağlam olması için Java/Spring Boot tercih edilmiştir.

Python Eşleştirme Servisi (Sistemin Beyni): Yoğun hesaplama ve potansiyel yapay zeka/makine öğrenmesi gerektiren "en uygun sürücüyü bulma" görevine odaklanmış uzman bir servistir. Bu iş için en iyi araçları sunan Python ile geliştirilecektir.

RabbitMQ (Sistemin Kan Damarları): Bu iki servis arasındaki iletişimi sağlayan asenkron mesajlaşma sistemidir. Bir servis diğerine doğrudan "bağımlı" değildir; bunun yerine, işlenecek görevleri (mesajları) bu ortak posta kutusuna bırakırlar. Bu, sistemin bir parçası geçici olarak yavaşlasa veya çökse bile veri kaybını önler ve genel dayanıklılığı artırır.

Bölüm 2: Veritabanı Mimarisi (PostgreSQL)
Veritabanı, sistemin "tek doğru kaynağıdır". Tüm kalıcı veriler burada saklanır.

users Tablosu:

Amacı: Platforma kayıt olan tüm bireylerin (sürücü veya dağıtıcı fark etmeksizin) ortak ve temel bilgilerini (e-posta, şifre, telefon) tutar.

Kritik Sütunlar: user_type (ENUM), bir kullanıcının 'DRIVER' mı yoksa 'DISTRIBUTOR' mü olduğunu belirleyerek yetkilendirme mekanizmasının temelini oluşturur.

drivers ve distributors Tabloları:

Amacı: users tablosundaki temel bilgilere ek olarak, her bir kullanıcı tipine özel bilgileri saklar. Örneğin, sürücüler için license_plate (plaka) ve rating_average (puan ortalaması); dağıtıcılar için ise company_name (şirket adı) ve balance (bakiye).

Kritik Sütunlar: additional_attributes (JSONB). Bu sütun, gelecekte eklenebilecek (araç modeli, MERSİS no gibi) esnek verileri, veritabanı şemasını değiştirmeden saklamamızı sağlar.

cargos Tablosu:

Amacı: Platformun ana nesnesi olan kargoların tüm bilgilerini ve yaşam döngüsünü tutar.

Kritik Sütunlar:

status (ENUM): Bir kargonun hangi aşamada olduğunu gösteren en önemli alandır:

PENDING_MATCHING: Kargo oluşturuldu, sürücü bekleniyor.

OFFERED: Sürücüye teklif gönderildi.

ASSIGNED: Sürücü teklifi kabul etti.

PICKED_UP: Sürücü kargoyu teslim aldı.

IN_TRANSIT: Kargo yolda.

DELIVERED: Teslim edildi.

public_tracking_token: Son kullanıcının giriş yapmadan kargosunu takip edebilmesi için üretilen, tahmin edilmesi imkansız, güvenli bir anahtardır.

reviews Tablosu:

Amacı: Sürücülere yapılan tüm puanlamaları ve yorumları saklar.

Kritik Sütunlar: reviewer_type (ENUM). Puanlamayı yapanın 'CUSTOMER' (son kullanıcı) mı yoksa 'DISTRIBUTOR' (dağıtıcı) mı olduğunu ayırır. Bu, farklı kullanıcı tiplerinden gelen geri bildirimleri analiz etme imkanı sunar.

user_documents Tablosu:

Amacı: Sürücü ve dağıtıcıların sisteme yüklediği resmi belgelerin (kimlik fotoğrafı, araç ruhsatı, vergi levhası) kaydını tutar.

Kritik Sütunlar: status (ENUM) sayesinde adminlerin bu belgeleri 'PENDING_REVIEW' (onay bekliyor), 'APPROVED' (onaylandı) veya 'REJECTED' (reddedildi) olarak işaretlemesini sağlar. Bu, platformun güvenliği için kritik bir süreçtir.

Bölüm 3: Servisler ve Sorumlulukları
3.1. Spring Boot Ana Servisi
Rolü: Sistemin ana iş akışlarını yöneten, dış dünya ile (mobil/web uygulamaları) konuşan ve veri tutarlılığını sağlayan merkezi servis.

API Katmanı Detayları:

Authentication API (/api/auth/...): Kullanıcı kaydı ve JWT (JSON Web Token) tabanlı güvenli giriş işlemlerini yönetir.

User-Facing API'ler (/api/drivers, /api/distributors): Giriş yapmış kullanıcıların kendi profillerini yönetmesi, dashboard'larını görmesi, kargo oluşturması veya teklif kabul etmesi gibi işlemleri sağlar.

Public API'ler (/api/public/...): Son kullanıcının (alıcının) giriş yapmadan, sadece SMS ile gelen güvenli token'lar aracılığıyla kargosunu takip etmesi, not bırakması ve puanlama yapması için kullanılır.

Internal API (/api/internal/...): Dış dünyaya tamamen kapalıdır. Sadece Python servisinin, eşleştirme yaparken ihtiyaç duyduğu anlık sürücü verilerini (konum, durum vb.) çekmesi için kullanılır. Güvenliği bir API anahtarı ile sağlanır.

Kritik Servisler ve İş Mantığı:

CargoServiceImpl: Yeni bir kargo oluşturulduğunda, veritabanına kaydeder, durumunu PENDING_MATCHING olarak ayarlar ve CargoMatchingRequestProducer aracılığıyla RabbitMQ'ya bir mesaj gönderir.

MatchingResultConsumer: RabbitMQ'nun sonuç kuyruğunu dinler. Python servisinden bir eşleştirme sonucu geldiğinde, bu mesajı işler: ilgili kargonun durumunu OFFERED olarak günceller, delivery_offers tablosuna kayıt atar ve NotificationService aracılığıyla sürücüye anlık WebSocket bildirimi gönderir.

ReviewServiceImpl: Son kullanıcıdan bir puanlama geldiğinde, reviews tablosuna kaydeder ve ardından ilgili sürücünün rating_average'ını yeniden hesaplayıp günceller.

3.2. Python Eşleştirme Servisi
Rolü: Tek bir işe odaklanmış, yüksek performanslı bir "uzman"dır: En verimli kargo-sürücü eşleşmesini bulmak.

İşleyiş Adımları:

Dinleme: Sürekli olarak RabbitMQ'daki cargo.matching.request.queue kuyruğunu dinler.

Mesajı Alma: Yeni bir kargo talebi mesajı geldiğinde, içindeki JSON verisini okur.

Veri Toplama: Spring Boot servisinin /api/internal/drivers/available API'sini çağırarak o an müsait olan tüm sürücülerin konum, puan, araç tipi gibi verilerini çeker.

Algoritmayı Çalıştırma: Elindeki kargo bilgisi ve tüm sürücü verilerini kullanarak kendi algoritmasını çalıştırır. Bu algoritma; mesafeyi, sürücünün mevcut rotasına ne kadar saptığını, sürücünün puanını, kargonun önceliğini vb. birçok faktörü hesaba katar.

Sonuç Hazırlama: En uygun bulduğu bir veya daha fazla sürücünün ID'sini ve teklif detaylarını içeren bir JSON sonucu oluşturur.

Sonucu Gönderme: Bu sonuç JSON'ını RabbitMQ'daki cargo.matching.result.queue kuyruğuna gönderir.

Bölüm 4: Admin Paneli Stratejisi
Seçilen Yaklaşım: Sıfırdan bir admin paneli yazmak yerine, Appsmith veya Retool gibi hazır bir "headless" (arayüzsüz) admin paneli aracı kullanmak.

Neden?: Geliştirme sürecini aylardan günlere indirir. Bu, ekibin zamanını müşterilerin doğrudan kullandığı ana ürün özelliklerine odaklamasını sağlar. Filtreleme, arama, veri düzenleme gibi standart özellikler için yeniden kod yazma zahmetinden kurtarır.

Entegrasyon: Bu araç, veritabanına kısıtlı yetkilere sahip bir kullanıcı ile bağlanır. Geliştirici, sürükle-bırak yöntemleriyle, hangi verilerin görüneceğini ve "Onayla", "Reddet" gibi butonların hangi işlemleri yapacağını birkaç saat içinde tasarlayabilir.
