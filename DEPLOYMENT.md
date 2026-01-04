# 🚀 Rotax Deployment Rehberi (IP ile - Domain YOK)

## Gereksinimler

- ✅ Google Cloud hesabı
- ✅ Gmail hesabı (mail göndermek için)
- ✅ GitHub hesabı
- ❌ Domain gerekmez (sadece IP ile çalışacak)

---

## 1. Google Cloud VM Oluştur

### 1.1. VM Instance Oluştur
```
1. https://console.cloud.google.com/compute açın
2. "Create Instance" tıklayın
3. Ayarlar:
   - Name: rotax-server
   - Region: europe-west1 (Belçika)
   - Machine type: e2-medium (2 vCPU, 4 GB RAM)
   - Boot disk: Ubuntu 24.04 LTS, 30 GB SSD
   - Firewall: ✅ Allow HTTP traffic, ✅ Allow HTTPS traffic
4. "Create" tıklayın
```

### 1.2. Static IP Ayarla
```
1. VPC Network > External IP Addresses
2. "Reserve Static Address" tıklayın
3. Name: rotax-static-ip
4. Region: europe-west1
5. Attach to: rotax-server
6. "Reserve" tıklayın
```

**IP Adresinizi Not Edin:** Örn. `34.76.123.45`

---

## 2. SSH Bağlantısı Kur

### 2.1. SSH Key Oluştur (Local Makinenizde)

```bash
# SSH key oluştur
ssh-keygen -t ed25519 -C "rotax-deploy" -f ~/.ssh/rotax-deploy

# Public key'i göster
cat ~/.ssh/rotax-deploy.pub
```

### 2.2. Key'i Google Cloud'a Ekle

```
1. Compute Engine > Metadata > SSH Keys
2. "Add SSH Key" tıklayın
3. Public key içeriğini yapıştırın
4. "Save" tıklayın
```

### 2.3. SSH ile Bağlan

```bash
ssh -i ~/.ssh/rotax-deploy YOUR_USERNAME@34.76.123.45
```

> `YOUR_USERNAME`: Google Cloud kullanıcı adınız

---

## 3. Sunucu Kurulumu

### 3.1. Sistem Güncellemesi

```bash
sudo apt update && sudo apt upgrade -y
```

### 3.2. Docker Kur

```bash
# Docker'ı kur
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Kullanıcıyı docker grubuna ekle
sudo usermod -aG docker $USER

# Docker Compose kur
sudo apt install docker-compose-plugin -y

# Logout/login (docker group için)
exit
```

Tekrar bağlan:
```bash
ssh -i ~/.ssh/rotax-deploy YOUR_USERNAME@34.76.123.45
```

Test et:
```bash
docker ps
docker compose version
```

### 3.3. Nginx Kur

```bash
sudo apt install nginx -y
sudo systemctl enable nginx
```

### 3.4. Git Kur

```bash
sudo apt install git -y
```

### 3.5. GitHub Actions Runner Kur

GitHub self-hosted runner kurarak CI/CD'yi sunucuda çalıştıracağız.

**Adımlar:**

1. GitHub Repo'nuza gidin
2. **Settings > Actions > Runners > New self-hosted runner**
3. **Linux x64** seçin
4. Gösterilen komutları sunucuda çalıştırın:

```bash
# Runner klasörü oluştur
mkdir ~/actions-runner && cd ~/actions-runner

# Runner'ı indir (GitHub'dan kopyalanan komut)
curl -o actions-runner-linux-x64-2.314.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.314.1/actions-runner-linux-x64-2.314.1.tar.gz

# Paketi aç
tar xzf ./actions-runner-linux-x64-2.314.1.tar.gz

# Runner'ı yapılandır (GitHub'dan kopyalanan token ile)
./config.sh --url https://github.com/YOUR_USERNAME/Rotax --token YOUR_TOKEN

# Runner ismini ver: rotax-server
# Grupları boş bırak (Enter)
# Labels ekle: self-hosted,Linux,X64,rotax
```

5. **Runner'ı servis olarak çalıştır** (her zaman açık olsun):

```bash
cd ~/actions-runner
sudo ./svc.sh install
sudo ./svc.sh start
```

6. **Durumu kontrol et:**

```bash
sudo ./svc.sh status
```

✅ Runner artık hazır! GitHub'da "Idle" olarak görünmeli.

---

## 4. Projeyi Sunucuya Kur

### 4.1. Proje Klasörü Oluştur

```bash
mkdir -p ~/rotax-app
cd ~/rotax-app
```

### 4.2. GitHub'dan Klonla

