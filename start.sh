#!/bin/bash

echo "Starting Moodle Docker environment..."

# Check if .env exists
if [ ! -f .env ]; then
    echo "Creating .env from .env.example..."
    cp .env.example .env
fi

# Pull latest images
echo "Pulling Docker images..."
docker-compose pull

# Build and start containers
echo "Building and starting containers..."
docker-compose up -d --build

# Wait for services to be ready
echo "Waiting for services to initialize..."
sleep 5

# Check container status
echo ""
echo "Container status:"
docker-compose ps

echo ""
echo "=========================================="
echo "Moodle Docker environment started!"
echo "=========================================="
echo ""
echo "Access points:"
echo "  - Moodle:    http://localhost:18080"
echo "  - MailHog:   http://localhost:18025"
echo "  - Database:  localhost:15432"
echo "  - Redis:     localhost:16379"
echo ""
echo "Credentials:"
echo "  - Admin:     admin / Admin@2024!"
echo ""
echo "Note: First run will take 3-5 minutes to:"
echo "  1. Clone Moodle 501_STABLE"
echo "  2. Install database"
echo "  3. Configure site"
echo ""
echo "Check logs: docker-compose logs -f moodle"
echo "Stop all:   ./stop.sh"