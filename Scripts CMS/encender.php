<?php

$nombreMaquina = $argv[1]; 
$puertoMinetest = $argv[2]; 
$puertoSSH = $argv[3];

echo $nombreMaquina;
echo $puertoMinetest;
echo $puertoSSH;

$public_ip = $argv[4];
$private_ip = $argv[5];
$port = $argv[6];

$user=$argv[7];
$password=$argv[8];

echo $public_ip;
echo $private_ip;
echo $port;

echo $user;
echo $password;



$connection_string = ssh2_connect($public_ip, $port);

$path = './Escritorio/Scripts-Conf/encender.sh '. $nombreMaquina . " " . $puertoMinetest . " " . $puertoSSH . " " . $private_ip;

if (@ssh2_auth_password($connection_string, $user, $password))
{
	echo "Authentication Successful!\n";
	#$stream = ssh2_exec($connection_string,  "echo $[100-$(vmstat 1 2|tail -1|awk '{print $15}')]");
	$stream = ssh2_exec($connection_string,  $path);

	stream_set_blocking ($stream, true);
	echo stream_get_contents($stream);
}
else
{
	throw new Exception("Authentication failed!");
}
?>
