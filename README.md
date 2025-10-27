# Moodle Docker Setup

Docker Compose setup for Moodle 501_STABLE development environment.

## Documentation

- [Project Overview & PDR](docs/project-overview-pdr.md) - Project purpose, requirements, and roadmap
- [System Architecture](docs/system-architecture.md) - Technical architecture and design decisions
- [Codebase Summary](docs/codebase-summary.md) - Repository structure and component details
- [Code Standards](docs/code-standards.md) - Coding conventions and best practices

## Quick Start

1. **Copy environment file:**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` if you want custom passwords.

2. **Start services:**
   ```bash
   docker-compose up -d --build
   ```
   First run will take ~5 minutes to:
   - Build PHP 8.2 image with extensions
   - Clone Moodle 501_STABLE from GitHub
   - Set up PostgreSQL database

3. **Wait for Moodle to be ready:**
   ```bash
   docker logs -f moodle-app
   ```
   Wait until you see Apache started.

4. **Access Moodle:**
   - URL: http://localhost:18080
   - Complete the installation wizard
   - Admin credentials you'll create during setup

## Services & Ports

| Service | Internal Port | External Port | Purpose |
|---------|--------------|---------------|---------|
| Moodle | 80 | 18080 | Web interface |
| PostgreSQL | 5432 | 15432 | Database |
| Redis | 6379 | 16379 | Cache/Sessions |
| MailHog | 1025 | 11025 | SMTP |
| MailHog UI | 8025 | 18025 | Email viewer |

## Managing Moodle

### Stop all services
```bash
./stop.sh
```

### Update Moodle source
```bash
cd moodle
git pull origin MOODLE_501_STABLE
```

### Switch Moodle version
```bash
cd moodle
git fetch
git checkout MOODLE_502_STABLE  # or any branch
docker-compose restart moodle
```

### View logs
```bash
docker-compose logs -f moodle
```

### Access database
```bash
docker exec -it moodle-db psql -U moodle
```

### Clear cache
```bash
docker exec -it moodle-app php admin/cli/purge_caches.php
```

## Directory Structure

```
moodle-docker/
├── docker-compose.yml     # Services configuration
├── Dockerfile            # Moodle image build
├── init.sh              # Auto-installation script
├── stop.sh              # Clean shutdown script
├── .env                 # Your environment config
├── moodle/              # Moodle source (auto-cloned)
├── moodledata/          # Moodle files/uploads
└── config/              # Generated configs
```

## Troubleshooting

### Reset everything
```bash
./stop.sh
docker-compose down -v
rm -rf moodle moodledata config
docker-compose up -d
```

### Port conflicts
All ports are non-default to avoid conflicts. If needed, edit `docker-compose.yml`.

### Database connection issues
Wait ~30 seconds on first run for database initialization.

## Development Notes

- Moodle source in `./moodle/` is not committed (see .gitignore)
- You can edit code directly in `./moodle/` - changes reflect immediately
- Database persists in Docker volume `pgdata`
- Uploaded files persist in `./moodledata/`

## Requirements

- Docker & Docker Compose
- 4GB+ RAM recommended
- 10GB+ disk space