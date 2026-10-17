FROM php:8.2-apache

ENV DEBIAN_FRONTEND=noninteractive
ENV APACHE_DOCUMENT_ROOT=/var/www/html/webroot
ENV COMPOSER_ALLOW_SUPERUSER=1

# Instalar dependencias del sistema
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

# Instalar extensiones PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j"$(nproc)" \
        intl gd zip pdo_mysql

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Reparar los módulos MPM de Apache
RUN set -eux; \
    a2dismod mpm_event mpm_worker mpm_prefork 2>/dev/null || true; \
    rm -f /etc/apache2/mods-enabled/mpm_*.load \
          /etc/apache2/mods-enabled/mpm_*.conf; \
    a2enmod mpm_prefork rewrite; \
    echo "=== MPM habilitados ==="; \
    find /etc/apache2/mods-enabled -maxdepth 1 \
        -name 'mpm_*.load' -printf '%f\n'; \
    test "$(find /etc/apache2/mods-enabled -maxdepth 1 \
        -name 'mpm_*.load' | wc -l)" -eq 1; \
    echo "=== Declaraciones MPM en configuracion ==="; \
    grep -RnsE \
        '^[[:space:]]*LoadModule[[:space:]]+mpm_(event|worker|prefork)_module' \
        /etc/apache2/apache2.conf \
        /etc/apache2/conf-enabled \
        /etc/apache2/sites-enabled \
        /etc/apache2/mods-enabled || true; \
    apache2ctl -t

# Configurar DocumentRoot
RUN sed -ri \
    "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" \
    /etc/apache2/sites-available/000-default.conf \
    /etc/apache2/apache2.conf

# Permitir acceso al webroot de CakePHP
RUN printf '%s\n' \
    '<Directory /var/www/html/webroot>' \
    '    Options FollowSymLinks' \
    '    AllowOverride All' \
    '    Require all granted' \
    '</Directory>' \
    >> /etc/apache2/apache2.conf

# Verificar Apache
RUN apache2ctl -t

WORKDIR /var/www/html

# Copiar el proyecto
COPY . /var/www/html

# Instalar dependencias de CakePHP
RUN composer install \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader

# Preparar directorios y permisos
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

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]
