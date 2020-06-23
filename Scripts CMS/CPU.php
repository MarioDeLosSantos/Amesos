<?php

$ip = $argv[1];
$port = $argv[2];
$user = $argv[3];
$password = $argv[4];


$connection_string = ssh2_connect($ip, $port);

if (@ssh2_auth_password($connection_string, $user, $password))
{
	$stream = ssh2_exec($connection_string,  "echo $[100-$(vmstat 1 2|tail -1|awk '{print $15}')]");
	#$stream = ssh2_exec($connection_string,  "echo $argv[2]");

	stream_set_blocking ($stream, true);
	echo stream_get_contents($stream);
}
else
{
	throw new Exception("Authentication failed!");
}
?>
