# 🔧 Troubleshooting Guide

## Kurulum Hataları

### 1. apt lock hatası (Docker kurulumu sırasında)

**Hata:**
```
E: Could not get lock /var/lib/apt/lists/lock. It is held by process XXXX (apt-get)
```

**Sebep:** Başka bir apt işlemi çalışıyor (genellikle otomatik güncellemeler)

**Çözüm 1 - Bekle (Önerilen):**
```bash
# Hangi process kullanıyor kontrol et
ps aux | grep apt

# Bekle (1-2 dakika)
# Otomatik güncellemeler bitince tekrar dene
./get-docker.sh
```

**Çözüm 2 - Process'i Öldür:**
```bash
# Process ID'yi bul
sudo lsof /var/lib/apt/lists/lock

# Process'i öldür (dikkatli!)
sudo kill -9 PROCESS_ID

# Lock dosyalarını temizle
sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock*

# dpkg'yi düzelt
sudo dpkg --configure -a

# Tekrar dene
sudo apt update
./get-docker.sh
```

**Çözüm 3 - Otomatik Güncellemeleri Durdur:**
```bash
# Önce otomatik güncellemeleri durdur
sudo systemctl stop unattended-upgrades
sudo systemctl disable unattended-upgrades

# Şimdi Docker kur
./get-docker.sh

# İsteğe bağlı: Güncellemeleri tekrar aç
sudo systemctl enable unattended-upgrades
sudo systemctl start unattended-upgrades
```

---

### 2. Docker build çok yavaş

**Sebep:** VM'de yeterli kaynak yok

**Çözüm:**
```bash
# VM size'ı büyüt (Google Cloud Console'dan)
# e2-medium -> e2-standard-2 (2 vCPU, 8 GB RAM)

# Veya build sırasında limit koy
docker compose build --parallel 1
```

---

### 3. Port 80 açılmıyor

**Hata:** `curl http://localhost:80` çalışmıyor

**Çözüm:**
```bash
# Nginx çalışıyor mu?
sudo systemctl status nginx

# Nginx yeniden başlat
sudo systemctl restart nginx

# Port dinliyor mu?
sudo netstat -tulpn | grep :80

# Firewall kontrol
sudo ufw status
sudo ufw allow 80/tcp
```

---

### 4. GitHub Actions runner bağlanamıyor

**Hata:** Runner "Offline" görünüyor

**Çözüm:**
```bash
# Runner durumu
cd ~/actions-runner
sudo ./svc.sh status

# Yeniden başlat
sudo ./svc.sh stop
sudo ./svc.sh start

# Logları kontrol et
tail -f ~/actions-runner/_diag/*.log
```

---

### 5. Backend container sürekli restart oluyor

**Çözüm:**
```bash
# Logları incele
docker compose logs backend

# Database bağlantısı kontrol et
docker compose exec postgres psql -U rotax_admin -d rotax_prod

# .env dosyası doğru mu?
cat ~/rotax-app/.env

# Container kaynak kullanımı
docker stats
```

---

### 6. Frontend API'ye bağlanamıyor

**Hata:** Frontend açılıyor ama API istekleri başarısız

**Çözüm:**
```bash
# Nginx config doğru mu?
sudo nginx -t

# Backend çalışıyor mu?
curl http://localhost:8080/actuator/health

# API endpoint test
curl http://localhost/api/health

# CORS hatası varsa backend loglarına bak
docker compose logs backend | grep CORS
```

---

## Runtime Hataları

### 7. Database bağlantı hatası

**Hata:** `Connection refused` veya `password authentication failed`

**Çözüm:**
```bash
# PostgreSQL çalışıyor mu?
docker compose ps postgres

# Database şifresi doğru mu?
cat .env | grep POSTGRES

# Manuel bağlantı testi
docker compose exec postgres psql -U rotax_admin -d rotax_prod

# Database logları
docker compose logs postgres
```

---

### 8. RabbitMQ bağlanamıyor

