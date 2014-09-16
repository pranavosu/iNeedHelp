<?php

// This is the server API for the help iPhone app. To use the API, the app sends an HTTP POST request to our URL. The POST data contains a field "cmd" that indicates what API command should be executed.

try
{
	// Are we running in development or production mode? You can easily switch between these two in the Apache VirtualHost configuration.
	
	if (!defined('APPLICATION_ENV'))
		define('APPLICATION_ENV', getenv('APPLICATION_ENV') ? getenv('APPLICATION_ENV') : 'production');

	if (APPLICATION_ENV == 'development')
	{
		error_reporting(E_ALL|E_STRICT);
		ini_set('display_errors', 'on');
	}
	else
	{
		error_reporting(0);
		ini_set('display_errors', 'off');
	}

	// Load the config file.

	require_once 'api_config.php';

	$config = $config[APPLICATION_ENV];

	// To keep the code clean, I put the API into its own class.

	$api = new API($config);
	$api->handleCommand();

	//echo "OK" . PHP_EOL;
}
catch (Exception $e)
{
	if (APPLICATION_ENV == 'development')
		var_dump($e);
	else
		exitWithHttpError(500);
}

class API{

	private $pdo;

	function __construct($config)
	{
		// Create a connection to the database.
		$this->pdo = new PDO(
			'mysql:host=' . $config['db']['host'] . ';dbname=' . $config['db']['dbname'], 
			$config['db']['username'], 
			$config['db']['password'],
			array());

		// If there is an error executing database queries, we want PDO to
		// throw an exception. Our exception handler will then exit the script
		// with a "500 Server Error" message.
		$this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

		// We want the database to handle all strings as UTF-8.
		$this->pdo->query('SET NAMES utf8');
	}

	function handleCommand(){
		if(isset($_POST['cmd'])){
			switch (trim($_POST['cmd'])) {
				case 'update':
					$this->handleUpdate();
					break;

				case 'help':
					$this->handleHelp();
					break;

				case 'getreplycount':
					$this->getReplyCount();
					break;

				case 'updatereplycount':
					$this->updateReplyCount();
					break;

				
				default:
					exitWithHttpError(400, 'Unknown command');
					break;
			}
		}
	}

	function handleUpdate(){

		echo "update";

		$device_id = $this->getDeviceId();
		$latitude = $this->getLatitude();
		$longitude = $this->getLongitude();
		//$replyCount = $this->getReplyCount();

		$stmt = $this->pdo->prepare('SELECT * FROM users WHERE device_id = ? LIMIT 1');
		$stmt->execute(array($device_id));
		$device = $stmt->fetch(PDO::FETCH_OBJ);

		$this->pdo->beginTransaction();

		if($device!== false){

			$stmt = $this->pdo->prepare('UPDATE users SET latitude = ? , longitude = ? WHERE device_id = ?');
			$stmt->execute(array($latitude, $longitude, $device_id));

		}

		else{
			
			$stmt = $this->pdo->prepare('INSERT INTO users (device_id, latitude, longitude,replyCount) VALUES (?, ?, ?, ?)');
			$stmt->execute(array($device_id, $latitude, $longitude, 0));
		}

		$this->pdo->commit();
	}
	
	function handleHelp(){

		echo "Function executed help";

		$device_id = $this->getDeviceId();
		$latitude = $this->getLatitude();
		$longitude = $this->getLongitude();

		//$latitude = 39.995;
		//$longitude = -83.044;

		$location = (string)$latitude.",".(string)$longitude.",".(string)$device_id;
		
		$latitude_max = (double)$latitude + 0.004167;
		$latitude_min = (double)$latitude - 0.004167;
		$longitude_max = (double)$longitude + 0.004167;
		$longitude_min = (double)$longitude - 0.004167;
		
		$stmt = $this->pdo->prepare('SELECT * FROM users WHERE (latitude BETWEEN ? AND ?) AND (longitude BETWEEN ? AND ?)');
		$stmt->execute(array($latitude_min,$latitude_max,$longitude_min,$longitude_max));
		$devices = $stmt->fetchAll(PDO::FETCH_OBJ);

		foreach ($devices as $device) {
			//echo "Push notification to ". $device->device_id;
			if($device_id !== $device->device_id){ 
			$this->sendPushNotification($location,$device->device_id);
			}
		}

	}

