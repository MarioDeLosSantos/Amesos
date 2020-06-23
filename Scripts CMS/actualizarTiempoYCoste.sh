#!/bin/bash
#Este Script recorerra todos los puertos disponibles (incluyendo el de la maquina fisica)
#para calcular cuanto tiempo lleva cada maquina levantada y ademas para los servidores
#cuanto es el coste de estos

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

            user=$(jq .Centres[$i].Servers[$j].user $jsonPath)
            temp="${user%\"}"
            temp="${temp#\"}"
            user=$temp
            password=$(jq .Centres[$i].Servers[$j].password $jsonPath)
            temp="${password%\"}"
            temp="${temp#\"}"
            password=$temp
            #Ahora creamos y encendemos dicha maquina
            port=$(jq .Centres[$i].Servers[$j].SSHPort $jsonPath)
            #newtime=$(ssh -p $port minetest@83.37.48.162 uptime | awk -F ',' ' {print $1} ' | 
            #awk ' {print $3} ' | awk -F ':' ' {hrs=$1; min=$2; print hrs + min} ') 

            newtime=$(php -f ./scripts/info/actualizar.php $public_ip $port $user $password)

            jq .Centres[$i].Servers[$j].TimeUp=$newtime $jsonPath > temp.json
            cat temp.json > $jsonPath
            rm temp.json

            #Ahora toca calcular el coste
            value=0.002116 #coste por minuto
            t=$(expr $newtime*$value | bc)

            jq .Centres[$i].Servers[$j].Cost=$t $jsonPath > temp.json
            cat temp.json > $jsonPath
            rm temp.json
        done

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
        #time=$(ssh -p $port mario@83.37.48.162 uptime | awk -F ',' ' {print $1} ' | 
        #awk ' {print $3} ' | awk -F ':' ' {hrs=$1; min=$2; print hrs + min} ') 

        time=$(php -f ./scripts/info/actualizar.php $public_ip $port $user $password)

        
        #Lo actualizamos en el json
        jq .Centres[$i].TimeUp=$time $jsonPath > temp.json
        cat temp.json > $jsonPath
        rm temp.json
    fi   
done