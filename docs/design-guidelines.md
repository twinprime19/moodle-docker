# Design Guidelines

## Overview

This document outlines the design principles, architectural decisions, and user experience guidelines for the Moodle Docker development environment. These guidelines ensure consistency, maintainability, and developer satisfaction.

## Design Principles

### 1. Simplicity First
**Principle**: Choose simplicity over complexity at every decision point.

**Application**:
- 2-service architecture instead of microservices complexity
- Single docker-compose.yml file for core services
- Minimal configuration with sensible defaults
- Optional services are configured but not mandatory

**Example**: Instead of a complex multi-service setup with Redis, MailHog, and monitoring by default, we provide a minimal Moodle + PostgreSQL setup with optional expansion.

### 2. Developer Experience Priority
**Principle**: Optimize for developer productivity and satisfaction.

**Application**:
- Zero port conflicts through custom port mapping
- Instant code reflection without container rebuilds
- Clear, actionable error messages
- Comprehensive documentation with examples

**Example**: Using ports 18080, 15432 instead of default 80, 5432 prevents conflicts with local services.

### 3. Production Pattern Preparation
**Principle**: Development environment should reflect production patterns without production complexity.

**Application**:
- Health checks for service reliability
- Environment-based configuration
- Separation of code, data, and configuration
- Scalability patterns without current complexity

**Example**: PostgreSQL health checks and proper volume management prepare for production patterns.

### 4. Convention Over Configuration
**Principle**: Provide sensible defaults that work out-of-the-box.

**Application**:
- Pre-configured environment variables
- Standard Docker networking
- Conventional file structure
- Automated initialization

**Example**: `.env.example` provides working defaults that developers can customize as needed.

## Architecture Design Guidelines

### Container Design

#### Single Responsibility Principle
Each container should have one clear purpose:

```yaml
# Good: Clear responsibilities
moodle:           # Web application and PHP processing
  purpose: "Moodle application server"

postgres:         # Database persistence
  purpose: "Database service"

# Avoid: Multiple responsibilities in one container
```

#### Resource Efficiency
Design for optimal resource usage:

```dockerfile
# Prefer Alpine variants for smaller images
FROM postgres:15-alpine    # ~230MB vs ~370MB for full

# Multi-stage builds when needed
FROM php:8.2-apache as base
# ... build steps
FROM base as production
# ... production-only steps
```

#### Health Check Patterns
Implement meaningful health checks:

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-moodle}"]
  interval: 10s
  timeout: 5s
  retries: 5
  start_period: 30s
```

### Network Design

#### Service Discovery
Use Docker's built-in service discovery:

```yaml
# Good: Use service names
environment:
  - DB_HOST=postgres    # References service name

# Avoid: Hard-coded IPs
environment:
  - DB_HOST=172.18.0.2  # Fragile, changes between runs
```

#### Port Strategy
Follow consistent port assignment:

```yaml
# Pattern: 1XXXX for service ports
ports:
  - "18080:80"     # Moodle web (18xxx range)
  - "15432:5432"   # PostgreSQL (15xxx range)
  - "16379:6379"   # Redis (16xxx range - planned)
  - "11025:1025"   # MailHog SMTP (11xxx range - planned)
  - "18025:8025"   # MailHog UI (18xxx range - planned)
```

### Data Management Design

#### Volume Strategy
Clear separation of data types:

```yaml
volumes:
  # Named volumes for system data
  pgdata:                    # Database persistence

  # Bind mounts for development
  ./moodle:/var/www/html     # Source code (editable)
  ./moodledata:/var/www/moodledata  # User data (persistent)
```

#### Configuration Management
Environment-driven configuration:

```bash
# .env file hierarchy
DB_NAME=moodle              # Database configuration
ADMIN_USER=admin            # Application configuration
SITE_NAME=Moodle Development # Site configuration
```

## User Experience Guidelines

### Installation Experience

#### Zero-Friction Setup
New users should be productive immediately:

1. **One Command Start**: `./start.sh` handles everything
2. **Automatic Dependencies**: No manual service setup
3. **Clear Progress**: Real-time feedback during setup
4. **Error Recovery**: Clear instructions for common issues

#### Progressive Disclosure
Information should be revealed as needed:

```bash
# Basic usage shown first
./start.sh

# Advanced options documented but not required
docker-compose up -d --build
```

### Development Workflow

#### Immediate Feedback
Changes should be visible instantly:

- Code changes reflect without restart
- Log output is easily accessible
- Container status is clear
- Error messages are actionable

#### Predictable Behavior
Operations should be consistent:

```bash
# Standard start/stop commands
./start.sh    # Always starts all services
./stop.sh     # Always stops cleanly

# Standard access patterns
http://localhost:18080     # Always the web interface
localhost:15432           # Always the database
```

### Error Handling Design

#### Error Prevention
Design to prevent common errors:

```bash
# Automatic environment setup
if [ ! -f .env ]; then
    echo "Creating .env from .env.example..."
    cp .env.example .env
fi
```

#### Error Recovery
Provide clear recovery paths:

```bash
# Reset instructions in troubleshooting
./stop.sh
docker-compose down -v
rm -rf moodle moodledata config
docker-compose up -d
```

#### Error Communication
Error messages should be:
- **Specific**: What exactly went wrong
- **Actionable**: What the user should do
- **Contextual**: Why it matters

## Script Design Guidelines

### Bash Script Standards

#### Error Handling
All scripts should handle errors gracefully:

```bash
#!/bin/bash
set -e  # Exit on error

