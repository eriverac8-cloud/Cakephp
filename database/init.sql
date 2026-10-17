-- ============================================================================
-- SCRIPT DE INICIALIZACIÓN AUTOMÁTICA EN CONTENEDOR MYSQL 8.0
-- ============================================================================

CREATE DATABASE IF NOT EXISTS railway CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sterenfix;

-- Asegurar usuario y permisos
CREATE USER IF NOT EXISTS 'sterenfix'@'%' IDENTIFIED BY 'SterenfixPassword123#';
GRANT ALL PRIVILEGES ON sterenfix.* TO 'sterenfix'@'%';
FLUSH PRIVILEGES;

-- Tablas e Índices
SOURCE /docker-entrypoint-initdb.d/schema.sql;
SOURCE /docker-entrypoint-initdb.d/seeds.sql;
