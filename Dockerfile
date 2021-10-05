FROM php:apache
LABEL org.opencontainers.image.source https://github.com/AppacYazilim/dphphost

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

HEALTHCHECK --interval=10s --timeout=4s --start-period=5s curl -f http://localhost/health || exit 1

RUN chmod uga+x /usr/local/bin/install-php-extensions && sync

RUN DEBIAN_FRONTEND=noninteractive apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qq -y wget locales \
    curl \
    git \
    zip unzip \
    && install-php-extensions \
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
    imagick \
    sockets \
    pcntl \
    mongodb \
    && a2enmod rewrite

COPY custom.ini /usr/local/etc/php/conf.d/custom.ini
COPY locales.gen /etc/locale.gen

RUN dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8 
ENV LC_ALL en_US.UTF-8

RUN wget -O /root/browsercap.ini http://browscap.org/stream?q=PHP_BrowsCapINI
# RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
