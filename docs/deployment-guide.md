# Deployment Guide

## Overview

This guide covers deployment strategies for the Moodle Docker environment, from local development to production-ready configurations. Current focus is on the simplified 2-service architecture (Moodle + PostgreSQL) with optional service expansion.

## Development Deployment

### Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- 4GB+ RAM available
- 10GB+ free disk space
- Git for version control

### Quick Start Deployment

1. **Clone and Setup**
   ```bash
   git clone <repository-url> moodle-docker
   cd moodle-docker
   cp .env.example .env
   ```

2. **Configure Environment**
   ```bash
   # Edit .env file with your preferences
   nano .env
   ```

3. **Deploy Services**
   ```bash
   # Using convenience script
   ./start.sh

   # Or manually
   docker-compose up -d --build
   ```

4. **Verify Deployment**
   ```bash
   # Check container status
   docker-compose ps

   # Follow initialization logs
   docker logs -f moodle-app
   ```

5. **Access Application**
   - URL: http://localhost:18080
   - Database: localhost:15432
   - Complete Moodle installation wizard

### Environment Configuration

#### Database Settings (.env)
```bash
DB_NAME=moodle
DB_USER=moodle
DB_PASSWORD=moodle_pass_2024
```

#### Admin Settings (.env)
```bash
ADMIN_USER=admin
ADMIN_PASSWORD=Admin@2024!
ADMIN_EMAIL=admin@example.com
```

#### Site Settings (.env)
```bash
SITE_NAME=Moodle Development
SITE_SHORTNAME=MoodleDev
```

## Development Workflow

### Daily Operations

```bash
# Start development environment
./start.sh

# Stop environment (preserves data)
./stop.sh

# View logs
docker-compose logs -f moodle

# Access database
docker exec -it moodle-db psql -U moodle

# Clear Moodle cache
docker exec -it moodle-app php admin/cli/purge_caches.php
```

### Code Development

1. **Edit Source Code**
   - Moodle source: `./moodle/`
   - Changes reflect immediately
   - No container rebuild needed

2. **Version Management**
   ```bash
   cd moodle
   git fetch
   git checkout MOODLE_502_STABLE
   docker-compose restart moodle
   ```

3. **Database Operations**
   ```bash
   # Backup database
   docker exec moodle-db pg_dump -U moodle moodle > backup.sql

   # Restore database
   docker exec -i moodle-db psql -U moodle moodle < backup.sql
   ```

### Testing Deployment

```bash
# Run PHPUnit tests
docker exec moodle-app php admin/tool/phpunit/cli/init.php
docker exec moodle-app vendor/bin/phpunit

# Run Behat tests
docker exec moodle-app php admin/tool/behat/cli/init.php
docker exec moodle-app vendor/bin/behat
```

## Staging Deployment

### Environment Preparation

1. **Server Requirements**
   - 8GB+ RAM
   - 50GB+ storage
   - Docker Swarm or Kubernetes
   - Load balancer (Nginx/Traefik)

2. **Security Hardening**
   ```bash
   # Change default passwords
   openssl rand -base64 32  # Generate secure password

   # Configure firewall
   ufw allow 22/tcp
   ufw allow 80/tcp
   ufw allow 443/tcp
   ufw enable
   ```

3. **SSL/TLS Setup**
   ```bash
   # Using Let's Encrypt
   certbot --nginx -d your-domain.com
   ```

### Docker Swarm Deployment

1. **Initialize Swarm**
   ```bash
   docker swarm init
   ```

2. **Deploy Stack**
   ```yaml
   # docker-stack.yml
   version: '3.8'
   services:
     moodle:
       image: moodle-custom:latest
       ports:
         - "80:80"
       environment:
         - DB_HOST=postgres
       deploy:
         replicas: 2
         restart_policy:
           condition: on-failure
       networks:
         - moodle-network

     postgres:
       image: postgres:15-alpine
       environment:
         - POSTGRES_PASSWORD_FILE=/run/secrets/db_password
       secrets:
         - db_password
       volumes:
         - pgdata:/var/lib/postgresql/data
       deploy:
         placement:
           constraints: [node.role == manager]
       networks:
         - moodle-network

   secrets:
     db_password:
       external: true

   volumes:
     pgdata:

   networks:
     moodle-network:
       driver: overlay
   ```

