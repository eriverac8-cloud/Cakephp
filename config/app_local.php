<?php
/**
 * Configuración Local para Sobreescrituras por Entorno
 */

return [
    'debug' => filter_var(env('DEBUG', true), FILTER_VALIDATE_BOOLEAN),

    'Security' => [
        'salt' => env('SECURITY_SALT', 'c30d92376e1a0df3311dbb5b991386d38e8ec8e0f6c77bb320c15e8b4e7a68fc'),
    ],

    'Datasources' => [
        'default' => [
            'className' => 'Cake\Database\Connection',
            'driver' => env('DB_DRIVER', 'Cake\Database\Driver\Mysql'),
            'host' => env('DB_HOST', 'db'),
            'port' => env('DB_PORT', '3306'),
            'username' => env('DB_USERNAME', 'sterenfix'),
            'password' => env('DB_PASSWORD', 'SterenfixPassword123#'),
            'database' => env('DB_DATABASE', 'sterenfix'),
            'url' => env('DATABASE_URL', null),
        ],
    ],
];
