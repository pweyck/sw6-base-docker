FROM php:7.4-fpm-alpine3.11

ENV LD_PRELOAD=/usr/lib/preloadable_libiconv.so

RUN apk add --no-cache \
            libxml2 \
            libjpeg-turbo \
            libpng \
            libcurl \
            icu \
            libzip \
            gnu-libiconv \
            nginx \
            zstd xz \
    && apk add --no-cache --virtual build-deps \
            libxml2-dev \
            libjpeg-turbo-dev \
            libpng-dev \
            icu-dev \
            libzip-dev \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) gd \
    && docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) intl \
    && docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) mysqli \
    && docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) pdo_mysql \
    && docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) zip \
    && apk del build-deps

COPY root /

RUN chown www-data:www-data -R /app

WORKDIR /app

EXPOSE 8000

ENTRYPOINT [ "/bin/entrypoint.sh" ]

HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8000/ping