```bash
git clone https://github.com/YOUR_USERNAME/Rotax.git .
```

> `YOUR_USERNAME` yerine GitHub kullanıcı adınızı yazın

---

## 5. Environment Variables (.env)

### 5.1. Gmail App Password Oluştur

```
1. Gmail hesabınıza gidin
2. Hesap > Güvenlik > 2 Adımlı Doğrulama
3. Uygulama Şifreleri
4. "Rotax Backend" için şifre oluşturun
5. 16 haneli şifreyi not edin
```

### 5.2. .env Dosyası Oluştur

```bash
cd ~/rotax-app
nano .env
```

Aşağıdaki içeriği yapıştırın ve **değiştirin**:

```env
# Database - GÜÇ LÜ ŞİFRELER KULLANIN!
POSTGRES_DB=rotax_prod
POSTGRES_USER=rotax_admin
POSTGRES_PASSWORD=BURAYA_SUPER_GUVENLI_SIFRE_YAZIN

# RabbitMQ
RABBITMQ_USER=rotax_mq
RABBITMQ_PASS=BURAYA_RABBITMQ_SIFRESI_YAZIN

# JWT Secret
JWT_SECRET=cm90YXgtc3VwZXItc2VjcmV0LWp3dC1rZXktMjAyNS12ZXJ5LWxvbmctYW5kLXNlY3VyZS1rZXktZm9yLXByb2R1Y3Rpb24=
JWT_EXPIRATION=86400000

# Mail - Gmail bilgilerinizi yazın
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-16-digit-app-password

# Frontend URL - IP adresinizi yazın
FRONTEND_URL=http://34.76.123.45
```

**Ctrl+O** (kaydet), **Enter**, **Ctrl+X** (çık)

---

## 6. Nginx Yapılandırması

### 6.1. Nginx Config Oluştur

```bash
sudo nano /etc/nginx/sites-available/rotax
```

Aşağıdaki içeriği yapıştırın:

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    # Frontend
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:8080/api/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 90;
    }

    # Health check
    location /health {
        return 200 "OK\n";
        add_header Content-Type text/plain;
    }
}
```

**Ctrl+O**, **Enter**, **Ctrl+X**

### 6.2. Nginx'i Aktifleştir

```bash
# Symlink oluştur
sudo ln -s /etc/nginx/sites-available/rotax /etc/nginx/sites-enabled/

# Default config'i kaldır
sudo rm /etc/nginx/sites-enabled/default

# Config test et
sudo nginx -t

# Nginx'i restart et
sudo systemctl restart nginx
```

---

## 7. İlk Deployment

### 7.1. Docker Build

```bash
cd ~/rotax-app
docker compose build
```

Bu adım 5-10 dakika sürebilir. Bekleyin...

### 7.2. Servisleri Başlat

```bash
docker compose up -d
```

### 7.3. Logları Kontrol Et

```bash
docker compose logs -f
```

**Ctrl+C** ile çıkın.

### 7.4. Durum Kontrolü

```bash
# Container'lar çalışıyor mu?
docker compose ps

# Backend hazır mı?
curl http://localhost:8080/actuator/health

