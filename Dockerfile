FROM php:7-fpm-alpine

RUN apk add --update --no-cache autoconf \
    make \
    gcc \
    g++ \
    bzip2-dev \
    libmcrypt-dev \
    gettext-dev \
    aspell-dev \
    libmcrypt-dev \
    libmemcached-dev \
    libzip-dev \
    git \
    curl

RUN docker-php-ext-install bz2 \
    calendar \
    exif \
    gettext \
    pcntl \
    pspell \
    mysqli \
    shmop \
    sockets \
    zip \
    opcache

RUN pecl install mcrypt-1.0.2
RUN pecl install memcached

RUN docker-php-ext-enable mcrypt \
    memcached

#gd
RUN apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev && \
  docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ && \
  NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
  docker-php-ext-install -j${NPROC} gd && \
  apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

#acpu
RUN docker-php-source extract \
    && apk add --no-cache --virtual .phpize-deps-configure $PHPIZE_DEPS \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && apk del .phpize-deps-configure \
    && docker-php-source delete

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apk add shadow && usermod -u 1000 www-data && groupmod -g 1000 www-data

RUN apk add msmtp

COPY zz-docker.conf /usr/local/etc/php-fpm.d
COPY user.ini /usr/local/etc/php/conf.d

CMD php-fpm