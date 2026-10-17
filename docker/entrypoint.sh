#!/bin/bash
set -e

# Adaptar Apache al puerto dinámico asignado por Railway / PaaS si existe
if [ -n "$PORT" ]; then
    sed -i "s/Listen 80/Listen $PORT/g" /etc/apache2/ports.conf
    sed -i "s/<VirtualHost \*:80>/<VirtualHost \*:$PORT>/g" /etc/apache2/sites-available/*.conf
fi

# Crear directorios temporales, logs y uploads si no existen
mkdir -p /var/www/html/tmp/cache/models \
         /var/www/html/tmp/cache/persistent \
         /var/www/html/tmp/cache/views \
         /var/www/html/tmp/sessions \
         /var/www/html/tmp/tests \
         /var/www/html/logs \
         /var/www/html/webroot/img/empleados

# Asignar permisos adecuados para Apache
chmod -R 777 /var/www/html/tmp /var/www/html/logs /var/www/html/webroot/img/empleados 2>/dev/null || true
chown -R www-data:www-data /var/www/html/tmp /var/www/html/logs /var/www/html/webroot/img/empleados 2>/dev/null || true

# Ejecutar composer install si no existe vendor
if [ ! -d "/var/www/html/vendor" ] && [ -f "/var/www/html/composer.json" ]; then
    echo "Instalando dependencias de Composer..."
    composer install --no-interaction --prefer-dist --optimize-autoloader
fi

# Ejecutar el comando principal (Apache)
exec "$@"
