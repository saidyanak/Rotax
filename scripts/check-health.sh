#!/bin/bash

# Health Check Script
# Check if all services are running properly

echo "========================================="
echo "🏥 Rotax Health Check"
echo "========================================="

cd ~/rotax-app

# Check Docker containers
echo ""
echo "📦 Docker Containers:"
docker compose -f docker-compose.prod.yml ps

echo ""
echo "📊 Container Stats:"
docker stats --no-stream

# Check services
echo ""
echo "🌐 Service Health Checks:"

# Frontend
if curl -f -s http://localhost:3000/health > /dev/null 2>&1; then
    echo "✅ Frontend is healthy"
else
    echo "❌ Frontend is down"
fi

# Backend
if curl -f -s http://localhost:8080/actuator/health > /dev/null 2>&1; then
    echo "✅ Backend is healthy"
else
    echo "❌ Backend is down"
fi

# PostgreSQL
if docker compose -f docker-compose.prod.yml exec -T postgres pg_isready > /dev/null 2>&1; then
    echo "✅ PostgreSQL is healthy"
else
    echo "❌ PostgreSQL is down"
fi

# RabbitMQ
if curl -f -s http://localhost:15672 > /dev/null 2>&1; then
    echo "✅ RabbitMQ is healthy"
else
    echo "❌ RabbitMQ is down"
fi

# Nginx
if sudo systemctl is-active --quiet nginx; then
    echo "✅ Nginx is running"
else
    echo "❌ Nginx is down"
fi

# Disk usage
echo ""
echo "💾 Disk Usage:"
df -h / | tail -1

# Docker disk usage
echo ""
echo "🐳 Docker Disk Usage:"
docker system df

echo ""
echo "========================================="
echo "Health check completed!"
echo "========================================="
