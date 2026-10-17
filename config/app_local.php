<?php
/**
 * Configuración local y de producción para CakePHP.
 */

return [
    'debug' => filter_var(
        env('DEBUG', false),
        FILTER_VALIDATE_BOOLEAN
    ),

    'Security' => [
        'salt' => env('SECURITY_SALT', ''),
    ],

    'Datasources' => [
        'default' => [
            'className' => \Cake\Database\Connection::class,
            'driver' => \Cake\Database\Driver\Mysql::class,
            'host' => env('DB_HOST', 'localhost'),
            'port' => env('DB_PORT', '3306'),
            'username' => env('DB_USERNAME', ''),
            'password' => env('DB_PASSWORD', ''),
            'database' => env('DB_DATABASE', ''),
            'url' => env('DATABASE_URL', null),
        ],
    ],
];
