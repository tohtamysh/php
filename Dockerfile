FROM php:8.0.3-fpm-alpine

RUN set -xe \
	&& apk add --no-cache --virtual .build-deps $PHPIZE_DEPS git zip unzip zlib-dev coreutils \
    && : "---------- Imagemagick ----------" \
    && apk add --no-cache --virtual .imagick-build-dependencies imagemagick-dev \
    && apk add --virtual .imagick-runtime-dependencies imagemagick \
    && git clone --depth 1 https://github.com/mkoppanen/imagick.git /tmp/imagick \
    && cd /tmp/imagick \
    && phpize \
    && ./configure \
    && make && make install \
    && echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini \
    && apk del .imagick-build-dependencies \
    && : "---------- GD ----------" \
    && apk add --no-cache --virtual .gd-build-dependencies freetype-dev libjpeg-turbo-dev libjpeg-turbo libpng-dev jpeg-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && : "---------- DS ----------" \
    && git clone --depth 1 https://github.com/php-ds/ext-ds.git /tmp/ds \
    && cd /tmp/ds \
    && phpize \
    && ./configure \
    && make && make install \
    && echo "extension=ds.so" > /usr/local/etc/php/conf.d/ext-ds.ini \
    && : "---------- Redis ----------" \
    && git clone --depth 1 https://github.com/phpredis/phpredis.git /tmp/phpredis \
    && cd /tmp/phpredis \
    && phpize \
    && ./configure \
    && make && make install \
    && echo "extension=redis.so" > /usr/local/etc/php/conf.d/ext-redis.ini \
    && : "---------- Postgres ----------" \
    && apk add --no-cache --virtual .postgresql-build-dependencies postgresql-dev \
    && apk add --virtual .postgresql-runtime-dependencies libpq \
    && docker-php-ext-install -j$(nproc) pdo_pgsql \
    && apk del .postgresql-build-dependencies \
    && : "---------- Mysql ----------" \
    && docker-php-ext-install -j$(nproc) pdo_mysql mysqli \
    && : "---------- Zip ----------" \
    && apk add --no-cache --virtual .zip-build-dependencies libzip-dev \
    && apk add --virtual .zip-runtime-dependencies libzip \
    && docker-php-ext-install -j$(nproc) zip \
    && apk del .zip-build-dependencies \
    && : "---------- Exif ----------" \
    && docker-php-ext-install -j$(nproc) exif \
    && : "---------- Bcmath ----------" \
    && docker-php-ext-install -j$(nproc) bcmath \
    && : "---------- Cleanup ----------" \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/* /var/tmp/* /tmp/*
    
RUN mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

RUN set -xe \
    && php --version \
    && php -m

ENTRYPOINT []
CMD []
