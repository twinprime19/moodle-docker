# Project Overview & Product Development Requirements (PDR)

## Executive Summary

Moodle Docker is a streamlined Docker-based development environment for Moodle LMS (Learning Management System). It provides developers with a quick, conflict-free setup for Moodle development, testing, and deployment preparation.

## Project Purpose

### Vision
To provide a zero-friction Docker environment that enables developers to spin up Moodle instances in under 5 minutes with guaranteed port availability and production-ready architecture patterns.

### Mission
Simplify Moodle development by eliminating environment setup complexities while maintaining production-grade patterns and best practices.

## Target Users

### Primary Users
- **Moodle Core Developers**: Contributing to Moodle core functionality
- **Plugin Developers**: Creating custom Moodle plugins and themes
- **Educational Institutions**: Testing Moodle configurations and customizations
- **DevOps Engineers**: Preparing Moodle for production deployment

### Secondary Users
- **QA Engineers**: Testing Moodle features and integrations
- **Educational Technology Teams**: Evaluating Moodle capabilities
- **System Administrators**: Learning Moodle administration

## Key Features

### Core Capabilities
1. **Rapid Setup** (<5 minutes)
   - Automated Moodle 501_STABLE source cloning
   - Pre-configured PostgreSQL 15 database with health checks
   - Streamlined initialization with simple/full options

2. **Non-Conflicting Ports**
   - Custom port mapping (18080 for web, 15432 for database)
   - Avoids common development port conflicts (80, 3000, 5432)
   - Configurable via environment variables with sensible defaults

3. **Version Management**
   - Easy switching between Moodle versions (git-based)
   - Default MOODLE_501_STABLE with upgrade paths
   - Branch checkout support for development/testing

4. **Live Development**
   - Direct code editing in ./moodle/ directory
   - Bind mount volumes for instant code reflection
   - No container rebuild required for code changes
   - Apache mod_rewrite enabled for Moodle routing

5. **Data Persistence**
   - PostgreSQL data in named Docker volume (pgdata)
   - Moodledata directory bind-mounted to host
   - Consistent state across container restarts
   - Clean separation of code, data, and configuration

### Management Features
- **Start/Stop Scripts**: Automated lifecycle with `start.sh` and `stop.sh`
- **Port Cleanup**: Intelligent port management with conflict resolution
- **Database Access**: Direct PostgreSQL CLI access via `docker exec`
- **Cache Management**: Built-in Moodle cache purging via CLI
- **Log Monitoring**: Real-time container log viewing
- **Environment Management**: Template-based configuration with `.env.example`

## Requirements & Constraints

### Technical Requirements
- **System Requirements**
  - Docker & Docker Compose installed
  - 4GB+ RAM available
  - 10GB+ disk space
  - macOS/Linux/Windows with WSL2

- **Software Stack**
  - PHP 8.2 with required extensions
  - PostgreSQL 15 Alpine
  - Apache web server
  - Moodle 501_STABLE (default)

### Development Requirements
- Git for version control
- Basic Docker knowledge
- Understanding of Moodle architecture
- Familiarity with PHP development

### Operational Constraints
- Development-only security settings
- Single-node architecture
- No built-in SSL/TLS
- Manual backup requirements

## Success Metrics

### Performance Metrics
- **Setup Time**: <5 minutes from clone to running
- **Container Start Time**: <30 seconds
- **Database Init Time**: <30 seconds
- **Code Change Reflection**: Immediate

### Reliability Metrics
- **Container Stability**: 99% uptime during development
- **Data Persistence**: 100% across restarts
- **Version Switch Success**: 100% compatibility

### Developer Experience Metrics
- **Zero Port Conflicts**: Custom ports avoid conflicts
- **Command Simplicity**: Single command operations
- **Documentation Completeness**: All features documented
- **Error Recovery**: Clean reset capability

## Use Cases

### Primary Use Cases

1. **New Moodle Development**
   - Clone repository
   - Run docker-compose up
   - Start developing immediately

2. **Plugin Development**
   - Mount plugin directory
   - Test against multiple Moodle versions
   - Debug with full stack access

3. **Version Testing**
   - Switch between Moodle branches
   - Test upgrade paths
   - Validate compatibility

4. **Team Development**
   - Consistent environment across team
   - Shared configuration via .env
   - Reproducible issues

### Extended Use Cases

1. **CI/CD Pipeline Testing**
   - Local validation before deployment
   - Integration test environment
   - Performance baseline testing

2. **Training & Education**
   - Moodle administration training
   - Developer onboarding
   - Workshop environments

3. **Proof of Concept**
   - Quick feature demonstrations
   - Client presentations
   - Architecture validation

## Project Scope

### In Scope
- Docker-based Moodle development environment
- PostgreSQL database integration
- Basic Redis cache support (planned)
- Development workflow optimization
- Version management capabilities
- Basic monitoring and logging

### Out of Scope
- Production deployment features
- Multi-node clustering
- Advanced monitoring/alerting
- Automated backups
- SSL/TLS configuration
- Load balancing

## Roadmap

### Phase 1: Foundation (Completed)
- ✅ Basic Docker setup
- ✅ PostgreSQL integration
- ✅ Automated Moodle installation
- ✅ Port conflict resolution
- ✅ Management scripts

### Phase 2: Enhancement (Current - October 2025)
- ✅ Documentation completion (comprehensive docs structure with PDR, architecture, code standards)
- ⏳ Redis cache integration (prepared in configs, not yet active in compose)
- ⏳ MailHog email testing (SMTP configured in init.sh, containers not in compose)
- ✅ Development tools integration (Claude AI workflows, MCP server, repomix analysis)
- ✅ Streamlined 2-service architecture (simplified from complex multi-service setup)

### Phase 3: Production Prep (Planned)
- Security hardening
- Performance optimization
- Monitoring integration
- Backup automation
- SSL/TLS support

### Phase 4: Scale (Future)
- Container orchestration
- Load balancing
- High availability
- Cloud deployment templates
- CI/CD integration

## Risk Assessment

### Technical Risks
- **Docker Version Compatibility**: Mitigated by version requirements
- **Moodle Breaking Changes**: Addressed by version pinning
- **Performance Issues**: Solved by resource recommendations

### Operational Risks
- **Data Loss**: Mitigated by volume persistence
- **Port Conflicts**: Resolved by custom port mapping
- **Environment Drift**: Prevented by Docker containerization

## Compliance & Standards

### Development Standards
- Docker best practices
- PHP PSR standards
- Moodle coding guidelines
- Git workflow conventions

### Security Considerations
- Development-only credentials
- Local-only port binding
- No production secrets in repository
- Clear security warnings in documentation

## Success Criteria

The project is considered successful when:
1. Developers can start Moodle development in <5 minutes
2. Zero reported port conflicts in development
3. All Moodle versions work with the setup
4. Documentation covers all use cases
5. Community adoption and contribution

## Conclusion

Moodle Docker provides a robust, developer-friendly environment that significantly reduces the time and complexity of Moodle development setup. By focusing on developer experience while maintaining production-ready patterns, it serves as both a development tool and a learning platform for production deployment strategies.