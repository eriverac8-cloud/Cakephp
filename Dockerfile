FROM php:8.2-apache

# Configuración del entorno
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

# Instalar extensiones PHP necesarias para CakePHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j"$(nproc)" \
        intl \
        gd \
        zip \
        pdo_mysql

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Configurar un solo MPM de Apache
RUN set -eux; \
    a2dismod mpm_event mpm_worker 2>/dev/null || true; \
    a2enmod mpm_prefork rewrite; \
    test "$(find /etc/apache2/mods-enabled -maxdepth 1 -name 'mpm_*.load' | wc -l)" -eq 1

# Configurar DocumentRoot para CakePHP
RUN sed -ri \
    "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" \
    /etc/apache2/sites-available/000-default.conf \
    /etc/apache2/apache2.conf

# Permitir acceso al webroot
RUN printf '%s\n' \
    '<Directory /var/www/html/webroot>' \
    '    Options FollowSymLinks' \
    '    AllowOverride All' \
    '    Require all granted' \
    '</Directory>' \
    >> /etc/apache2/apache2.conf

# Verificar la configuración de Apache
RUN apache2ctl -t

# Directorio de la aplicación
WORKDIR /var/www/html

# Copiar el código del proyecto
COPY . /var/www/html

# Instalar dependencias PHP de CakePHP
RUN composer install \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader

# Crear directorios necesarios para CakePHP
RUN mkdir -p \
    tmp/cache/models \
    tmp/cache/persistent \
    tmp/cache/views \
    tmp/sessions \
    tmp/tests \
    logs \
    webroot/img/empleados \
    && chown -R www-data:www-data tmp logs webroot/img/empleados \
    && chmod -R 775 tmp logs webroot/img/empleados

# Copiar el script de inicio
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

# Puerto HTTP
EXPOSE 80

# Iniciar la aplicación
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]
