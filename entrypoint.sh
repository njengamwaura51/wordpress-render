#!/bin/bash
set -e

mkdir -p /var/www/html/wp-content/plugins
mkdir -p /var/www/html/wp-content/themes
mkdir -p /var/www/html/wp-content/mu-plugins
mkdir -p /var/www/html/wp-content/uploads

# 1. Copy mu-plugins and db drop-in (passwordless login & TiDB collation fix)
cp -rn /usr/src/wp-content-seed/mu-plugins/* /var/www/html/wp-content/mu-plugins/ 2>/dev/null || true
cp -f /usr/src/wp-content-seed/db.php /var/www/html/wp-content/db.php 2>/dev/null || true

# 2. Download and unpack base themes and plugins if not present
if [ ! -d /var/www/html/wp-content/themes/neve ]; then
    echo "Downloading base Neve theme..."
    curl -sL https://downloads.wordpress.org/theme/neve.4.2.16.zip -o /tmp/neve.zip
    unzip -qo /tmp/neve.zip -d /var/www/html/wp-content/themes/
    rm -f /tmp/neve.zip
fi

if [ ! -d /var/www/html/wp-content/themes/neve-fse ]; then
    echo "Downloading Neve FSE theme..."
    curl -sL https://downloads.wordpress.org/theme/neve-fse.1.1.7.zip -o /tmp/neve-fse.zip
    unzip -qo /tmp/neve-fse.zip -d /var/www/html/wp-content/themes/
    rm -f /tmp/neve-fse.zip
fi

if [ ! -d /var/www/html/wp-content/plugins/otter-blocks ]; then
    echo "Downloading base Otter Blocks..."
    curl -sL https://downloads.wordpress.org/plugin/otter-blocks.3.2.7.zip -o /tmp/otter-blocks.zip
    unzip -qo /tmp/otter-blocks.zip -d /var/www/html/wp-content/plugins/
    rm -f /tmp/otter-blocks.zip
fi

if [ ! -d /var/www/html/wp-content/plugins/woocommerce ]; then
    echo "Downloading base WooCommerce..."
    curl -sL https://downloads.wordpress.org/plugin/woocommerce.11.2.1.zip -o /tmp/woocommerce.zip
    unzip -qo /tmp/woocommerce.zip -d /var/www/html/wp-content/plugins/
    rm -f /tmp/woocommerce.zip
fi

if [ ! -d /var/www/html/wp-content/plugins/templates-patterns-collection ]; then
    echo "Downloading Starter Sites & Templates library..."
    curl -sL https://downloads.wordpress.org/plugin/templates-patterns-collection.1.4.6.zip -o /tmp/tpc.zip
    unzip -qo /tmp/tpc.zip -d /var/www/html/wp-content/plugins/
    rm -f /tmp/tpc.zip
fi

# 3. Unpack paid plugins
echo "Extracting ThemeIsle paid plugins..."
for zip_file in /usr/src/paid-plugins/*.zip; do
    [ -e "$zip_file" ] || continue
    unzip -qo "$zip_file" -d /var/www/html/wp-content/plugins/
done

# 4. Configure dynamic PORT for Heroku
if [ -n "$PORT" ]; then
    echo "Configuring Apache to listen on port $PORT for Heroku..."
    sed -i "s/80/$PORT/g" /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf
fi

# 5. Handle Heroku database URLs (JawsDB / ClearDB / default DATABASE_URL)
if [ -n "$JAWSDB_URL" ]; then
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

chown -R www-data:www-data /var/www/html/wp-content

exec docker-entrypoint.sh "$@"
