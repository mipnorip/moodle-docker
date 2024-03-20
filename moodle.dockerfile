FROM php:8.0.0-apache

EXPOSE 80

ARG version=403
ENV ServerName=localhost

# setup
RUN apt update && apt install -y \
        libpng-dev \
        libjpeg-dev \
        libwebp-dev;

RUN apt update && apt upgrade -y && \
    apt install wget unzip libzip-dev libwebp-dev libpq-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev -y && \
    docker-php-ext-install zip pgsql pdo_pgsql pdo && \
    docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install -j$(nproc) gd

RUN apt install libicu-dev -y && \
    docker-php-ext-install intl && \ 
    docker-php-ext-enable intl

RUN echo 'extension=zip.so' >> /usr/local/etc/php/conf.d/docker-php-ext-sodium.ini && \
    echo 'extension=pgsql' >> /usr/local/etc/php/conf.d/docker-php-ext-sodium.ini && \
    echo 'extension=gd' >> /usr/local/etc/php/conf.d/docker-php-ext-sodium.ini

RUN echo 'max_input_vars = 5000' > /usr/local/etc/php/conf.d/upload.ini

# work with moodle
WORKDIR /tmp
RUN wget "https://packaging.moodle.org/stable${version}/moodle-latest-${version}.zip"
RUN unzip *.zip
RUN rm -rf /var/www/html && cp -rf ./moodle /var/www/html && find /var/www/html -exec chmod 777 {} \;
RUN mkdir -m 777 /var/www/moodledata

# apache conf
COPY ./apache.conf /etc/apache2/sites-available/000-default.conf
