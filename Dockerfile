FROM php:8.2-apache

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive

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

# Instalar extensiones PHP necesarias para CakePHP y MySQL
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j"$(nproc)" \
        intl \
        gd \
        zip \
        pdo_mysql

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Corregir los módulos MPM de Apache:
# deshabilitar los MPM alternativos y habilitar solo prefork
RUN a2dismod mpm_event mpm_worker 2>/dev/null || true
RUN a2enmod mpm_prefork rewrite

# Verificar que solo se cargue un MPM
RUN set -eu; \
    count="$(apache2ctl -M 2>/dev/null | grep -Ec 'mpm_(prefork|event|worker)_module' || true)"; \
    test "$count" -eq 1

# Configurar Apache para utilizar CakePHP webroot
ENV APACHE_DOCUMENT_ROOT=/var/www/html/webroot

RUN sed -ri \
    's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf && \
    sed -ri \
    's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/apache2.conf \
    /etc/apache2/conf-available/*.conf && \
    printf '%s\n' \
    '<Directory /var/www/html/webroot>' \
    '    Options FollowSymLinks' \
    '    AllowOverride All' \
    '    Require all granted' \
    '</Directory>' \
    >> /etc/apache2/apache2.conf

# Directorio de trabajo
WORKDIR /var/www/html

# Copiar el código de la aplicación
COPY . /var/www/html

# Instalar dependencias PHP
RUN composer install \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader

# Asignar permisos
RUN chown -R www-data:www-data /var/www/html

# Copiar script de arranque
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Puerto HTTP
EXPOSE 80

# Arranque del contenedor
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]
