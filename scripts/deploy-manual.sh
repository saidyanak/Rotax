#!/bin/bash

# Manual Deployment Script
# Run this on the server for manual deployments

set -e

cd ~/rotax-app

echo "========================================="
echo "🚀 Rotax Manual Deployment"
echo "========================================="

# Pull latest code
echo "📥 Pulling latest code..."
git pull origin main

# Pull latest Docker images
echo "📦 Pulling Docker images..."
docker compose -f docker-compose.prod.yml pull

# Stop services
echo "🛑 Stopping services..."
docker compose -f docker-compose.prod.yml down

# Start services
echo "▶️  Starting services..."
docker compose -f docker-compose.prod.yml up -d

# Wait for services
echo "⏳ Waiting for services to start..."
sleep 15

# Check status
echo "📊 Service status:"
docker compose -f docker-compose.prod.yml ps

# Show logs
echo "📝 Recent logs:"
docker compose -f docker-compose.prod.yml logs --tail=30

# Cleanup
echo "🧹 Cleaning up..."
docker image prune -f

echo "========================================="
echo "✅ Deployment completed!"
echo "========================================="
