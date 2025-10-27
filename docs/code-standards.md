# Code Standards & Structure

## Directory Organization

### Project Structure Philosophy
The Moodle Docker project follows a clear separation of concerns:
- **Infrastructure as Code**: Docker configurations separate from application
- **Script Organization**: Management scripts at root level for easy access
- **Data Separation**: Clear distinction between code, data, and configuration
- **Documentation First**: Comprehensive docs in dedicated directory

### Directory Layout Standards

```
moodle-docker/
├── [Root Level]              # Infrastructure and management
│   ├── docker-compose.yml   # Service orchestration
│   ├── Dockerfile*          # Container definitions
│   └── *.sh                 # Management scripts
│
├── [Application]            # Moodle application layer
│   ├── moodle/             # Source code (git-managed)
│   ├── moodledata/         # Persistent user data
│   └── config/             # Generated configurations
│
├── [Documentation]         # Project documentation
│   ├── docs/              # Technical documentation
│   └── README.md          # User-facing guide
│
└── [Development]          # Development tools
    ├── .claude/           # AI assistance workflows
    └── .opencode/         # Agent configurations
```

### File Organization Rules

1. **Script Files**
   - Location: Root directory
   - Naming: Lowercase with hyphens (init-simple.sh)
   - Purpose: Single responsibility per script
   - Permissions: Executable for management scripts

2. **Configuration Files**
   - Docker configs: Root level
   - Environment: .env files at root
   - Application: Generated in config/
   - Never commit: .env with secrets

3. **Documentation**
   - Technical: docs/ directory
   - User guide: README.md at root
   - Format: Markdown (.md)
   - Naming: Lowercase with hyphens

## Naming Conventions

### Docker Resources

#### Container Names
```yaml
container_name: moodle-app     # Format: project-service
container_name: moodle-db      # Hyphenated, lowercase
```

#### Image Names
```dockerfile
FROM php:8.2-apache            # Official: name:version-variant
FROM postgres:15-alpine        # Alpine preferred for size
```

#### Volume Names
```yaml
volumes:
  pgdata:                      # Short, descriptive
  moodledata:                  # No prefix needed
```

#### Network Names
```yaml
networks:
  moodle-network:             # Format: project-network
    driver: bridge
```

### Port Mapping Strategy

#### Port Assignment Rules
- **Base Port**: 10000+ to avoid conflicts
- **Service Offset**: Consistent spacing
- **Documentation**: Always document purpose

```yaml
ports:
  - "18080:80"      # Moodle Web (18xxx range)
  - "15432:5432"    # PostgreSQL (15xxx range)
  - "16379:6379"    # Redis (16xxx range)
  - "11025:1025"    # MailHog SMTP (11xxx range)
  - "18025:8025"    # MailHog UI (18xxx range)
```

### Environment Variables

#### Naming Standards
```bash
DB_HOST=postgres              # Service reference
DB_NAME=${DB_NAME:-moodle}   # With defaults
DB_USER=${DB_USER:-moodle}   # Uppercase, underscore
DB_PASSWORD=${DB_PASSWORD:-}  # No default for secrets
```

#### Variable Prefixes
- `DB_*`: Database configuration
- `APP_*`: Application settings
- `DOCKER_*`: Container settings
- `MOODLE_*`: Moodle-specific

## Docker Best Practices

### Dockerfile Standards

#### Layer Optimization
```dockerfile
# Good: Combine related operations
RUN apt-get update && apt-get install -y \
    package1 \
    package2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Bad: Multiple RUN statements
RUN apt-get update
RUN apt-get install package1
RUN apt-get install package2
```

#### Build Arguments
```dockerfile
ARG PHP_VERSION=8.2
FROM php:${PHP_VERSION}-apache
```

#### Labels
```dockerfile
LABEL maintainer="team@example.com"
LABEL version="1.0"
LABEL description="Moodle development environment"
```

### Docker Compose Standards

#### Service Definition Order
1. Primary application (moodle)
2. Database services (postgres)
3. Cache services (redis)
4. Utility services (mailhog)

#### Health Checks
```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-moodle}"]
  interval: 10s
  timeout: 5s
  retries: 5
```

#### Dependency Management
```yaml
depends_on:
  postgres:
    condition: service_healthy  # Wait for health check
```

## Shell Script Standards

### Script Structure

```bash
#!/bin/bash
#
# Script: init-simple.sh
# Purpose: Initialize Moodle installation
# Usage: ./init-simple.sh
#

set -e  # Exit on error

# Configuration
MOODLE_BRANCH="MOODLE_501_STABLE"
MOODLE_REPO="https://github.com/moodle/moodle.git"

# Functions
function check_requirements() {
    # Implementation
}

function main() {
    check_requirements
    # Main logic
}

# Execute
main "$@"
```

### Error Handling

```bash
# Exit codes
# 0: Success
# 1: General error
# 2: Missing dependency
# 3: Configuration error

if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed"
    exit 2
fi
```

### Logging Standards

```bash
# Logging functions
log_info() { echo "[INFO] $*"; }
log_error() { echo "[ERROR] $*" >&2; }
log_debug() { [ "$DEBUG" = "true" ] && echo "[DEBUG] $*"; }

# Usage
log_info "Starting Moodle initialization"
log_error "Database connection failed"
```

