FROM wordpress:latest

# Install unzip, mariadb client, curl, less, and WP-CLI
RUN apt-get update && apt-get install -y unzip default-mysql-client curl less && rm -rf /var/lib/apt/lists/* && \
    curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Custom PHP settings (uploads, memory, execution time, opcache)
COPY config/uploads.ini /usr/local/etc/php/conf.d/uploads.ini

# Pre-download and install base themes and plugins directly into image
RUN mkdir -p /usr/src/wordpress/wp-content/themes /usr/src/wordpress/wp-content/plugins /usr/src/wordpress/wp-content/mu-plugins && \
    curl -sL https://downloads.wordpress.org/theme/neve.4.2.16.zip -o /tmp/neve.zip && unzip -qo /tmp/neve.zip -d /usr/src/wordpress/wp-content/themes/ && rm -f /tmp/neve.zip && \
    curl -sL https://downloads.wordpress.org/theme/neve-fse.1.1.7.zip -o /tmp/neve-fse.zip && unzip -qo /tmp/neve-fse.zip -d /usr/src/wordpress/wp-content/themes/ && rm -f /tmp/neve-fse.zip && \
    curl -sL https://downloads.wordpress.org/plugin/otter-blocks.3.2.7.zip -o /tmp/otter.zip && unzip -qo /tmp/otter.zip -d /usr/src/wordpress/wp-content/plugins/ && rm -f /tmp/otter.zip && \
    curl -sL https://downloads.wordpress.org/plugin/woocommerce.11.2.1.zip -o /tmp/wc.zip && unzip -qo /tmp/wc.zip -d /usr/src/wordpress/wp-content/plugins/ && rm -f /tmp/wc.zip && \
    curl -sL https://downloads.wordpress.org/plugin/templates-patterns-collection.1.4.6.zip -o /tmp/tpc.zip && unzip -qo /tmp/tpc.zip -d /usr/src/wordpress/wp-content/plugins/ && rm -f /tmp/tpc.zip

# Paid product zips, pre-extracted into plugins directory
COPY paid-plugins/ /usr/src/paid-plugins/
RUN for zip in /usr/src/paid-plugins/*.zip; do [ -e "$zip" ] && unzip -qo "$zip" -d /usr/src/wordpress/wp-content/plugins/; done

COPY mu-plugins/ /usr/src/wordpress/wp-content/mu-plugins/
COPY db.php /usr/src/wp-content-seed/db.php

# Custom entrypoint
COPY entrypoint.sh /usr/local/bin/custom-entrypoint.sh
RUN chmod +x /usr/local/bin/custom-entrypoint.sh && \
    chmod -R 777 /etc/apache2 /var/log/apache2 /var/run/apache2 2>/dev/null || true

WORKDIR /var/www/html

ENTRYPOINT ["/usr/local/bin/custom-entrypoint.sh"]
CMD ["apache2-foreground"]
