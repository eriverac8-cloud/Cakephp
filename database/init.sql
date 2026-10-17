-- ============================================================================
-- SCRIPT DE INICIALIZACIÓN AUTOMÁTICA - MYSQL 8.0
-- SISTEMA DE GESTIÓN DE PERSONAL STERENFIX
-- ============================================================================

CREATE DATABASE IF NOT EXISTS railway
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE railway;

-- Crear usuario de la aplicación
CREATE USER IF NOT EXISTS 'sterenfix'@'%'
    IDENTIFIED BY 'SterenfixPassword123#';

-- Permisos sobre la base de datos
GRANT ALL PRIVILEGES ON railway.* TO 'sterenfix'@'%';

FLUSH PRIVILEGES;

-- ============================================================================
-- IMPORTANTE:
-- Los archivos schema.sql y seeds.sql deben ejecutarse mediante el mecanismo
-- de inicialización del contenedor MySQL, no mediante SOURCE dentro de este
-- archivo si el entrypoint no admite esos comandos en este contexto.
-- ============================================================================
