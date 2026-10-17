FROM wordpress:latest

# Install unzip and mariadb client
RUN apt-get update && apt-get install -y unzip default-mysql-client curl && rm -rf /var/lib/apt/lists/*

# Custom PHP settings
COPY config/uploads.ini /usr/local/etc/php/conf.d/uploads.ini

# Paid product zips and mu-plugins
COPY paid-plugins/ /usr/src/paid-plugins/
COPY mu-plugins/ /usr/src/wp-content-seed/mu-plugins/

# Custom entrypoint
COPY entrypoint.sh /usr/local/bin/custom-entrypoint.sh
RUN chmod +x /usr/local/bin/custom-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/custom-entrypoint.sh"]
CMD ["apache2-foreground"]
