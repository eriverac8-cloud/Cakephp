FROM php:8.2-apache

# Evitar prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias del sistema requeridas para extensiones PHP
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

# Compilar e instalar extensiones requeridas por CakePHP y MySQL
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j$(nproc) \
    intl \
    gd \
    zip \
    pdo_mysql

# Instalar Composer desde la imagen oficial
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Habilitar mod_rewrite en Apache
RUN a2enmod rewrite

# Configurar Apache DocumentRoot hacia /var/www/html/webroot
ENV APACHE_DOCUMENT_ROOT=/var/www/html/webroot
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf && \
    sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf && \
    echo '<Directory /var/www/html/webroot>\n    Options Indexes FollowSymLinks\n    AllowOverride All\n    Require all granted\n</Directory>' >> /etc/apache2/apache2.conf

# Directorio de trabajo
WORKDIR /var/www/html

# Copiar el código de la aplicación
COPY . /var/www/html

# Instalar dependencias de Composer dentro del contenedor
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Asignar permisos a www-data
RUN chown -R www-data:www-data /var/www/html

# Copiar script de arranque
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]
