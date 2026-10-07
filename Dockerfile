FROM php:8.3-apache

RUN a2enmod rewrite
RUN docker-php-ext-install mysqli pdo pdo_mysql

# 1. Install & enable Xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug

# 2. Use PHP's built-in development ini (enables display_errors & E_ALL)
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# 3. Configure Xdebug
RUN echo "xdebug.mode=develop,debug" >> "$PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini" \
    && echo "xdebug.start_with_request=yes" >> "$PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini" \
    && echo "xdebug.client_host=host.docker.internal" >> "$PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini" \
    && echo "xdebug.client_port=9003" >> "$PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini"
