.PHONY: help up down restart logs build clean frontend backend db rabbitmq

# Default target
help:
	@echo "Rotax Full Stack - Docker Commands"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  up          - Start all services"
	@echo "  down        - Stop all services"
	@echo "  restart     - Restart all services"
	@echo "  logs        - Show all logs"
	@echo "  build       - Build all images"
	@echo "  clean       - Stop and remove volumes"
	@echo ""
	@echo "Individual Services:"
	@echo "  frontend    - Start only frontend"
	@echo "  backend     - Start only backend"
	@echo "  db          - Start only database"
	@echo "  rabbitmq    - Start only RabbitMQ"
	@echo ""
	@echo "Logs:"
	@echo "  logs-f      - Follow all logs"
	@echo "  logs-b      - Backend logs"
	@echo "  logs-fe     - Frontend logs"

# Start all services
up:
	docker compose up -d

# Stop all services
down:
	docker compose down

# Restart all services
restart:
	docker compose restart

# Show logs
logs:
	docker compose logs

logs-f:
	docker compose logs -f

logs-b:
	docker compose logs -f backend

logs-fe:
	docker compose logs -f frontend

# Build images
build:
	docker compose build

# Build without cache
build-fresh:
	docker compose build --no-cache

# Clean everything
clean:
	docker compose down -v --rmi local

# Individual services
frontend:
	docker compose up -d frontend

backend:
	docker compose up -d backend postgres rabbitmq

db:
	docker compose up -d postgres

rabbitmq:
	docker compose up -d rabbitmq

# Status
status:
	docker compose ps

# Shell access
shell-backend:
	docker compose exec backend sh

shell-frontend:
	docker compose exec frontend sh

shell-db:
	docker compose exec postgres psql -U rotax -d rotax
