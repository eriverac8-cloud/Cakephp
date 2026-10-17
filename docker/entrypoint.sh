#!/bin/bash
set -e

echo "Iniciando CakePHP en Railway..."

if [ -n "${PORT:-}" ]; then
    case "$PORT" in
        *[!0-9]*|"")
            echo "ERROR: Puerto invalido"
            exit 1
            ;;
    esac

    if [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
        echo "ERROR: Puerto fuera de rango"
        exit 1
    fi

    sed -i -E \
        "s/^[[:space:]]*Listen[[:space:]].*/Listen ${PORT}/" \
        /etc/apache2/ports.conf

    sed -i -E \
        "s/<VirtualHost \\*:[0-9]+>/<VirtualHost *:${PORT}>/" \
        /etc/apache2/sites-available/000-default.conf

    echo "Apache escuchara en el puerto ${PORT}"
fi

mkdir -p \
    /var/www/html/tmp/cache/models \
    /var/www/html/tmp/cache/persistent \
    /var/www/html/tmp/cache/views \
    /var/www/html/tmp/sessions \
    /var/www/html/tmp/tests \
    /var/www/html/logs \
    /var/www/html/webroot/img/empleados

chown -R www-data:www-data \
    /var/www/html/tmp \
    /var/www/html/logs \
    /var/www/html/webroot/img/empleados

chmod -R 775 \
    /var/www/html/tmp \
    /var/www/html/logs \
    /var/www/html/webroot/img/empleados

echo "Validando Apache..."
apache2ctl -t

echo "Iniciando Apache..."
exec "$@"