3. **Deploy**
   ```bash
   echo "secure_password" | docker secret create db_password -
   docker stack deploy -c docker-stack.yml moodle
   ```

## Production Deployment

### Infrastructure Requirements

- **Compute**: 4+ CPU cores, 16GB+ RAM per node
- **Storage**: SSD with 200GB+ capacity
- **Network**: Load balancer with SSL termination
- **Monitoring**: Prometheus + Grafana
- **Logging**: ELK Stack or similar
- **Backup**: Automated database and file backups

### Kubernetes Deployment

1. **Namespace Setup**
   ```yaml
   # namespace.yml
   apiVersion: v1
   kind: Namespace
   metadata:
     name: moodle-prod
   ```

2. **ConfigMap and Secrets**
   ```yaml
   # configmap.yml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: moodle-config
     namespace: moodle-prod
   data:
     DB_HOST: "postgres-service"
     DB_NAME: "moodle"
     DB_USER: "moodle"

   ---
   apiVersion: v1
   kind: Secret
   metadata:
     name: moodle-secrets
     namespace: moodle-prod
   type: Opaque
   data:
     DB_PASSWORD: <base64-encoded-password>
     ADMIN_PASSWORD: <base64-encoded-password>
   ```

3. **Persistent Volumes**
   ```yaml
   # pv.yml
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: moodle-data
     namespace: moodle-prod
   spec:
     accessModes:
       - ReadWriteMany
     resources:
       requests:
         storage: 100Gi
     storageClassName: nfs-client

   ---
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: postgres-data
     namespace: moodle-prod
   spec:
     accessModes:
       - ReadWriteOnce
     resources:
       requests:
         storage: 50Gi
     storageClassName: ssd
   ```

4. **Deployments**
   ```yaml
   # moodle-deployment.yml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: moodle
     namespace: moodle-prod
   spec:
     replicas: 3
     selector:
       matchLabels:
         app: moodle
     template:
       metadata:
         labels:
           app: moodle
       spec:
         containers:
         - name: moodle
           image: moodle-custom:v1.0.0
           ports:
           - containerPort: 80
           env:
           - name: DB_HOST
             valueFrom:
               configMapKeyRef:
                 name: moodle-config
                 key: DB_HOST
           - name: DB_PASSWORD
             valueFrom:
               secretKeyRef:
                 name: moodle-secrets
                 key: DB_PASSWORD
           volumeMounts:
           - name: moodle-data
             mountPath: /var/www/moodledata
           resources:
             requests:
               memory: "1Gi"
               cpu: "500m"
             limits:
               memory: "2Gi"
               cpu: "1000m"
         volumes:
         - name: moodle-data
           persistentVolumeClaim:
             claimName: moodle-data
   ```

5. **Services and Ingress**
   ```yaml
   # service.yml
   apiVersion: v1
   kind: Service
   metadata:
     name: moodle-service
     namespace: moodle-prod
   spec:
     selector:
       app: moodle
     ports:
     - port: 80
       targetPort: 80
     type: ClusterIP

   ---
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: moodle-ingress
     namespace: moodle-prod
     annotations:
       kubernetes.io/ingress.class: nginx
       cert-manager.io/cluster-issuer: letsencrypt-prod
   spec:
     tls:
     - hosts:
       - moodle.yourdomain.com
       secretName: moodle-tls
     rules:
     - host: moodle.yourdomain.com
       http:
         paths:
         - path: /
           pathType: Prefix
           backend:
             service:
               name: moodle-service
               port:
                 number: 80
   ```

### Production Checklist

#### Security
- [ ] Change all default passwords
- [ ] Enable SSL/TLS certificates
- [ ] Configure firewall rules
- [ ] Set up VPN access
- [ ] Enable security headers
- [ ] Configure rate limiting
- [ ] Implement WAF protection

