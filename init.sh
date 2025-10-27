#!/bin/bash

# Clone Moodle if not already present
if [ ! -d "/var/www/html/admin" ]; then
    echo "Moodle source not found. Cloning MOODLE_501_STABLE..."
    cd /tmp
    git clone --depth 1 --branch MOODLE_501_STABLE https://github.com/moodle/moodle.git moodle_temp
    cp -r moodle_temp/* /var/www/html/
    cp -r moodle_temp/.* /var/www/html/ 2>/dev/null || true
    rm -rf moodle_temp
    echo "Moodle source cloned successfully."
else
    echo "Moodle source already present."
fi

# Set proper permissions
chown -R www-data:www-data /var/www/html
chown -R www-data:www-data /var/www/moodledata
chmod -R 755 /var/www/html
chmod -R 777 /var/www/moodledata

# Wait for database to be ready
echo "Waiting for database to be ready..."
until pg_isready -h "${MOODLE_DATABASE_HOST}" -p "${MOODLE_DATABASE_PORT}" -U "${MOODLE_DATABASE_USER}" 2>/dev/null; do
    echo "Database is unavailable - sleeping"
    sleep 2
done
echo "Database is ready!"

# Check if Moodle is already installed
if [ -f "/var/www/html/config.php" ] && [ -s "/var/www/html/config.php" ]; then
    echo "Moodle config exists. Checking if installation is complete..."

    # Check if database has tables
    TABLES=$(PGPASSWORD="${MOODLE_DATABASE_PASSWORD}" psql -h "${MOODLE_DATABASE_HOST}" -p "${MOODLE_DATABASE_PORT}" -U "${MOODLE_DATABASE_USER}" -d "${MOODLE_DATABASE_NAME}" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null || echo "0")

    if [ "$TABLES" -gt "10" ]; then
        echo "Moodle is already installed."
    else
        echo "Config exists but database is empty. Running installation..."
        cd /var/www/html
        php admin/cli/install_database.php \
            --agree-license \
            --adminuser="${MOODLE_ADMIN_USER}" \
            --adminpass="${MOODLE_ADMIN_PASSWORD}" \
            --adminemail="${MOODLE_ADMIN_EMAIL}" \
            --fullname="${MOODLE_SITE_NAME}" \
            --shortname="${MOODLE_SITE_SHORTNAME}"
    fi
else
    echo "Installing Moodle..."
    cd /var/www/html

    # Run Moodle CLI installation
    php admin/cli/install.php \
        --non-interactive \
        --agree-license \
        --wwwroot="${MOODLE_URL}" \
        --dataroot=/var/www/moodledata \
        --dbtype="${MOODLE_DATABASE_TYPE}" \
        --dbhost="${MOODLE_DATABASE_HOST}" \
        --dbname="${MOODLE_DATABASE_NAME}" \
        --dbuser="${MOODLE_DATABASE_USER}" \
        --dbpass="${MOODLE_DATABASE_PASSWORD}" \
        --dbport="${MOODLE_DATABASE_PORT}" \
        --adminuser="${MOODLE_ADMIN_USER}" \
        --adminpass="${MOODLE_ADMIN_PASSWORD}" \
        --adminemail="${MOODLE_ADMIN_EMAIL}" \
        --fullname="${MOODLE_SITE_NAME}" \
        --shortname="${MOODLE_SITE_SHORTNAME}"

    # Configure Redis session cache
    if [ ! -z "${REDIS_HOST}" ]; then
        echo "Configuring Redis cache..."
        php admin/cli/cfg.php --name=session_handler --set=redis
        php admin/cli/cfg.php --name=session_redis_host --set="${REDIS_HOST}"
        php admin/cli/cfg.php --name=session_redis_port --set="${REDIS_PORT}"
    fi

    # Set permissions again after installation
    chown -R www-data:www-data /var/www/html
    chown -R www-data:www-data /var/www/moodledata
fi

# Configure SMTP for MailHog
php admin/cli/cfg.php --name=smtphosts --set=mailhog:1025 2>/dev/null || true
php admin/cli/cfg.php --name=noreplyaddress --set=noreply@localhost 2>/dev/null || true

echo "Starting Apache..."
apache2-foreground