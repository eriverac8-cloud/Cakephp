#!/bin/bash
set -e

# Configurar el puerto asignado por Railway
if [ -n "${PORT:-}" ]; then
    sed -i 's/^Listen .*/Listen '"$PORT"'/' /etc/apache2/ports.conf

    sed -i 's/<VirtualHost \*:.*>/<VirtualHost *:'"$PORT"'>/' \
        /etc/apache2/sites-available/000-default.conf
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

# Asignar permisos
chown -R www-data:www-data \
    /var/www/html/tmp \
    /var/www/html/logs \
    /var/www/html/webroot/img/empleados

chmod -R 775 \
    /var/www/html/tmp \
    /var/www/html/logs \
    /var/www/html/webroot/img/empleados

# Instalar dependencias si vendor no existe
if [ ! -d /var/www/html/vendor ] && \
   [ -f /var/www/html/composer.json ]; then
    composer install \
        --no-interaction \
        --prefer-dist \
        --optimize-autoloader
fi

# Comprobar módulos MPM antes de iniciar Apache
echo "Verificando módulos MPM de Apache..."
apache2ctl -M 2>&1 | grep -E 'mpm_(prefork|event|worker)_module' || true

# Iniciar Apache
exec "$@"