#### Performance
- [ ] Configure CDN
- [ ] Enable Redis caching
- [ ] Optimize database
- [ ] Set up monitoring
- [ ] Configure auto-scaling
- [ ] Implement health checks

#### Reliability
- [ ] Set up automated backups
- [ ] Configure log aggregation
- [ ] Implement alerting
- [ ] Test disaster recovery
- [ ] Document runbooks
- [ ] Set up monitoring dashboards

#### Compliance
- [ ] Data encryption at rest
- [ ] Data encryption in transit
- [ ] Access control implementation
- [ ] Audit logging enabled
- [ ] Compliance scanning
- [ ] Security documentation

## Troubleshooting

### Common Deployment Issues

1. **Port Conflicts**
   ```bash
   # Check port usage
   lsof -i :18080

   # Kill conflicting process
   kill -9 <PID>

   # Or change ports in docker-compose.yml
   ```

2. **Database Connection Issues**
   ```bash
   # Check database status
   docker-compose ps postgres

   # Verify database connectivity
   docker exec moodle-db pg_isready -U moodle

   # Check logs
   docker-compose logs postgres
   ```

3. **Memory Issues**
   ```bash
   # Check Docker resource limits
   docker stats

   # Increase memory in Docker settings
   # Or add resource limits to compose file
   ```

4. **Permission Issues**
   ```bash
   # Fix file permissions
   docker exec moodle-app chown -R www-data:www-data /var/www/html
   docker exec moodle-app chmod -R 755 /var/www/html
   ```

### Recovery Procedures

#### Complete Environment Reset
```bash
./stop.sh
docker-compose down -v
rm -rf moodle moodledata config
docker-compose up -d --build
```

#### Data Recovery
```bash
# Restore from backup
docker exec -i moodle-db psql -U moodle moodle < backup.sql
docker cp backup-moodledata/ moodle-app:/var/www/moodledata/
```

## Monitoring and Maintenance

### Health Checks

```bash
# Application health
curl -f http://localhost:18080/

# Database health
docker exec moodle-db pg_isready -U moodle

# Container health
docker-compose ps
```

### Log Management

```bash
# View application logs
docker-compose logs -f moodle

# View database logs
docker-compose logs -f postgres

# Export logs
docker-compose logs --since 24h > moodle-logs.txt
```

### Backup Strategy

```bash
# Automated backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)

# Database backup
docker exec moodle-db pg_dump -U moodle moodle > db_backup_$DATE.sql

# File backup
tar -czf moodledata_backup_$DATE.tar.gz ./moodledata/

# Cleanup old backups (keep 7 days)
find . -name "*backup*" -mtime +7 -delete
```

### Updates and Maintenance

```bash
# Update base images
docker-compose pull
docker-compose up -d --build

# Update Moodle version
cd moodle
git fetch
git checkout MOODLE_403_STABLE
docker-compose restart moodle

# Apply security updates
docker exec moodle-app apt-get update && apt-get upgrade -y
```

## Performance Optimization

### Database Optimization

```sql
-- PostgreSQL tuning
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
ALTER SYSTEM SET maintenance_work_mem = '64MB';
SELECT pg_reload_conf();
```

### Application Optimization

```php
// Moodle config.php optimizations
$CFG->cachejs = true;
$CFG->cachecss = true;
$CFG->yuicomboloading = true;
$CFG->enablecompletion = true;
```

### Infrastructure Optimization

```yaml
# docker-compose.yml resource limits
services:
  moodle:
    mem_limit: 2g
    cpus: '1.5'
  postgres:
    mem_limit: 1g
    cpus: '1.0'
```

## Conclusion

This deployment guide provides comprehensive coverage from development to production environments. Always test deployments in staging before production, and maintain regular backups and monitoring to ensure system reliability.

For specific deployment scenarios or advanced configurations, consult the individual component documentation and consider engaging with DevOps specialists for production deployments.