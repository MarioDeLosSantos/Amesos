<?php


$ip = $argv[1];
$port = $argv[2];
$nombreMaquina = $argv[3]; 

$user=$argv[4];
$password=$argv[5];



$connection_string = ssh2_connect($ip, $port);
$path = './Escritorio/Scripts-Conf/apagar.sh '. $nombreMaquina;


if (@ssh2_auth_password($connection_string, $user, $password))
{
	echo "Authentication Successful!\n";
	$stream = ssh2_exec($connection_string, $path);
	stream_set_blocking ($stream, true);
	echo stream_get_contents($stream);
}
else
{
	throw new Exception("Authentication failed!");
}
?>
