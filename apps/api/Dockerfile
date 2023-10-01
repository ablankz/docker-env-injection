FROM php:8.2-fpm

COPY php.ini /usr/local/etc/php/
COPY docker.conf /usr/local/etc/php-fpm.d/docker.conf

RUN apt-get update \
  && apt-get install -y zlib1g-dev mariadb-client vim libzip-dev iputils-ping net-tools dnsutils libpq-dev\
  && docker-php-ext-install zip pdo pgsql pdo_pgsql 

#Composer install
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER 1

ENV COMPOSER_HOME /composer

ENV PATH $PATH:/composer/vendor/bin

WORKDIR /var/www