	function getDeviceId(){
		if (!isset($_POST['device_id']))
			exitWithHttpError(400, 'Missing device_id');

		$device_id = trim(urldecode($_POST['device_id']));
		//if (!$this->isValidUserId($userId))
		//	exitWithHttpError(400, 'Invalid user_id');

		return $device_id;
	}

	function getLatitude(){
		if (!isset($_POST['latitude']))
			exitWithHttpError(400, 'Missing latitude');

		$latitude = trim($_POST['latitude']);

		return $latitude;
	}

	function getLongitude(){
		if (!isset($_POST['longitude']))
			exitWithHttpError(400, 'Missing longitude');

		$longitude = trim($_POST['longitude']);

		return $longitude; 
	}
	
	function getReplyCount(){

		$patient_device_id = $this->getDeviceId();

		$stmt = $this->pdo->prepare('SELECT replyCount FROM users WHERE device_id = ? LIMIT 1');
		$stmt->execute(array($patient_device_id));
		$device = $stmt->fetch(PDO::FETCH_COLUMN);
		echo $device;
		return $device;
	}

	function updateReplyCount(){

		$patient_device_id = $this->getDeviceId();
		

		$this->pdo->beginTransaction();

		$stmt = $this->pdo->exec('UPDATE users SET replyCount = replyCount + 1 WHERE device_id = "'.$patient_device_id.'"');
		//$stmt->execute(array($this->getReplyCount() + 1 , $patient_device_id));

		$this->pdo->commit();

	}

	function resetReplyCount(){

	$this->pdo->beginTransaction();

	$stmt = $this->pdo->exec('UPDATE users SET replyCount = 0');
	
	$this->pdo->commit();		

	}
	

	function sendPushNotification($message,$deviceToken){
		$passphrase = 'zaq123';

		$ctx = stream_context_create();
		stream_context_set_option($ctx, 'ssl', 'local_cert', 'ck.pem');
		stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);

		// Open a connection to the APNS server
		$fp = stream_socket_client(
			'ssl://gateway.sandbox.push.apple.com:2195', $err,
			$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);

		if (!$fp)
			exit("Failed to connect: $err $errstr" . PHP_EOL);

		echo 'Connected to APNS' . PHP_EOL;

			$alert = array('body'=> 'Somebody needs help', 'payload' => $message, 'action-loc-key'=> 'Open');
			
			
			
		// Create the payload body
		$body['aps'] = array(
			'alert' => $alert,
			'sound' => 'default'
			);
			

		//array('body' => $message,"action-loc-key": "Open") 
		// Encode the payload as JSON
		$payload = json_encode($body);

		echo $payload . PHP_EOL;

		// Build the binary notification
		$msg = chr(0) . pack('n', 32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;

		// Send it to the server
		$result = fwrite($fp, $msg, strlen($msg));

		if (!$result)
			echo 'Message not delivered' . PHP_EOL;
		else
			echo 'Message successfully delivered' . PHP_EOL;

		// Close the connection to the server
		fclose($fp);
	}

}

function exitWithHttpError($error_code, $message = '')
{
	switch ($error_code)
	{
		case 400: header("HTTP/1.0 400 Bad Request"); break;	
		case 403: header("HTTP/1.0 403 Forbidden"); break;
		case 404: header("HTTP/1.0 404 Not Found"); break;
		case 500: header("HTTP/1.0 500 Server Error"); break;
	}

	header('Content-Type: text/plain');

	if ($message != '')
		header('X-Error-Description: ' . $message);

	exit;
}