# Frontend hazır mı?
curl http://localhost:3000
```

Hepsi **200 OK** dönmeli.

---

## 8. Test Et

Tarayıcınızda açın:

```
http://34.76.123.45
```

✅ **Rotax frontend açılmalı!**

API dökümanları:
```
http://34.76.123.45/api/swagger-ui/
```

✅ **Swagger UI açılmalı!**

---

## 9. GitHub Actions (Otomatik Deployment)

Self-hosted runner zaten kurulu, şimdi GitHub Secrets ekleyip test edelim.

### 9.1. GitHub Secrets Ekle

```
1. GitHub Repo > Settings > Secrets and variables > Actions
2. "New repository secret" tıklayın
3. Aşağıdaki secret'ları ekleyin:
```

**Gerekli Secrets:**

```
POSTGRES_DB = rotax_prod
POSTGRES_USER = rotax_admin
POSTGRES_PASSWORD = (güçlü şifre - .env'dekiyle aynı)
RABBITMQ_USER = rotax_mq
RABBITMQ_PASS = (güçlü şifre - .env'dekiyle aynı)
JWT_SECRET = (base64 secret - .env'dekiyle aynı)
JWT_EXPIRATION = 86400000
MAIL_HOST = smtp.gmail.com
MAIL_PORT = 587
MAIL_USERNAME = your-email@gmail.com
MAIL_PASSWORD = (app password - .env'dekiyle aynı)
FRONTEND_URL = http://34.76.123.45
```

> **Not:** Şifreleri .env dosyasındakilerle aynı yapın!

### 9.2. Runner Kontrolü

Sunucuda runner çalışıyor mu kontrol et:

```bash
cd ~/actions-runner
sudo ./svc.sh status
```

GitHub'da kontrol et:
```
Settings > Actions > Runners
```

"rotax-server" **Idle** durumunda olmalı ✅

### 9.3. Test Deployment

Local makinenizde:

```bash
cd /path/to/Rotax

git add .
git commit -m "test: deployment"
git push origin main
```

GitHub Actions otomatik başlayacak:

1. GitHub Repo > Actions > Son workflow
2. Logları izleyin
3. ✅ Başarılı olmalı

**Artık her push'ta otomatik deployment!** 🚀

---

## 10. Günlük Kullanım

### Logları İzle

```bash
ssh server
cd ~/rotax-app

# Tüm loglar
docker compose logs -f

# Sadece backend
docker compose logs -f backend

# Sadece frontend
docker compose logs -f frontend
```

### Servis Yönetimi

```bash
# Durumu kontrol et
docker compose ps

# Restart
docker compose restart

# Durdur
docker compose down

# Başlat
docker compose up -d

# Yeniden build
docker compose up -d --build
```

### Manuel Deployment

```bash
ssh server
cd ~/rotax-app
git pull origin main
docker compose up -d --build
```

### Health Check

```bash
# Health script çalıştır
./scripts/check-health.sh

# Veya manuel:
curl http://34.76.123.45/health
curl http://34.76.123.45/api/actuator/health
```

---

## 11. Troubleshooting

### Frontend açılmıyor?

```bash
# Container çalışıyor mu?
docker compose ps

# Frontend logları
docker compose logs frontend

# Nginx durumu
sudo systemctl status nginx
sudo nginx -t

# Nginx logları
sudo tail -f /var/log/nginx/error.log
```

### Backend çalışmıyor?

```bash
# Backend logları
docker compose logs backend

# Database bağlantısı test et
docker compose exec postgres psql -U rotax_admin -d rotax_prod
```

### Port kapalı mı?

```bash
# Firewall kontrol
sudo ufw status

# Port açma
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### Container restart oluyor?

```bash
# Logları incele
docker compose logs --tail=100 backend

# Resource kullanımı
docker stats

# Disk doldu mu?
df -h
docker system df
```

---

## 12. Güvenlik

### SSH Güvenliği

```bash
sudo nano /etc/ssh/sshd_config
```

Değiştir:
```
PermitRootLogin no
PasswordAuthentication no
```

```bash
sudo systemctl restart sshd
```

### Firewall

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw enable
```

### Database Backup

```bash
# Script oluştur
nano ~/backup-db.sh
```

İçerik:
```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
docker compose exec -T postgres pg_dump -U rotax_admin rotax_prod > ~/backups/rotax_$DATE.sql
gzip ~/backups/rotax_$DATE.sql
find ~/backups -name "*.sql.gz" -mtime +7 -delete
```

```bash
chmod +x ~/backup-db.sh
mkdir ~/backups

# Cronjob (her gün 02:00)
crontab -e
# Ekle: 0 2 * * * ~/backup-db.sh
```

---

## 13. Hızlı Komutlar

```bash
# SSH kısa yol ekle (local makinede)
nano ~/.ssh/config
```

İçerik:
```
Host rotax
    HostName 34.76.123.45
    User your-username
    IdentityFile ~/.ssh/rotax-deploy
```

Artık:
```bash
ssh rotax
```

Tek komutla:
```bash
# Logları izle
ssh rotax "cd rotax-app && docker compose logs -f backend"

# Restart
ssh rotax "cd rotax-app && docker compose restart"

# Pull & deploy
ssh rotax "cd rotax-app && git pull && docker compose up -d --build"
```

---

## 📞 Erişim Bilgileri

- **Frontend**: http://34.76.123.45
- **Backend API**: http://34.76.123.45/api/
- **Swagger Docs**: http://34.76.123.45/api/swagger-ui/
- **RabbitMQ UI**: http://34.76.123.45:15672

---

## ⚠️ Önemli Notlar

1. **SSL YOK**: Domain olmadığı için HTTPS yok. Production için önerilmez.
2. **Şifreler**: .env dosyasındaki şifreleri mutlaka değiştirin!
3. **Firewall**: Sadece gerekli portları açık tutun.
4. **Backup**: Düzenli database backup'ı alın.
5. **Monitoring**: Logları düzenli kontrol edin.

---

**Deployment tamamlandı!** 🎉

Sorun olursa Troubleshooting bölümüne bakın veya GitHub Issues açın.
