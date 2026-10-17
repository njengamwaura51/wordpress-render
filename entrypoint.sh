#!/bin/bash
set -e

mkdir -p /var/www/html/wp-content/plugins
mkdir -p /var/www/html/wp-content/themes
mkdir -p /var/www/html/wp-content/mu-plugins
mkdir -p /var/www/html/wp-content/uploads

# 1. Copy mu-plugins (passwordless login & license activator)
cp -rn /usr/src/wp-content-seed/mu-plugins/* /var/www/html/wp-content/mu-plugins/ 2>/dev/null || true

# 2. Download and unpack base free dependencies if not present
if [ ! -d /var/www/html/wp-content/themes/neve ]; then
    echo "Downloading base Neve theme..."
    curl -sL https://downloads.wordpress.org/theme/neve.4.2.16.zip -o /tmp/neve.zip
    unzip -qo /tmp/neve.zip -d /var/www/html/wp-content/themes/
    rm -f /tmp/neve.zip
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

# 3. Unpack paid plugins and themes from zip files
echo "Extracting ThemeIsle paid products..."
for zip_file in /usr/src/paid-plugins/*.zip; do
    [ -e "$zip_file" ] || continue
    name=$(basename "$zip_file")
    if [[ "$name" =~ neve-fse ]]; then
        unzip -qo "$zip_file" -d /var/www/html/wp-content/themes/
    else
        unzip -qo "$zip_file" -d /var/www/html/wp-content/plugins/
    fi
done

chown -R www-data:www-data /var/www/html/wp-content

exec docker-entrypoint.sh "$@"
