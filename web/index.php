<?php

require_once __DIR__.'/../vendor/autoload.php'; 

$app = new Silex\Application();
$app['debug'] = true;

$app->register(new Silex\Provider\DoctrineServiceProvider(), array(
    'db.options' => array(
        'driver'   => 'pdo_sqlite',
        'path'     => __DIR__.'/../db/pi-weatherstation.db',
    ),
));

$app->get('/hello/{name}', function($name) use($app) {
    return 'Hello '.$app->escape($name); 
});

$app->get('/setup', function() use($app) {
    $reply = "";
    $sm = $app['db']->getSchemaManager();

    if (sizeof($sm->listTables()) > 0) {
        $reply = "Database already exists!";
    } else {
        // create database
        $sql = file_get_contents(__DIR__.'/../db/schema.sql');
        $app['db']->executeQuery($sql);

        if (sizeof($sm->listTables > 0)) {
            $reply = "Database initialization successful!";
        }
    }

    return $reply = ($reply == "" ? "Something went wrong :(" : $reply);
});

$app->run();
