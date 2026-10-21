FROM php:8.2.35-apache-bookworm
LABEL org.opencontainers.image.source="https://github.com/AppacYazilim/dphphost"

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

HEALTHCHECK --interval=10s --timeout=4s --start-period=5s \
    CMD curl -f http://localhost/health || exit 1

RUN chmod uga+x /usr/local/bin/install-php-extensions && sync

# Pin Imagick 3.8.1 to its upstream commit; avoid the unreliable PECL archive endpoint.
RUN DEBIAN_FRONTEND=noninteractive apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qq -y wget locales \
    curl \
    git \
    zip unzip \
    && for attempt in 1 2 3; do \
    install-php-extensions \
    bcmath \
    bz2 \
    calendar \
    exif \
    gd \
    intl \
    ldap \
    memcached \
    mysqli \
    opcache \
    pdo_mysql \
    soap \
    xsl \
    zip \
    Imagick/imagick@70087bab33eab913e99ac77d64d04d1a2fd0b7b0 \
    sockets \
    pcntl \
    mongodb \
    redis && break; \
    test "$attempt" -lt 3 || exit 1; \
    sleep 5; \
    done \
    && a2enmod rewrite

COPY custom.ini /usr/local/etc/php/conf.d/custom.ini
COPY locales.gen /etc/locale.gen

RUN dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN wget -O /root/browsercap.ini https://browscap.org/stream?q=PHP_BrowsCapINI
# RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
