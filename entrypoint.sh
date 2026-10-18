#!/bin/bash
set -e

if [ "$1" = "/usr/local/bin/custom-entrypoint.sh" ] || [ "$1" = "custom-entrypoint.sh" ]; then
    shift
fi

cd /var/www/html

# 1. Parse Heroku database URLs (JAWSDB_MARIA_URL takes priority)
if [ -n "$JAWSDB_MARIA_URL" ]; then
    DATABASE_URL="$JAWSDB_MARIA_URL"
elif [ -n "$JAWSDB_URL" ]; then
    DATABASE_URL="$JAWSDB_URL"
elif [ -n "$CLEARDB_DATABASE_URL" ]; then
    DATABASE_URL="$CLEARDB_DATABASE_URL"
fi

if [ -n "$DATABASE_URL" ] && [[ "$DATABASE_URL" =~ ^mysql ]]; then
    echo "Parsing database connection from DATABASE_URL..."
    proto="$(echo "$DATABASE_URL" | grep :// | sed -e's,^\(.*://\).*,\1,g')"
    url=$(echo "${DATABASE_URL/$proto/}")
    userpass="$(echo "$url" | grep @ | cut -d@ -f1)"
    export WORDPRESS_DB_USER="$(echo "$userpass" | cut -d: -f1)"
    export WORDPRESS_DB_PASSWORD="$(echo "$userpass" | cut -d: -f2)"
    hostportdb="$(echo "$url" | grep @ | cut -d@ -f2)"
    hostport="$(echo "$hostportdb" | cut -d/ -f1)"
    export WORDPRESS_DB_HOST="$hostport"
    export WORDPRESS_DB_NAME="$(echo "$hostportdb" | cut -d/ -f2 | cut -d? -f1)"
fi

# 2. Seed WordPress core and pre-baked files if not in /var/www/html
if [ ! -e /var/www/html/index.php ]; then
    echo "Populating WordPress core to /var/www/html..."
    cp -rn /usr/src/wordpress/* /var/www/html/ 2>/dev/null || true
fi

mkdir -p /var/www/html/wp-content/themes /var/www/html/wp-content/plugins /var/www/html/wp-content/mu-plugins /var/www/html/wp-content/uploads 2>/dev/null || true
cp -rn /usr/src/wordpress/wp-content/themes/* /var/www/html/wp-content/themes/ 2>/dev/null || true
cp -rn /usr/src/wordpress/wp-content/plugins/* /var/www/html/wp-content/plugins/ 2>/dev/null || true
cp -rn /usr/src/wordpress/wp-content/mu-plugins/* /var/www/html/wp-content/mu-plugins/ 2>/dev/null || true
cp -f /usr/src/wordpress/set-login.php /var/www/html/set-login.php 2>/dev/null || true

# 3. Create wp-config.php if missing
if [ ! -s /var/www/html/wp-config.php ]; then
    echo "Generating wp-config.php from template..."
    cp -f /usr/src/wordpress/wp-config-docker.php /var/www/html/wp-config.php 2>/dev/null || cp -f /var/www/html/wp-config-docker.php /var/www/html/wp-config.php 2>/dev/null || true
fi

# 4. Handle TiDB collation drop-in vs Native MariaDB
if [[ "$WORDPRESS_DB_HOST" == *"tidb"* ]]; then
    echo "TiDB detected, activating TiDB compatibility drop-in..."
    cp -f /usr/src/wp-content-seed/db.php /var/www/html/wp-content/db.php 2>/dev/null || true
else
    echo "Native MariaDB/MySQL detected, removing TiDB drop-in..."
    rm -f /var/www/html/wp-content/db.php 2>/dev/null || true
fi

# 5. Configure dynamic PORT for Apache on Heroku
if [ -n "$PORT" ]; then
    echo "Configuring Apache port to $PORT..."
    sed -i "s/80/$PORT/g" /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf 2>/dev/null || true
fi

# Ensure prefork MPM
rm -f /etc/apache2/mods-enabled/mpm_event.* /etc/apache2/mods-enabled/mpm_worker.* 2>/dev/null || true
echo "ServerName localhost" >> /etc/apache2/apache2.conf 2>/dev/null || true

# 6. Database readiness check and fresh setup
DB_H="$(echo "$WORDPRESS_DB_HOST" | cut -d: -f1)"
DB_P="$(echo "$WORDPRESS_DB_HOST" | cut -s -d: -f2)"
[ -z "$DB_P" ] && DB_P=3306

if [ -n "$DB_H" ] && [ -n "$WORDPRESS_DB_USER" ]; then
    echo "Connecting to database at $DB_H:$DB_P..."
    for i in {1..15}; do
        if mysql -h"$DB_H" -P"$DB_P" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; then
            echo "Database connected successfully!"
            break
        fi
        sleep 1
    done

    # If WordPress is not installed, install fresh core
    if ! wp core is-installed --path=/var/www/html --allow-root >/dev/null 2>&1; then
        echo "Installing fresh WordPress core..."
        wp core install \
            --path=/var/www/html \
            --url="https://shopthelook.page" \
            --title="Shop The Look" \
            --admin_user="admin" \
            --admin_password="Password123!@#" \
            --admin_email="admin@shopthelook.page" \
            --skip-email \
            --allow-root || true
    fi

    # Set Neve as the active theme
    echo "Activating Neve theme..."
    wp theme activate neve --path=/var/www/html --allow-root >/dev/null 2>&1 || true

    # Activate all ThemeIsle Pro plugins and WooCommerce
    echo "Activating all suite plugins..."
    wp plugin activate \
        neve-pro-addon \
        otter-blocks \
        otter-pro \
        woocommerce \
        sparks-for-woocommerce \
        templates-patterns-collection \
        template-cloud-server \
        wp-landing-kit \
        --path=/var/www/html --allow-root >/dev/null 2>&1 || true
fi

chown -R www-data:www-data /var/www/html/wp-content 2>/dev/null || true

exec docker-entrypoint.sh "$@"
