FROM php:8.2-apache

ENV DEBIAN_FRONTEND=noninteractive
ENV APACHE_DOCUMENT_ROOT=/var/www/html/webroot
ENV COMPOSER_ALLOW_SUPERUSER=1

# Dependencias del sistema
RUN apt-get update && apt-get install -y \
    unzip \
    curl \
    git \
    libicu-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libonig-dev \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Extensiones PHP necesarias para CakePHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j"$(nproc)" \
        intl gd zip pdo_mysql

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Limpiar declaraciones MPM y activar solamente prefork
RUN set -eux; \
    a2dismod mpm_event mpm_worker mpm_prefork 2>/dev/null || true; \
    find /etc/apache2 -type f \
        ! -path '/etc/apache2/mods-available/*' \
        -exec sed -i -E \
        '/^[[:space:]]*LoadModule[[:space:]]+mpm_(event|worker|prefork)_module[[:space:]]+/d' \
        {} +; \
    rm -f /etc/apache2/mods-enabled/mpm_*.load \
          /etc/apache2/mods-enabled/mpm_*.conf; \
    a2enmod mpm_prefork rewrite; \
    echo "=== Declaraciones MPM activas ==="; \
    grep -RnsE '^[[:space:]]*LoadModule[[:space:]]+mpm_' \
        /etc/apache2 --exclude-dir=mods-available || true; \
    apache2ctl -t

# Configurar DocumentRoot de CakePHP
RUN sed -ri \
    "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" \
    /etc/apache2/sites-available/000-default.conf \
    /etc/apache2/apache2.conf

# Permisos para el directorio público
RUN printf '%s\n' \
    '<Directory /var/www/html/webroot>' \
    '    Options FollowSymLinks' \
    '    AllowOverride All' \
    '    Require all granted' \
    '</Directory>' \
    >> /etc/apache2/apache2.conf

WORKDIR /var/www/html

# Copiar el proyecto
COPY . /var/www/html

# Instalar dependencias PHP
RUN composer install \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader

# Preparar directorios de CakePHP
RUN mkdir -p \
    tmp/cache/models \
    tmp/cache/persistent \
    tmp/cache/views \
    tmp/sessions \
    tmp/tests \
    logs \
    webroot/img/empleados \
    && chown -R www-data:www-data \
        tmp logs webroot/img/empleados \
    && chmod -R 775 \
        tmp logs webroot/img/empleados

# Script de inicio
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]
