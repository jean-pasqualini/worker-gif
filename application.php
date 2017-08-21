<?php declare(strict_types=1);

namespace App;

require __DIR__.'/vendor/autoload.php';

use Google\Cloud\PubSub\PubSubClient;
use Silly\Application;
use Superbalist\PubSub\GoogleCloud\GoogleCloudPubSubAdapter;
use Symfony\Component\Console\Output\OutputInterface;

$app = new Application();

$client = new PubSubClient([
    'projectId' => 'truc',
]);
$adapter = new GoogleCloudPubSubAdapter($client);
$adapter->setAutoCreateTopics(true);
$adapter->setAutoCreateSubscriptions(true);
$adapter->setClientIdentifier('gif_service');

$app->command('worker:gif', function(OutputInterface $output) use ($adapter) {
    $output->writeln('<info>worker started....</info>');

    $adapter->subscribe('gif', function($message) {
        var_dump($message);
    });
});

$app->command('test:gif [keyword]', function(OutputInterface $output, $keyword) use ($adapter) {
    $adapter->publish('gif', ['keyword' => $keyword]);

    $output->writeln(sprintf('<info>Gif <bg=green;fg=red;options=bold>%s</> accepted</info>', strtoupper($keyword)));
});

$app->setDefaultCommand('worker:gif');
$app->run();