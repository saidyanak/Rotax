# ✅ Rotax Server Setup Checklist

## 1. Google Cloud VM ✅

- [ ] VM Instance oluşturuldu (e2-medium, Ubuntu 24.04)
- [ ] Static IP alındı: `___.___.___.___`
- [ ] Firewall HTTP/HTTPS açık

## 2. SSH Bağlantısı ✅

- [ ] SSH key oluşturuldu: `~/.ssh/rotax-deploy`
- [ ] Public key Google Cloud'a eklendi
- [ ] SSH bağlantısı test edildi

## 3. Server Kurulumu ✅

- [ ] Docker kuruldu
- [ ] Docker Compose kuruldu
- [ ] Nginx kuruldu
- [ ] Git kuruldu
- [ ] GitHub Actions Runner kuruldu ve çalışıyor

## 4. Proje Kurulumu ✅

- [ ] Proje klonlandı: `~/rotax-app`
- [ ] `.env` dosyası oluşturuldu
- [ ] Gmail App Password eklendi
- [ ] IP adresi `FRONTEND_URL`'e yazıldı

## 5. Nginx Yapılandırması ✅

- [ ] `/etc/nginx/sites-available/rotax` oluşturuldu
- [ ] Symlink eklendi: `/etc/nginx/sites-enabled/rotax`
- [ ] Default config silindi
- [ ] `nginx -t` başarılı
- [ ] Nginx restart edildi

## 6. İlk Deployment ✅

- [ ] `docker compose build` çalıştırıldı
- [ ] `docker compose up -d` çalıştırıldı
- [ ] Container'lar çalışıyor: `docker compose ps`
- [ ] Backend health OK: `curl http://localhost:8080/actuator/health`
- [ ] Frontend OK: `curl http://localhost:3000`

## 7. Test ✅

- [ ] Tarayıcıda frontend açıldı: `http://IP_ADRESI`
- [ ] Swagger UI açıldı: `http://IP_ADRESI/api/swagger-ui/`

## 8. GitHub Actions ✅

- [ ] Runner sunucuda çalışıyor: `~/actions-runner/svc.sh status`
- [ ] GitHub'da runner "Idle" görünüyor
- [ ] Secrets eklendi (11 adet)
- [ ] Test push yapıldı
- [ ] Workflow başarılı

## 9. Güvenlik ✅

- [ ] SSH password auth kapatıldı
- [ ] Firewall aktif: `sudo ufw enable`
- [ ] Database şifreleri güçlü
- [ ] .env dosyası güvenli

## 10. Backup ✅

- [ ] Backup scripti oluşturuldu: `~/backup-db.sh`
- [ ] Cronjob eklendi
- [ ] Backup klasörü: `~/backups`

---

## Hızlı Erişim Bilgileri

```bash
# SSH
ssh -i ~/.ssh/rotax-deploy USER@IP

# Loglar
ssh rotax "cd rotax-app && docker compose logs -f backend"

# Restart
ssh rotax "cd rotax-app && docker compose restart"

# Health
curl http://IP_ADRESI/health
```

## URL'ler

- **Frontend**: http://IP_ADRESI
- **API**: http://IP_ADRESI/api/
- **Swagger**: http://IP_ADRESI/api/swagger-ui/
- **RabbitMQ**: http://IP_ADRESI:15672

## GitHub Secrets (Gerekli)

1. POSTGRES_DB
2. POSTGRES_USER
3. POSTGRES_PASSWORD
4. RABBITMQ_USER
5. RABBITMQ_PASS
6. JWT_SECRET
7. JWT_EXPIRATION
8. MAIL_HOST
9. MAIL_PORT
10. MAIL_USERNAME
11. MAIL_PASSWORD
12. FRONTEND_URL

---

✅ **Tüm adımlar tamamlandığında deployment hazır!**
