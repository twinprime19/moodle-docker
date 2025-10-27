# Moodle Docker Development Environment

A streamlined Docker Compose setup for Moodle 501_STABLE development with non-conflicting ports and automated installation.

## Documentation

- [Project Overview & PDR](docs/project-overview-pdr.md) - Project purpose, requirements, and roadmap
- [System Architecture](docs/system-architecture.md) - Technical architecture and design decisions
- [Codebase Summary](docs/codebase-summary.md) - Repository structure and component details
- [Code Standards](docs/code-standards.md) - Coding conventions and best practices
- [Deployment Guide](docs/deployment-guide.md) - Production deployment considerations
- [Project Roadmap](docs/project-roadmap.md) - Development roadmap and future plans

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
   Or use the start script:
   ```bash
   ./start.sh
   ```
   First run will take ~5 minutes to:
   - Build PHP 8.2 image with essential extensions
   - Clone Moodle 501_STABLE from GitHub (shallow clone)
   - Set up PostgreSQL 15 database with health checks

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

| Service | Internal Port | External Port | Purpose | Status |
|---------|--------------|---------------|---------|---------|
| Moodle | 80 | 18080 | Web interface | ✅ Active |
| PostgreSQL | 5432 | 15432 | Database | ✅ Active |
| Redis | 6379 | 16379 | Cache/Sessions | ⏳ Planned |
| MailHog | 1025 | 11025 | SMTP | ⏳ Configured |
| MailHog UI | 8025 | 18025 | Email viewer | ⏳ Configured |

**Note**: Redis and MailHog are configured but not currently in the Docker Compose stack. They can be added as needed.

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
├── docker-compose.yml     # Services configuration (2 services)
├── Dockerfile            # Full Moodle image (unused)
├── Dockerfile.simple     # Simple Moodle image (current)
├── init.sh              # Full auto-installation script
├── init-simple.sh       # Simple initialization script
├── start.sh             # Startup script with status
├── stop.sh              # Clean shutdown with port cleanup
├── .env.example         # Environment template
├── .env                 # Your environment config (created from template)
├── moodle/              # Moodle source (auto-cloned, git-ignored)
├── moodledata/          # Moodle files/uploads (persistent)
└── docs/                # Project documentation
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