## Git Workflow

### Branch Management

```bash
main                  # Production-ready code
├── feature/*        # New features
├── fix/*           # Bug fixes
└── docs/*          # Documentation updates
```

### Commit Messages

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `refactor`: Code refactoring
- `test`: Testing
- `chore`: Maintenance

Examples:
```
feat(docker): add Redis cache service
fix(db): resolve connection timeout issue
docs(readme): update installation instructions
```

### .gitignore Standards

```gitignore
# Application
moodle/               # Cloned source
moodledata/          # User data
config/              # Generated configs

# Environment
.env                 # Local configuration
*.log               # Log files

# IDE
.idea/
.vscode/
*.swp

# OS
.DS_Store
Thumbs.db
```

## PHP Configuration Standards

### PHP.ini Settings

```ini
; Performance
memory_limit=256M
max_execution_time=600
opcache.enable=1

; Upload
upload_max_filesize=64M
post_max_size=64M

; Development
display_errors=On
error_reporting=E_ALL
```

### Extension Requirements

Required:
- gd (graphics)
- intl (internationalization)
- pdo_pgsql (database)
- zip (compression)
- opcache (performance)

Optional:
- redis (caching)
- xdebug (debugging)

## Database Standards

### PostgreSQL Configuration

```sql
-- Naming conventions
CREATE DATABASE moodle;
CREATE USER moodle WITH PASSWORD 'secure_password';

-- Table naming (Moodle standard)
mdl_user              -- Prefix: mdl_
mdl_course           -- Singular, lowercase
mdl_user_enrolments  -- Relationships: table1_table2
```

### Connection Pooling

```yaml
environment:
  - POSTGRES_MAX_CONNECTIONS=100
  - POSTGRES_SHARED_BUFFERS=256MB
```

## Security Standards

### Development Environment

#### Acceptable Practices
- Hardcoded passwords in .env.example
- Exposed ports for debugging
- Verbose error reporting
- Debug mode enabled

#### Unacceptable Practices
- Committing .env with real passwords
- Using production data
- Exposing admin interfaces publicly
- Skipping health checks

### Production Preparation

#### Required Changes
1. External secrets management
2. SSL/TLS certificates
3. Firewall configuration
4. Non-root users
5. Security headers
6. Rate limiting

## Testing Standards

### Container Testing

```bash
# Health check
docker-compose ps
docker exec moodle-app curl -f http://localhost/

# Database connectivity
docker exec moodle-db pg_isready

# Log verification
docker-compose logs --tail=50 moodle
```

### Code Testing

```bash
# PHPUnit
docker exec moodle-app php admin/tool/phpunit/cli/init.php
docker exec moodle-app vendor/bin/phpunit

# Behat
docker exec moodle-app php admin/tool/behat/cli/init.php
docker exec moodle-app vendor/bin/behat
```

## Documentation Standards

### Document Structure

```markdown
# Title

## Overview
Brief description

## Requirements
What's needed

## Usage
How to use

## Configuration
Available options

## Troubleshooting
Common issues

## References
Additional resources
```

### Code Documentation

```php
/**
 * Initialize Moodle configuration
 *
 * @param array $config Database configuration
 * @return bool Success status
 * @throws Exception On connection failure
 */
function init_moodle($config) {
    // Implementation
}
```

## Performance Standards

### Container Optimization

```dockerfile
# Multi-stage builds
FROM php:8.2-apache AS builder
# Build steps

FROM php:8.2-apache-slim
COPY --from=builder /app /app
```

### Resource Limits

```yaml
services:
  moodle:
    mem_limit: 512m
    cpus: '1.0'

  postgres:
    mem_limit: 256m
    cpus: '0.5'
```

## Monitoring Standards

### Logging

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### Health Monitoring

```bash
# Service health
docker-compose ps

# Resource usage
docker stats

# Log monitoring
docker-compose logs -f --tail=100
```

## Version Management

### Version Pinning

```yaml
services:
  postgres:
    image: postgres:15-alpine  # Specific version

  moodle:
    build:
      args:
        PHP_VERSION: 8.2      # Parameterized
```

### Upgrade Strategy

1. Test in development
2. Update version in Dockerfile
3. Document breaking changes
4. Provide migration scripts
5. Tag release

## Code Review Checklist

### Docker Files
- [ ] Optimized layer caching
- [ ] Security best practices
- [ ] Resource limits defined
- [ ] Health checks implemented
- [ ] Documentation updated

### Scripts
- [ ] Error handling included
- [ ] Help text provided
- [ ] Exit codes defined
- [ ] Logging implemented
- [ ] Tested on target OS

### Configuration
- [ ] Environment variables documented
- [ ] Defaults provided
- [ ] Secrets excluded from repo
- [ ] Port conflicts avoided
- [ ] Volume paths correct

## Compliance Requirements

### Open Source Compliance
- License compatibility verified
- Attribution requirements met
- Source code availability ensured
- Modification tracking maintained

### Docker Hub Compliance
- Base image licenses reviewed
- Security scanning enabled
- Vulnerability patches applied
- Image signing configured