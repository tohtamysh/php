FROM php:8.0.3-fpm-alpine

RUN mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

RUN set -xe \
    && php --version \
    && php -m

ENTRYPOINT []
CMD []
