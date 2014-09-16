<?php 

require_once 'api.php'; 
require_once 'api_config.php';
$config = $config[APPLICATION_ENV];

echo "ok1";

$api = new API($config);

echo "ok2";

$api->resetReplyCount();

echo "ok3";

?>