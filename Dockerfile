FROM php:8.3.23-fpm-alpine

RUN set -eux \
    && apk update \
    && apk upgrade \
    && apk add \
        ca-certificates \
        tzdata \
        imagemagick \
        ripgrep \
    && update-ca-certificates

RUN curl -sSLf \
	-o /usr/local/bin/install-php-extensions \
	https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions && \
	chmod +x /usr/local/bin/install-php-extensions

RUN install-php-extensions \
    opcache \
    redis \
    gd \
    bcmath \
    intl \
    pdo_pgsql \
    pdo_mysql \
    zip \
    imagick \
    exif \
    pcntl \
    soap

RUN rm -rf /var/cache/apk/* /var/tmp/* /tmp/*
    
RUN mv /usr/local/etc/php/php.ini-production ${PHP_INI_DIR}/php.ini

COPY custom.ini ${PHP_INI_DIR}/conf.d/99-custom.ini

COPY composer.sh composer.sh

RUN chmod +x composer.sh && ./composer.sh && rm composer.sh

WORKDIR /srv

RUN set -xe \
    && php --version \
    && php -m \
    && composer --version

ENTRYPOINT []
CMD []
