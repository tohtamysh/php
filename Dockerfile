FROM php:8.4.6-fpm-alpine

RUN set -eux \
    && apk update \
    && apk upgrade \
    && apk add \
        ca-certificates \
        tzdata \
        imagemagick \
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
    soap \
    mbstring \
    ctype \
    dom

RUN rm -rf /var/cache/apk/* /var/tmp/* /tmp/*
    
RUN mv /usr/local/etc/php/php.ini-production ${PHP_INI_DIR}/php.ini

COPY custom.ini ${PHP_INI_DIR}/conf.d/99-custom.ini

RUN EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')" \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")" \
    if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ] \
    then \
        >&2 echo 'ERROR: Invalid installer checksum' \
        rm composer-setup.php \
        exit 1 \
    fi \
    php composer-setup.php --quiet --install-dir=/usr/local/bin --filename=composer \
    RESULT=$? \
    rm composer-setup.php \
    chmod +x /usr/local/bin/composer

WORKDIR /srv

RUN set -xe \
    && php --version \
    && php -m \
    && composer --version

ENTRYPOINT []
CMD []
