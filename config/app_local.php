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
            'host' => env('MYSQLHOST', 'localhost'),
            'port' => (int)env('MYSQLPORT', 3306),
            'username' => env('MYSQLUSER', 'root'),
            'password' => env('MYSQLPASSWORD', ''),
            'database' => env('MYSQLDATABASE', 'railway'),
            'encoding' => 'utf8mb4',
            'timezone' => 'UTC',
            'cacheMetadata' => true,
        ],
    ],
];
