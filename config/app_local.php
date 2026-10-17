<?php
declare(strict_types=1);

return [
    'debug' => filter_var(
        env('DEBUG', false),
        FILTER_VALIDATE_BOOLEAN
    ),

    'Datasources' => [
        'default' => [
            'className' => \Cake\Database\Connection::class,
            'driver' => \Cake\Database\Driver\Mysql::class,
            'persistent' => false,

            'host' => env('DB_HOST', 'localhost'),
            'port' => (int)env('DB_PORT', 3306),
            'username' => env('DB_USERNAME', 'root'),
            'password' => env('DB_PASSWORD', ''),
            'database' => env('DB_DATABASE', 'railway'),

            'encoding' => 'utf8mb4',
            'timezone' => 'UTC',
            'cacheMetadata' => true,
        ],
    ],
];
