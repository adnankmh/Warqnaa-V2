FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json ./
RUN composer install --no-dev --no-interaction --no-progress --prefer-dist --optimize-autoloader --no-scripts

FROM php:8.3-fpm-alpine
COPY --from=ghcr.io/php/pie:1.5.0-bin /pie /usr/local/bin/pie
RUN apk add --no-cache bash curl icu-dev libzip-dev postgresql-dev oniguruma-dev unzip $PHPIZE_DEPS \
    && docker-php-ext-install pdo_pgsql pdo_mysql intl mbstring bcmath pcntl opcache zip \
    && pie install --no-cache phpredis/phpredis:6.3.0 \
    && php -m | grep -qx redis \
    && rm -f /usr/local/bin/pie \
    && apk del unzip $PHPIZE_DEPS
WORKDIR /var/www/html
COPY --from=vendor /app/vendor ./vendor
COPY . .
COPY docker/php/entrypoint.sh /usr/local/bin/warqna-entrypoint
RUN chmod +x /usr/local/bin/warqna-entrypoint \
    && chown -R www-data:www-data storage bootstrap/cache
USER www-data
EXPOSE 9000
ENTRYPOINT ["warqna-entrypoint"]
CMD ["php-fpm"]
