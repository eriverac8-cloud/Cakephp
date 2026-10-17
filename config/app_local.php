<?php

use Cake\Database\Connection;
use Cake\Database\Driver\Mysql;

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
            'className' => Connection::class,
            'driver' => Mysql::class,
            'host' => env('DB_HOST', 'localhost'),
            'port' => (int)env('DB_PORT', 3306),
            'username' => env('DB_USERNAME', ''),
            'password' => env('DB_PASSWORD', ''),
            'database' => env('DB_DATABASE', ''),
            'url' => env('DATABASE_URL', null),
            'encoding' => 'utf8mb4',
            'timezone' => 'UTC',
            'cacheMetadata' => true,
        ],
    ],
];
