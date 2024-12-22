FROM php:8.2-fpm as php

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libtool \
    make \
    gcc

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

RUN pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

WORKDIR /var/www
COPY . .

# Get latest Composer
COPY --from=composer:2.7.4 /usr/bin/composer /usr/bin/composer

# This should actually be run in the host terminal, not in the container
RUN chmod +x Docker/entrypoint.sh

ENTRYPOINT [ "Docker/entrypoint.sh" ]

CMD ["php-fpm"]


# Node
FROM node:alpine as node

WORKDIR /var/www
COPY . .

RUN npm install --global cross-env
RUN npm install

VOLUME /var/www/node_modules