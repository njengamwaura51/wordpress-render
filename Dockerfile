FROM wordpress:latest

# Install unzip and mariadb client
RUN apt-get update && apt-get install -y unzip default-mysql-client curl && rm -rf /var/lib/apt/lists/*

# Custom PHP settings
COPY config/uploads.ini /usr/local/etc/php/conf.d/uploads.ini

# Paid product zips, mu-plugins, and db drop-in
COPY paid-plugins/ /usr/src/paid-plugins/
COPY mu-plugins/ /usr/src/wp-content-seed/mu-plugins/
COPY db.php /usr/src/wp-content-seed/db.php

# Custom entrypoint
COPY entrypoint.sh /usr/local/bin/custom-entrypoint.sh
RUN chmod +x /usr/local/bin/custom-entrypoint.sh && \
    chmod -R 777 /etc/apache2 /var/log/apache2 /var/run/apache2 2>/dev/null || true

ENTRYPOINT ["/usr/local/bin/custom-entrypoint.sh"]
CMD ["apache2-foreground"]
