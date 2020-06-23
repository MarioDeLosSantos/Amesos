#!/bin/bash
#Este Script recorerra todos los puertos disponibles (incluyendo el de la maquina fisica)
#para calcular cuanto CPU usada tiene cada maquina (haciendo una media).

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
            
        public_ip=$(jq .Centres[$i].public_ip $jsonPath)
        temp="${public_ip%\"}"
        public_ip="${temp#\"}"

        #En caso de que hayamos encontrado el centro de procesamiento de datosackj 
        if [[ "$nombre" = $parametro ]] 
        then
            numero_servidores=$(jq --arg var $i '.Centres[$var | tonumber ].Servers | length -1' $jsonPath)
            for j in $( seq 0 $numero_servidores ); do
                #Ahora creamos y encendemos dicha maquina
                port=$(jq .Centres[$i].Servers[$j].SSHPort $jsonPath)
                
                #Quitamos las comillas con el temp
                user=$(jq .Centres[$i].Servers[$j].user $jsonPath)
                temp="${user%\"}"
                temp="${temp#\"}"
                user=$temp
                password=$(jq .Centres[$i].Servers[$j].password $jsonPath)
                temp="${password%\"}"
                temp="${temp#\"}"
                password=$temp
                    
                #Cogemos la nueva y la vieja CPU
                CPUAntigua=$(jq .Centres[$i].Servers[$j].ultimaCPU $jsonPath)
                
                CPUnueva=$(php -f ./scripts/info/CPU.php $public_ip $port $user $password) 
                #CPUnueva=$(ssh -p $port minetest@$public_ip echo $[100-$(vmstat 1 2|tail -1|awk '{print $15}')])
                #Actualizamos la ultima CPUs
                jq .Centres[$i].Servers[$j].ultimaCPU=$CPUnueva $jsonPath > temp.json
                cat temp.json > $jsonPath
                rm temp.json

                CPUmedia=$[($CPUAntigua + $CPUnueva)/2]
                
                jq .Centres[$i].Servers[$j].CPU=$CPUmedia $jsonPath > temp.json
                cat temp.json > $jsonPath
                rm temp.json

                #Ahora hacemos lo mismo pero calculando la memoria RAM usada
                #Cogemos la nueva y la vieja CPU
                MEMAntigua=$(jq .Centres[$i].Servers[$j].ultimaMem $jsonPath)
                MEMnueva=$(php -f ./scripts/info/Mem.php $public_ip $port $user $password) 
                #MEMnueva=$(ssh -p $port minetest@$public_ip vmstat -s | { read a b ; read c d ; echo $((100*$c/$a)) ; } ;)

                #Actualizamos la ultima CPUs
                jq .Centres[$i].Servers[$j].ultimaMem=$MEMnueva $jsonPath > temp.json
                cat temp.json > $jsonPath
                rm temp.json

                Memmedia=$[($MEMAntigua + $MEMnueva)/2]

                
                jq .Centres[$i].Servers[$j].Mem=$Memmedia $jsonPath > temp.json
                cat temp.json > $jsonPath
                rm temp.json

            done

            #Obtenemos los datos del nodo fisico
            user=$(jq .Centres[$i].user $jsonPath)
            temp="${user%\"}"
            temp="${temp#\"}"
            user=$temp

            password=$(jq .Centres[$i].password $jsonPath)
            temp="${password%\"}"
            temp="${temp#\"}"
            password=$temp

            #Ahora actualizamos la CPU y memoria me el propio nodo fisico
            port=$(jq .Centres[$i].port $jsonPath)
            Memnueva=$(php -f ./scripts/info/Mem.php $public_ip $port $user $password) 

            #Memnueva=$(ssh -p $port mario@$public_ip vmstat -s | { read a b ; read c d ; echo $((100*$c/$a)) ; } ;)

            #Lo actualizamos en el json
            jq .Centres[$i].Mem=$Memnueva $jsonPath > temp.json
            cat temp.json > $jsonPath
            rm temp.json

            #Ahora actualizamos la CPU y memoria me el propio nodo fisico
            #port=$(jq .Centres[$i].port $jsonPath)
            CPUnueva=$(php -f ./scripts/info/CPU.php $public_ip $port $user $password) 
            #CPUnueva=$(ssh -p $port mario@$public_ip echo $[100-$(vmstat 1 2|tail -1|awk '{print $15}')])
       
            #Lo actualizamos en el json
            jq .Centres[$i].CPU=$CPUnueva $jsonPath > temp.json
            cat temp.json > $jsonPath
            rm temp.json
        fi   
    done
