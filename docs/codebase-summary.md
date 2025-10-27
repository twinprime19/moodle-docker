# Codebase Summary

## Repository Overview

Moodle Docker is a containerized development environment for Moodle LMS, providing automated setup, database management, and development tools through Docker Compose orchestration.

## Repository Structure

```
moodle-docker/
├── Docker Configuration
│   ├── docker-compose.yml       # Service orchestration configuration
│   ├── Dockerfile               # Full Moodle image with all extensions
│   └── Dockerfile.simple        # Minimal Moodle image (currently used)
│
├── Initialization Scripts
│   ├── init.sh                  # Full initialization with auto-install
│   ├── init-simple.sh           # Simple initialization (clone & start)
│   ├── start.sh                 # Service startup management
│   └── stop.sh                  # Clean shutdown script
│
├── Configuration
│   ├── .env.example             # Environment variable template
│   └── .env                     # Local environment configuration
│
├── Application Directories
│   ├── moodle/                  # Moodle source code (auto-cloned, git-ignored)
│   ├── moodledata/              # Moodle data files (persistent storage)
│   └── config/                  # Generated Moodle configuration
│
├── Documentation
│   ├── docs/
│   │   ├── project-overview-pdr.md
│   │   ├── codebase-summary.md (this file)
│   │   ├── code-standards.md
│   │   ├── system-architecture.md
│   │   └── RELEASE.md
│   └── README.md                # Quick start guide
│
└── Development Tools
    ├── .claude/                 # Claude AI workflows
    ├── .opencode/               # OpenCode agent configurations
    ├── .gitignore               # Git exclusions
    └── .mcp.json                # MCP configuration
```

## Key Components

### 1. Docker Services

#### Moodle Application Container
- **Image**: Custom PHP 8.2 Apache image
- **Port**: 18080 (mapped from internal 80)
- **Volumes**:
  - `./moodle:/var/www/html` (source code)
  - `./moodledata:/var/www/moodledata` (user files)
- **Dependencies**: PostgreSQL health check

#### PostgreSQL Database
- **Image**: postgres:15-alpine
- **Port**: 15432 (mapped from internal 5432)
- **Volume**: `pgdata` (persistent database storage)
- **Health Check**: pg_isready command
- **Credentials**: Configurable via .env

#### Network Configuration
- **Network**: moodle-network (bridge driver)
- **DNS**: Internal service resolution

### 2. Initialization Process

#### Simple Initialization (init-simple.sh)
1. Checks for existing Moodle installation
2. Clones Moodle 501_STABLE from GitHub
3. Sets proper file permissions
4. Starts Apache in foreground

#### Full Initialization (init.sh)
1. Performs simple initialization steps
2. Waits for database availability
3. Creates Moodle configuration
4. Runs automated installation
5. Sets admin credentials
6. Configures development settings

### 3. Management Scripts

#### start.sh
- Creates necessary directories
- Validates environment file
- Starts containers with build
- Displays access information
- Shows real-time logs

#### stop.sh
- Gracefully stops Moodle container
- Stops PostgreSQL container
- Preserves data volumes
- Cleans up processes

## Technology Stack

### Core Technologies
- **Container Platform**: Docker & Docker Compose
- **Web Server**: Apache 2.4
- **Programming Language**: PHP 8.2
- **Database**: PostgreSQL 15
- **LMS Platform**: Moodle 501_STABLE

### PHP Extensions
- **Graphics**: gd (with freetype, jpeg)
- **Database**: pdo, pdo_pgsql, pgsql
- **Internationalization**: intl
- **Compression**: zip
- **Performance**: opcache

### Development Tools
- **Version Control**: Git
- **Database Client**: postgresql-client
- **Process Management**: Apache mod_rewrite

## Dependencies

### External Dependencies
- Docker Engine 20.10+
- Docker Compose 2.0+
- Internet connection (for Moodle cloning)

### Moodle Dependencies
- GitHub repository: https://github.com/moodle/moodle.git
- Branch: MOODLE_501_STABLE (configurable)
- Automatic shallow clone for efficiency

### System Requirements
- **RAM**: 4GB minimum
- **Disk Space**: 10GB minimum
- **OS**: macOS, Linux, Windows (WSL2)

## Development Workflow