**Çözüm:**
```bash
# RabbitMQ çalışıyor mu?
docker compose ps rabbitmq

# Port dinliyor mu?
docker compose exec rabbitmq rabbitmq-diagnostics ping

# Management UI
curl http://localhost:15672

# Şifre doğru mu?
cat .env | grep RABBITMQ
```

---

### 9. Disk dolu hatası

**Hata:** `No space left on device`

**Çözüm:**
```bash
# Disk kullanımı
df -h

# Docker disk kullanımı
docker system df

# Temizlik yap
docker system prune -a -f
docker volume prune -f

# Eski logları temizle
sudo journalctl --vacuum-time=3d

# Eski backupları sil
find ~/backups -name "*.sql.gz" -mtime +7 -delete
```

---

### 10. Memory yetersiz

**Hata:** Container OOM (Out of Memory) kill ediliyor

**Çözüm:**
```bash
# Memory kullanımı
free -h
docker stats

# Swap ekle
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Kalıcı yap
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

---

## Deployment Hataları

### 11. GitHub Actions workflow başarısız

**Çözüm:**
```bash
# Runner çalışıyor mu?
cd ~/actions-runner
sudo ./svc.sh status

# Logları kontrol et
GitHub > Actions > Failed workflow > Logs

# Sunucuda manuel test et
cd ~/rotax-app
git pull
docker compose build
docker compose up -d
```

---

### 12. SSL olmadan çalışmıyor

**Not:** Domain olmadan SSL olmaz! Bu normal.

**Çözüm:**
```bash
# HTTP ile eriş (HTTPS değil)
http://34.76.123.45

# Mixed content hatası varsa
# Frontend'de tüm URL'leri http:// yap
```

---

## Güvenlik Hataları

### 13. SSH bağlanamıyor

**Hata:** `Permission denied (publickey)`

**Çözüm:**
```bash
# Key doğru mu?
ssh -i ~/.ssh/rotax-deploy -v user@IP

# Key Google Cloud'da var mı?
# Compute Engine > Metadata > SSH Keys

# Key izinleri
chmod 600 ~/.ssh/rotax-deploy
chmod 644 ~/.ssh/rotax-deploy.pub
```

---

### 14. Firewall tüm trafiği engelliyor

**Çözüm:**
```bash
# Firewall durumu
sudo ufw status

# HTTP/HTTPS port aç
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp

# Reload
sudo ufw reload
```

---

## Performance Sorunları

### 15. Yavaş yanıt süresi

**Çözüm:**
```bash
# Resource kullanımı
htop
docker stats

# Nginx cache ekle
sudo nano /etc/nginx/sites-available/rotax
# proxy_cache ekle

# Database index'leri kontrol et
docker compose exec postgres psql -U rotax_admin -d rotax_prod
\di
```

---

### 16. Build çok uzun sürüyor

**Çözüm:**
```bash
# Docker cache kullan
docker compose build

# Multi-stage build optimize et
# Dockerfile'da layer'ları azalt

# BuildKit kullan
DOCKER_BUILDKIT=1 docker compose build
```

---

## Hızlı Komutlar

### Tüm Servisleri Restart
```bash
docker compose restart
```

### Logları Temizle
```bash
docker compose down
docker system prune -a -f
docker compose up -d
```

### Database Reset
```bash
docker compose down -v  # Dikkat! Tüm data silinir
docker compose up -d
```

### Manuel Deployment
```bash
cd ~/rotax-app
git pull origin main
docker compose down
docker compose build --no-cache
docker compose up -d
```

---

## Yardım

Sorun çözülmediyse:

1. **Logları topla:**
```bash
docker compose logs > logs.txt
sudo journalctl -xe > system-logs.txt
```

2. **GitHub Issues aç:**
   - Hata mesajını ekle
   - Logları ekle
   - Adımları detaylı yaz

3. **Sunucu bilgilerini ekle:**
```bash
uname -a
docker --version
docker compose version
free -h
df -h
```

---

**En sık sorunlar:** apt lock, memory, disk dolu, firewall
