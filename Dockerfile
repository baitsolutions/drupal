# Basis-Image
FROM drupal:php8.3-apache-bookworm

# Set working directory
WORKDIR /var/www

# Copy composer.json and composer.lock
COPY composer.json composer.lock ./

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/* \
    && composer install

# Copy settings
ARG ENVIRONMENT
COPY settings/settings.php /var/www/web/sites/default/settings.php
COPY settings/settings.${ENVIRONMENT}.php /var/www/web/sites/default/settings.${ENVIRONMENT}.php

# Copy web directory
COPY web /var/www/web

# Copy environment file
COPY .env /var/www/.env

# Set appropriate permissions
RUN chown -R www-data:www-data /var/www/web \
    && chmod -R 755 /var/www/web

# Expose port 8080
EXPOSE 8080

# Define a volume for persistent storage
VOLUME /var/www/web/sites/default/files

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost/ || exit 1
# Entrypoint command
CMD ["apache2-foreground"]