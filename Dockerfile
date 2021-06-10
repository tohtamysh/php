FROM php:8.0.7-fpm-alpine

RUN set -xe \
	&& apk add --no-cache --virtual .build-deps $PHPIZE_DEPS git zip unzip zlib-dev coreutils \
    && : "---------- Imagemagick ----------" \
    && apk add --no-cache --virtual .imagick-build-dependencies imagemagick-dev \
    && apk add --virtual .imagick-runtime-dependencies imagemagick \
    && IMAGICK_TAG="3.4.4" \
    && git clone -o ${IMAGICK_TAG} --depth 1 https://github.com/mkoppanen/imagick.git /tmp/imagick \
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
    && DS_TAG="1.3.0" \
    && git clone -o ${DS_TAG} --depth 1 https://github.com/php-ds/ext-ds.git /tmp/ds \
    && cd /tmp/ds \
    && phpize \
    && ./configure \
    && make && make install \
    && echo "extension=ds.so" > /usr/local/etc/php/conf.d/ext-ds.ini \
    && : "---------- Redis ----------" \
    && REDIS_TAG="5.3.4" \
    && git clone -o ${REDIS_TAG} --depth 1 https://github.com/phpredis/phpredis.git /tmp/phpredis \
    && cd /tmp/phpredis \
    && phpize \
    && ./configure \
    && make && make install \
    && echo "extension=redis.so" > /usr/local/etc/php/conf.d/ext-redis.ini \
    && apk add --virtual .memcached-runtime-dependencies libmemcached-libs \
    && : "---------- Memcached ----------" \
    && apk add --no-cache --virtual .memcached-build-dependencies libmemcached-dev \
    && MEMCACHED_URL="https://pecl.php.net/get/memcached-3.1.5.tgz" \
    && pecl install igbinary \
    && docker-php-ext-enable igbinary \
    && mkdir -p /tmp/memcached \
    && curl -fsSL "$MEMCACHED_URL" -o memcached.tgz \
    && tar -xf memcached.tgz -C /tmp/memcached --strip-components=1 \
    && rm memcached.tgz \
    && docker-php-ext-configure /tmp/memcached --enable-memcached-session --enable-memcached-igbinary --enable-memcached-json \
    && docker-php-ext-install /tmp/memcached \
    && apk del .memcached-build-dependencies \
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
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-install -j$(nproc) zip \
    && apk del .zip-build-dependencies \
    && : "---------- Soap ----------" \
    && apk add --no-cache --virtual .soap-build-dependencies libxml2-dev \
    && docker-php-ext-install -j$(nproc) soap \
    && apk del .soap-build-dependencies \
    && : "---------- Exif ----------" \
    && docker-php-ext-install -j$(nproc) exif \
    && : "---------- Bcmath ----------" \
    && docker-php-ext-install -j$(nproc) bcmath \
    && : "---------- Opcache ----------" \
    && docker-php-ext-install -j$(nproc) opcache \
    && : "---------- Cleanup ----------" \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/* /var/tmp/* /tmp/*
    
RUN mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

RUN set -xe \
    && php --version \
    && php -m

ENTRYPOINT []
CMD []
