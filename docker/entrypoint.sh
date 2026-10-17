#!/bin/bash
set -e

echo "Iniciando configuración de CakePHP para Railway..."

# Configurar el puerto dinámico de Railway
if [ -n "${PORT:-}" ]; then
    echo "Configurando Apache para escuchar en el puerto ${PORT}..."

    # Actualizar el puerto de escucha
    sed -i -E \
        's/^[[:space:]]*Listen[[:space:]]+.*/Listen '"${PORT}"'/' \
        /etc/apache2/ports.conf

    # Actualizar el VirtualHost predeterminado
    if [ -f /etc/apache2/sites-available/000-default.conf ]; then
        sed -i -E \
            's/<VirtualHost \*:[0-9]+>/<VirtualHost *:'"${PORT}"'>/' \
            /etc/apache2/sites-available/000-default.conf
    fi
fi

# Crear directorios necesarios para CakePHP
mkdir -p \
    /var/www/html/tmp/cache/models \
    /var/www/html/tmp/cache/persistent \
    /var/www/html/tmp/cache/views \
    /var/www/html/tmp/sessions \
    /var/www/html/tmp/tests \
    /var/www/html/logs \
    /var/www/html/webroot/img/empleados

# Asignar permisos para Apache
chown -R www-data:www-data \
    /var/www/html/tmp \
    /var/www/html/logs \
    /var/www/html/webroot/img/empleados

chmod -R 775 \
    /var/www/html/tmp \
    /var/www/html/logs \
    /var/www/html/webroot/img/empleados

# Instalar dependencias solo si vendor no existe
if [ ! -d /var/www/html/vendor ] && \
   [ -f /var/www/html/composer.json ]; then
    echo "Instalando dependencias de Composer..."

    composer install \
        --no-interaction \
        --prefer-dist \
        --optimize-autoloader
fi

# Verificar configuración antes de iniciar
echo "Validando configuración de Apache..."

apache2ctl -t

echo "Iniciando Apache..."

# Ejecutar el proceso principal del contenedor
exec "$@"
