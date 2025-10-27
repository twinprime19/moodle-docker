#!/bin/bash

echo "Stopping Moodle Docker containers..."

# Stop and remove containers
docker-compose down

# Kill any processes on our custom ports
echo "Cleaning up ports..."

# Function to kill process on port
kill_port() {
    local port=$1
    local pid=$(lsof -ti:$port 2>/dev/null)
    if [ ! -z "$pid" ]; then
        echo "Killing process on port $port (PID: $pid)"
        kill -9 $pid 2>/dev/null
    fi
}

# Kill processes on our custom ports
kill_port 18080  # Moodle web
kill_port 15432  # PostgreSQL
kill_port 16379  # Redis
kill_port 11025  # MailHog SMTP
kill_port 18025  # MailHog Web UI

echo "All Moodle services stopped and ports cleaned."

# Optional: Remove volumes (uncomment if needed)
# read -p "Remove data volumes? (y/N): " -n 1 -r
# echo
# if [[ $REPLY =~ ^[Yy]$ ]]; then
#     docker-compose down -v
#     echo "Volumes removed."
# fi