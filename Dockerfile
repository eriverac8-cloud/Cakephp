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

# Extensiones PHP para CakePHP y MySQL
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j"$(nproc)" \
        intl gd zip pdo_mysql

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Corregir definitivamente los módulos MPM habilitados
RUN set -eux; \
    a2dismod mpm_event mpm_worker mpm_prefork 2>/dev/null || true; \
    rm -f /etc/apache2/mods-enabled/mpm_*.load \
          /etc/apache2/mods-enabled/mpm_*.conf; \
    for file in /etc/apache2/apache2.conf \
                /etc/apache2/conf-enabled/*.conf \
                /etc/apache2/sites-enabled/*.conf; do \
        if [ -f "$file" ] && [ ! -L "$file" ]; then \
            sed -i -E \
                '/^[[:space:]]*LoadModule[[:space:]]+mpm_(event|worker)_module[[:space:]]/d' \
                "$file"; \
        fi; \
    done; \
    a2enmod mpm_prefork rewrite; \
    echo "Verificando archivos MPM habilitados:"; \
    find /etc/apache2/mods-enabled -maxdepth 1 \
        -name 'mpm_*.load' -printf '%f\n'; \
    test "$(find /etc/apache2/mods-enabled -maxdepth 1 \
        -name 'mpm_*.load' | wc -l)" -eq 1; \
    apache2ctl -t

# Configurar DocumentRoot de CakePHP
RUN sed -ri \
    "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" \
    /etc/apache2/sites-available/000-default.conf \
    /etc/apache2/apache2.conf

# Permisos para webroot
RUN printf '%s\n' \
    '<Directory /var/www/html/webroot>' \
    '    Options FollowSymLinks' \
    '    AllowOverride All' \
    '    Require all granted' \
    '</Directory>' \
    >> /etc/apache2/apache2.conf

# Validar configuración
RUN apache2ctl -t

WORKDIR /var/www/html

# Copiar aplicación
COPY . /var/www/html

# Instalar dependencias
RUN composer install \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader

# Directorios de CakePHP
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
    && chmod -R 775 tmp logs webroot/img/empleados

# Script de inicio
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]
