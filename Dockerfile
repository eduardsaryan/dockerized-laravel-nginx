FROM php:7.4-fpm

# Arguments defined in docker-compose.yml
ARG user
ARG uid

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Nginx and other necessary libraries
RUN apt-get update && apt-get install -y --no-install-recommends nginx supervisor libpng-dev libjpeg-dev libjpeg62-turbo libmcrypt4 libmcrypt-dev libcurl3-dev libxml2-dev libxslt-dev libicu-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directory for SSL files
RUN mkdir /etc/nginx/ssl

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

RUN composer create-project --prefer-dist laravel/laravel laravel-app

# Set working directory
WORKDIR /var/www/html/laravel-app

USER $user

# Use supervisord instead of direct run for Nginx and PHP
COPY ./conf/supervisord.conf /etc/supervisord.conf

# PHP-FPM basic config file
COPY ./conf/fpm.conf /usr/local/etc/php-fpm.d/www.conf

# Adding startup script for Nginx and PHP
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Exposing ports
EXPOSE 80 443 9000

CMD ["/entrypoint.sh"]
