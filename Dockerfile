FROM php:8.4.4-fpm-alpine3.21

RUN set -eux \
    && apk update \
    && apk upgrade \
    && apk add \
        ca-certificates \
        tzdata \
    && update-ca-certificates \
    && apk add --virtual .build-deps $PHPIZE_DEPS git zip unzip zlib-dev coreutils \
    && : "---------- GD ----------" \
    && apk add --no-cache --virtual .gd-build-dependencies freetype-dev libjpeg-turbo-dev libpng-dev vips-dev \
    && apk add vips \
    && docker-php-ext-configure gd --with-jpeg --with-freetype --with-webp \
    && docker-php-ext-install -j$(nproc) gd \
    && apk del .gd-build-dependencies \
    && : "---------- DS ----------" \
    && pecl install ds \
    && docker-php-ext-enable ds \
    && : "---------- Redis ----------" \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && : "---------- Memcached ----------" \
    && apk add --no-cache --virtual .memcached-build-dependencies libmemcached-dev \
    && apk add libmemcached \
    && pecl install memcached \
    && docker-php-ext-enable memcached \
    && apk del .memcached-build-dependencies \
    && : "---------- Mysql ----------" \
    && docker-php-ext-install -j$(nproc) pdo_mysql mysqli \
    && : "---------- Postgres ----------" \
    && apk add --no-cache --virtual .postgresql-build-dependencies postgresql-dev \
    && apk add libpq \
    && docker-php-ext-install -j$(nproc) pdo_pgsql \
    && apk del .postgresql-build-dependencies \
    && : "---------- Exif ----------" \
    && docker-php-ext-install -j$(nproc) exif \
    && : "---------- Bcmath ----------" \
    && docker-php-ext-install -j$(nproc) bcmath \
    && : "---------- Opcache ----------" \
    && docker-php-ext-install -j$(nproc) opcache \
    && : "---------- Intl ----------" \
    && apk add icu-libs libintl \
    && apk add --no-cache --virtual .intl-build-dependencies icu-dev \
    && docker-php-ext-install -j$(nproc) intl \
    && apk del .intl-build-dependencies \
    && : "---------- Soap ----------" \
    && apk add --no-cache --virtual .soap-build-dependencies libxml2-dev \
    && docker-php-ext-install -j$(nproc) soap \
    && apk del .soap-build-dependencies \
    && : "---------- Zip ----------" \
    && apk add --no-cache --virtual .zip-build-dependencies libzip-dev \
    && apk add libzip \
    && docker-php-ext-install -j$(nproc) zip \
    && apk del .zip-build-dependencies \
    && : "---------- PCNTL ----------" \
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-install pcntl \
    && : "---------- Cleanup ----------" \
    && apk del .build-deps \
    && docker-php-source delete \
    && rm -rf /var/cache/apk/* /var/tmp/* /tmp/*
    
RUN mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

RUN set -xe \
    && php --version \
    && php -m

ENTRYPOINT []
CMD []
