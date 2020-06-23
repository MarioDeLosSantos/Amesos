<?php

$ip = $argv[1];
$port = $argv[2];
$user = $argv[3];
$password = $argv[4];

$connection_string = ssh2_connect($ip, $port);



if (@ssh2_auth_password($connection_string, $user, $password))
{
	if($port==6000)
	{
		$stream = ssh2_exec($connection_string,  "uptime | awk -F ',' ' {print $1} ' | 
		awk ' {print $3} ' | awk -F ':' ' {hrs=$1; min=$2; print hrs*60 + min} '");
	}
	else
	{
		$stream = ssh2_exec($connection_string,  "uptime | awk -F ',' ' {print $1} ' | 
		awk ' {print $3} ' | awk -F ':' ' {hrs=$1; min=$2; print hrs + min} '");
	}
	
					
	stream_set_blocking ($stream, true);
	echo stream_get_contents($stream);
}
else
{
	throw new Exception("Authentication failed!");
}
?>
