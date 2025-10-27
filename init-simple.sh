#!/bin/bash

# Clone Moodle if not present
if [ ! -f "/var/www/html/version.php" ]; then
    echo "Cloning Moodle 501_STABLE..."
    git clone --depth 1 --branch MOODLE_501_STABLE https://github.com/moodle/moodle.git /tmp/moodle
    mv /tmp/moodle/* /var/www/html/
    mv /tmp/moodle/.* /var/www/html/ 2>/dev/null || true
    rm -rf /tmp/moodle
fi

# Fix permissions
chown -R www-data:www-data /var/www/html /var/www/moodledata

# Start Apache
apache2-foreground