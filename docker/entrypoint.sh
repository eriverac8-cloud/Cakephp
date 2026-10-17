#!/bin/bash
set -eu

echo "Iniciando CakePHP en Railway..."

# Limpiar declaraciones MPM adicionales en archivos de configuracion
echo "Limpiando configuracion MPM..."

a2dismod mpm_event mpm_worker mpm_prefork 2>/dev/null || true

find /etc/apache2 -type f \
    ! -path '/etc/apache2/mods-available/*' \
    -exec sed -i -E \
    '/^[[:space:]]*LoadModule[[:space:]]+mpm_(event|worker|prefork)_module[[:space:]]+/d' \
    {} +

rm -f /etc/apache2/mods-enabled/mpm_*.load \
      /etc/apache2/mods-enabled/mpm_*.conf

a2enmod mpm_prefork rewrite

# Configurar puerto proporcionado por Railway
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

    if grep -qE '^[[:space:]]*Listen[[:space:]]+' \
        /etc/apache2/ports.conf; then
        sed -i -E \
            "s/^[[:space:]]*Listen[[:space:]].*/Listen ${PORT}/" \
            /etc/apache2/ports.conf
    else
        echo "Listen ${PORT}" >> /etc/apache2/ports.conf
    fi

    sed -i -E \
        "s/<VirtualHost[[:space:]]+\\*:[0-9]+>/<VirtualHost *:${PORT}>/" \
        /etc/apache2/sites-available/000-default.conf

    echo "Apache escuchara en el puerto ${PORT}"
fi

# Preparar directorios de CakePHP
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

# Mostrar las declaraciones MPM que Apache encuentra
echo "=== Declaraciones MPM ==="
grep -RnsE '^[[:space:]]*LoadModule[[:space:]]+mpm_' \
    /etc/apache2 --exclude-dir=mods-available || true

# Validar configuracion
echo "Validando Apache..."
apache2ctl -t

# Iniciar Apache en primer plano
echo "Iniciando Apache..."
exec "$@"