# Function to handle cleanup
cleanup() {
    echo "Cleaning up..."
    # Cleanup code here
}
trap cleanup EXIT
```

#### User Communication
Scripts should communicate clearly:

```bash
echo "Starting Moodle Docker environment..."
echo "Building and starting containers..."
echo "=========================================="
echo "Moodle Docker environment started!"
```

#### Idempotency
Scripts should be safe to run multiple times:

```bash
# Check if already exists
if [ ! -f .env ]; then
    cp .env.example .env
fi

# Safe port cleanup
kill_port() {
    local port=$1
    local pid=$(lsof -ti:$port 2>/dev/null)
    if [ ! -z "$pid" ]; then
        kill -9 $pid 2>/dev/null
    fi
}
```

## Documentation Design

### Structure Guidelines

#### Hierarchy
Information should be organized by user journey:

1. **README.md**: Quick start for new users
2. **docs/**: Deep technical documentation
3. **Examples**: Real-world usage patterns
4. **Troubleshooting**: Common issues and solutions

#### Content Guidelines
Documentation should be:

- **Task-oriented**: Focus on what users want to accomplish
- **Example-rich**: Show real commands and outputs
- **Up-to-date**: Reflect current implementation
- **Searchable**: Use clear headings and keywords

### Code Examples
All examples should be:

```bash
# ✅ Copy-pasteable
./start.sh

# ✅ Include expected output
Container status:
NAME        IMAGE     STATUS    PORTS
moodle-app  ...       Up        0.0.0.0:18080->80/tcp

# ✅ Show context
cd moodle-docker  # Navigate to project directory
./start.sh         # Start all services
```

## Configuration Design

### Environment Variables

#### Naming Convention
Follow consistent naming patterns:

```bash
# Group by function with prefixes
DB_NAME=moodle           # Database configuration
DB_USER=moodle
DB_PASSWORD=password

ADMIN_USER=admin         # Application configuration
ADMIN_PASSWORD=password
ADMIN_EMAIL=admin@example.com

SITE_NAME=Moodle Dev     # Site configuration
SITE_SHORTNAME=MoodleDev
```

#### Default Values
Provide working defaults:

```yaml
environment:
  - DB_HOST=postgres
  - DB_NAME=${DB_NAME:-moodle}          # Default if not set
  - DB_USER=${DB_USER:-moodle}
  - DB_PASS=${DB_PASSWORD:-moodle_pass_2024}
```

### Docker Compose Design

#### Service Definition
Keep service definitions clean and minimal:

```yaml
services:
  moodle:
    build:
      context: .
      dockerfile: Dockerfile.simple    # Minimal build
    container_name: moodle-app         # Predictable name
    ports:
      - "18080:80"                     # Non-conflicting port
    environment:
      - DB_HOST=postgres               # Service reference
    volumes:
      - ./moodle:/var/www/html         # Development volume
    depends_on:
      postgres:
        condition: service_healthy     # Proper dependency
```

## Security Design Guidelines

### Development Security
Balance security with development productivity:

```bash
# ✅ Development convenience
ADMIN_PASSWORD=Admin@2024!    # Default but documented as dev-only

# ✅ Production warning
# WARNING: Change all passwords before production use
```

### Secret Management
Prepare for production patterns:

```bash
# Development: Simple .env file
DB_PASSWORD=moodle_pass_2024

# Production pattern: External secret management
DB_PASSWORD=${DB_PASSWORD}  # From environment or secret store
```

## Performance Design Guidelines

### Resource Optimization

#### Image Size
Optimize container images:

```dockerfile
# ✅ Alpine variants where possible
FROM postgres:15-alpine

# ✅ Multi-stage builds for complex images
FROM php:8.2-apache as builder
# ... build steps
FROM php:8.2-apache as runtime
COPY --from=builder /app /app
```

#### Startup Time
Minimize service startup time:

```bash
# ✅ Shallow clones for faster setup
git clone --depth 1 --branch MOODLE_501_STABLE

# ✅ Parallel operations where possible
docker-compose up -d  # Start services in parallel
```

### Monitoring Preparation
Design for observability:

```yaml
# Health checks for monitoring
healthcheck:
  test: ["CMD-SHELL", "curl -f http://localhost/admin/tool/health/ || exit 1"]

# Resource limits for production planning
deploy:
  resources:
    limits:
      memory: 1G
      cpus: '1'
```

## Future Design Considerations

### Extensibility
Design for future expansion:

```yaml
# Current: Minimal services
services:
  moodle: {...}
  postgres: {...}

# Future: Optional services (prepared but not active)
  redis: {...}     # Cache service
  mailhog: {...}   # Email testing
```

### Modularity
Support different deployment patterns:

```yaml
# Development: docker-compose.yml
services: [moodle, postgres]

# Production: docker-compose.prod.yml (future)
services: [moodle, postgres, redis, monitoring]
```

## Conclusion

These design guidelines ensure that the Moodle Docker environment remains simple, productive, and scalable. Every design decision should support the core principles of simplicity, developer experience, and production preparation while maintaining flexibility for future enhancement.

The key is to start simple and add complexity only when it provides clear value to users, always maintaining the balance between functionality and usability.