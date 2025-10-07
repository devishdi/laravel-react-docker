FROM php:8.4.1-fpm-alpine3.21
LABEL maintainer="dev@ishdi.com"

ARG ENV="local"
ARG COMPOSER_VERSION=2.8.11
ARG UID=82

# PAGER required by wp-cli, see Help_Command::pass_through_pager
ENV COMPOSER_MEMORY_LIMIT=-1 \
    LD_PRELOAD="/usr/lib/preloadable_libiconv.so php" \
    PAGER=more \
    PHP_CPPFLAGS="$PHP_CPPFLAGS -std=c++17" \
    TERM=xterm
# alpine-sdk and autoconf to be able to install xdebug
# icu-dev to be able to install intl
# zip to allow Composer to download dependencies from dist
# recreate user www-data to allow PHP to write files
# recreate user www-data to allow PHP to write files
RUN echo "@edge-main http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "@edge-community http://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk add --no-cache linux-headers \
    && apk add --update alpine-sdk autoconf bash curl freetype-dev g++ gdb git gnu-libiconv@edge-community icu-dev \
    gettext gettext-dev bzip2-dev imap-dev php84-dev krb5-dev libc-dev openssl-dev libjpeg-turbo-dev libwebp-dev libpng libpng-dev libzip-dev make patch mysql-client pcre-dev \
    strace tzdata vim zip libxml2-dev libxslt-dev libgcrypt-dev ssmtp \
    && curl -sS https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar -o /usr/local/bin/composer \
    && chmod a+x /usr/local/bin/composer \
    && deluser www-data \
    && adduser -D -g 'php user' -h /var/www -s /bin/false -u $UID www-data \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ --with-webp=/usr/include/ \
    && docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) bcmath gd intl mysqli pdo_mysql zip calendar exif gettext bz2 soap sockets xsl \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && pecl install imap \
    && docker-php-ext-enable imap \
    && cp /usr/share/zoneinfo/Asia/Singapore /etc/localtime \
    && echo "Asia/Kolkata" > /etc/timezone \
    && set -xe \
    && apk del --purge alpine-sdk autoconf pcre-dev tzdata \
    && rm -rf /tmp/* /usr/share/vim/vim74/doc/* /usr/share/vim/vim74/tutor/* /usr/src/php.tar* /var/cache/apk/*   

RUN echo "hostname=localhost" > /etc/ssmtp/ssmtp.conf \
    && echo "root=dev@ishdi.com" >> /etc/ssmtp/ssmtp.conf \
    && echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf \
    && echo "mailhub=mailhog:1025" >> /etc/ssmtp/ssmtp.conf

COPY php.ini /usr/local/etc/php/
# prefix with zzz- to make sure the config will be loaded
COPY app.conf /usr/local/etc/php-fpm.d/zzz-app.conf
