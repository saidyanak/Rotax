# ===========================================
# ROTAX BACKEND - MAKEFILE
# ===========================================
# Kullanım: make <komut>
# Yardım: make help

.PHONY: help up down build logs shell db-shell clean restart status test

# Varsayılan komut
.DEFAULT_GOAL := help

# Renkler
GREEN  := \033[0;32m
YELLOW := \033[0;33m
CYAN   := \033[0;36m
RESET  := \033[0m

help: ## Bu yardım mesajını gösterir
	@echo ""
	@echo "$(CYAN)Rotax Backend - Kullanılabilir Komutlar$(RESET)"
	@echo "========================================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-15s$(RESET) %s\n", $$1, $$2}'
	@echo ""

# -------------------------------------------
# Docker Compose Komutları
# -------------------------------------------

up: ## Tüm servisleri başlatır (backend + database)
	@echo "$(CYAN)🚀 Servisler başlatılıyor...$(RESET)"
	docker compose up -d
	@echo "$(GREEN)✅ Servisler başlatıldı!$(RESET)"
	@echo "   API: http://localhost:8080"
	@echo "   Swagger: http://localhost:8080/swagger-ui.html"

down: ## Tüm servisleri durdurur
	@echo "$(YELLOW)⏹️  Servisler durduruluyor...$(RESET)"
	docker compose down
	@echo "$(GREEN)✅ Servisler durduruldu!$(RESET)"

build: ## Image'ları yeniden oluşturur ve başlatır
	@echo "$(CYAN)🔨 Image'lar oluşturuluyor...$(RESET)"
	docker compose up -d --build
	@echo "$(GREEN)✅ Build tamamlandı!$(RESET)"

restart: ## Servisleri yeniden başlatır
	@echo "$(YELLOW)🔄 Servisler yeniden başlatılıyor...$(RESET)"
	docker compose restart
	@echo "$(GREEN)✅ Servisler yeniden başlatıldı!$(RESET)"

logs: ## Tüm servislerin loglarını gösterir
	docker compose logs -f

logs-backend: ## Sadece backend loglarını gösterir
	docker compose logs -f backend

logs-db: ## Sadece database loglarını gösterir
	docker compose logs -f db

status: ## Servislerin durumunu gösterir
	@echo "$(CYAN)📊 Servis Durumları:$(RESET)"
	docker compose ps

# -------------------------------------------
# Shell Erişimi
# -------------------------------------------

shell: ## Backend container'a shell bağlantısı açar
	docker compose exec backend /bin/bash

db-shell: ## PostgreSQL shell açar
	docker compose exec db psql -U postgres -d rotax

# -------------------------------------------
# Temizlik
# -------------------------------------------

clean: ## Servisleri durdurur ve volume'ları siler
	@echo "$(YELLOW)🧹 Temizlik yapılıyor...$(RESET)"
	docker compose down -v
	@echo "$(GREEN)✅ Temizlik tamamlandı!$(RESET)"

prune: ## Kullanılmayan Docker kaynaklarını temizler
	@echo "$(YELLOW)🧹 Docker prune yapılıyor...$(RESET)"
	docker system prune -f
	@echo "$(GREEN)✅ Prune tamamlandı!$(RESET)"

# -------------------------------------------
# Geliştirme
# -------------------------------------------

init: ## İlk kurulum: .env dosyasını oluşturur
	@if [ ! -f .env ]; then \
		cp .env-example .env; \
		echo "$(GREEN)✅ .env dosyası oluşturuldu. Lütfen değerleri düzenleyin.$(RESET)"; \
	else \
		echo "$(YELLOW)⚠️  .env dosyası zaten mevcut.$(RESET)"; \
	fi

test: ## Testleri çalıştırır
	docker compose exec backend ./mvnw test

# -------------------------------------------
# Sadece Database
# -------------------------------------------

db-up: ## Sadece database'i başlatır
	docker compose up -d db
	@echo "$(GREEN)✅ Database başlatıldı! (localhost:5432)$(RESET)"

db-down: ## Database'i durdurur
	docker compose stop db
