#!/bin/bash

#Path del json de datos
jsonPath="./scripts/info/datos.json"
jsonInformativoPath="./scripts/info/jsonInformativo.json"

#Lo primero es crear un array vacio donde iremos insertando cada uno de los elementos

echo '
{  
  "Servidores":[]
}
' > $jsonInformativoPath
#Primero creamos campos vacios y luegos los actualizamos
numero_centros=$(jq '.Centres | length -1' $jsonPath)

for i in $( seq 0 $numero_centros)
do
    numero_servidores=$(jq --arg var $i '.Centres[$var | tonumber ].Servers | length - 1' $jsonPath)
    for j in $( seq 0 $numero_servidores ); do
	#Lo primero creamos los parametros 
	jq '.Servidores += [{"public_ip": "None","port": "None"}]' $jsonInformativoPath > temp.json
	cat temp.json > $jsonInformativoPath
	rm temp.json

	#Ahora los actualizamos
	ip=$(jq .Centres[$i].public_ip $jsonPath)
	port=$(jq .Centres[$i].Servers[$j].port $jsonPath)

	numero=$(jq '.Servidores | length -1' $jsonInformativoPath)
	#Primero el puerto
	jq .Servidores[$numero].port=$port $jsonInformativoPath> temp.json
	cat temp.json > $jsonInformativoPath
	rm temp.json

	#Despues la IP
	jq .Servidores[$numero].public_ip=$ip $jsonInformativoPath > temp.json
	cat temp.json > $jsonInformativoPath
	rm temp.json
    
    done
done 

