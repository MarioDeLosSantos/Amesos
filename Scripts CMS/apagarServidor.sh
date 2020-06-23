#!/bin/bash
#Este Script recorerra todos los centros de procesamiento de datos buscando aquel
#cuyo nombre sea igual al del parametro.Una vez encontrado,desplegaremos el primer 
#servidor de ese centro de procesamiento de datos disponible.

#Guardamos el nombre del centro de procesamiento de datos que tenemos que buscar
parametro=$1

#Path del json con los datos
jsonPath="./scripts/info/datos.json"

#Buscamos el centro de procesamiento de datos que nos han dado en el parametro
numero_centros=$(jq '. | length -1' $jsonPath)

#Por cada uno de los centros , comparamos el nombre
for i in $( seq 0 $numero_centros )
do
    #Cogemos el nombre del centro de procesamiento actual y le quitamos las comillas
    #para poder compararlo con el parametro
    nombre=$(jq .Centres[$i].name $jsonPath)
    temp="${nombre%\"}"
    nombre="${temp#\"}"

    user=$(jq .Centres[$i].user $jsonPath)
    temp="${user%\"}"
    temp="${temp#\"}"
    user=$temp
    password=$(jq .Centres[$i].password $jsonPath)
    temp="${password%\"}"
    temp="${temp#\"}"
    password=$temp

    #En caso de que hayamos encontrado el centro de procesamiento de datos
    #Cerramos el primer servidor disponible
    if [[ "$nombre" = $parametro ]]; then
        #Buscamos el primer servidor disponible
         #Creamos el nombre de la maquina en base al numero de servidores que haya 
        public_ip=$(jq .Centres[$i].public_ip $jsonPath)
        temp="${public_ip%\"}"
        public_ip="${temp#\"}"
        port=$(jq .Centres[$i].port $jsonPath)
        numero_servidores=$(jq --arg var $i '.Centres[$var | tonumber ].Servers | length -1' $jsonPath)
        indice_servidor=0
        CPU_final=$(jq .Centres[$i].Servers[0].CPU $jsonPath)
        for j in $( seq 1 $numero_servidores ); do
            #Recorremos todos los servidores buscando aquel que use menos CPU
            nueva_CPU=$(jq .Centres[$i].Servers[$j].CPU $jsonPath)
            if (("$nueva_CPU" < "$CPU_final")) ; then
                CPU_final=$nueva_CPU
                indice_servidor=$j
            fi
            echo $CPU_final
            echo $indice_servidor
        done

        numero=-1

        if (("$numero_servidores" > "$numero")); then
            nombreServer=$(jq .Centres[$i].Servers[$indice_servidor].name $jsonPath)
            temp="${nombreServer%\"}"
            nombreServer="${temp#\"}"

            #Vamos a guardar el servidor en servidores en desuso
            numero_servidores=$(jq --arg var $i '.Centres[$var | tonumber ].UnusedPorts | length  ' $jsonPath)
            #Y por ultimo actualizamos el siguiente puerto disponible de Minetest
            jq '.Centres[0].UnusedPorts += [{"name":"", "number":null}]' $jsonPath > temp.json
            cat temp.json > $jsonPath
            rm temp.json

            unused_port=$(jq .Centres[$i].Servers[$indice_servidor].port $jsonPath)
            jq .Centres[$i].UnusedPorts[$numero_servidores].number=$unused_port $jsonPath > temp.json
            cat temp.json > $jsonPath
            rm temp.json

            name=$(jq .Centres[$i].Servers[$indice_servidor].name $jsonPath)
            jq .Centres[$i].UnusedPorts[$numero_servidores].name=$name $jsonPath > temp.json
            cat temp.json > $jsonPath
            rm temp.json

            # #Borramos el servidor
            jq --argjson indice $indice_servidor 'del(.Centres[0].Servers[$indice])' $jsonPath > temp.json
            cat temp.json > $jsonPath
            rm temp.json
            
            php -f ./scripts/info/apagar.php $public_ip $port $nombreServer $user $password
            #ssh -p $port mario@$public_ip 'bash -s' < ./apagar.sh $nombreServer
        fi
    fi
done