### Initial Setup
1. Clone repository
2. Copy `.env.example` to `.env`
3. Run `docker-compose up -d`
4. Wait for initialization (~5 minutes)
5. Access at http://localhost:18080

### Daily Development
1. Start services: `./start.sh`
2. Edit code in `./moodle/`
3. Changes reflect immediately
4. View logs: `docker logs -f moodle-app`
5. Stop services: `./stop.sh`

### Version Management
1. Navigate to moodle directory
2. Fetch updates: `git fetch`
3. Switch branch: `git checkout MOODLE_XXX_STABLE`
4. Restart container: `docker-compose restart moodle`

### Database Operations
- **Direct access**: `docker exec -it moodle-db psql -U moodle`
- **Backup**: Use pg_dump through container
- **Reset**: Remove pgdata volume

### Cache Management
- **Clear all**: `docker exec -it moodle-app php admin/cli/purge_caches.php`
- **Restart services**: `docker-compose restart`

## Configuration Management

### Environment Variables (.env)
```bash
DB_NAME=moodle              # Database name
DB_USER=moodle              # Database user
DB_PASSWORD=moodle_pass_2024 # Database password
```

### Port Configuration
| Service | Internal | External | Purpose |
|---------|----------|----------|---------|
| Moodle | 80 | 18080 | Web interface |
| PostgreSQL | 5432 | 15432 | Database |
| Redis | 6379 | 16379 | Cache (planned) |
| MailHog SMTP | 1025 | 11025 | Email testing |
| MailHog UI | 8025 | 18025 | Email viewer |

### Volume Management
- **pgdata**: PostgreSQL data (Docker managed)
- **moodledata**: User uploads, cache (host mounted)
- **moodle**: Source code (host mounted, git-ignored)

## Testing Approach

### Local Testing
- Manual testing via web interface
- CLI testing through Docker exec
- Database query testing via psql
- Log analysis via Docker logs

### Automated Testing
- PHPUnit support through Moodle CLI
- Behat acceptance testing capability
- Custom test data generation

## Security Considerations

### Development Security
- **Credentials**: Hardcoded for development only
- **Ports**: Bound to localhost only
- **Permissions**: www-data user for web files
- **SSL/TLS**: Not configured (development only)

### Production Warnings
- Change all default passwords
- Implement proper secret management
- Configure SSL/TLS certificates
- Restrict port access
- Implement firewall rules

## Performance Optimizations

### Current Optimizations
- Alpine Linux for smaller images
- Shallow Git clone for faster setup
- OPcache enabled for PHP
- Health checks for reliability

### Planned Optimizations
- Redis cache integration
- PHP-FPM implementation
- Static asset optimization
- Database query optimization

## Troubleshooting Guide

### Common Issues
1. **Port conflicts**: Modify ports in docker-compose.yml
2. **Permission errors**: Check file ownership
3. **Database connection**: Wait for initialization
4. **Memory issues**: Increase Docker resources

### Reset Procedures
```bash
# Complete reset
./stop.sh
docker-compose down -v
rm -rf moodle moodledata config
docker-compose up -d
```

## Future Enhancements

### Short-term (Q1 2025)
- Redis cache implementation
- MailHog integration completion
- Improved logging system
- Development profiling tools

### Medium-term (Q2-Q3 2025)
- Multi-version support
- Plugin development templates
- Automated testing suite
- Performance monitoring

### Long-term (Q4 2025+)
- Production deployment templates
- Kubernetes manifests
- CI/CD pipeline integration
- High availability setup

## Contributing Guidelines

### Code Contributions
1. Follow Docker best practices
2. Test all changes locally
3. Document new features
4. Update relevant scripts

### Documentation
1. Keep README concise
2. Detail technical changes here
3. Update architecture diagrams
4. Include troubleshooting tips

## License & Compliance

- Repository: Open source (check LICENSE file)
- Moodle: GNU GPL v3
- Docker images: Various open source licenses
- PostgreSQL: PostgreSQL License

## Maintenance Notes

### Regular Maintenance
- Update base images monthly
- Check Moodle security updates
- Review and update dependencies
- Clean unused volumes/images

### Version Updates
- Test new Moodle versions
- Update PHP version compatibility
- PostgreSQL major version upgrades
- Docker Compose syntax updates