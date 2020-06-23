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
    temp="${temp#\"}"

    #En caso de que hayamos encontrado el centro de procesamiento de datosackj 
    #Abrimos el primer servidor disponible
    if [[ "$temp" = $parametro ]] 
    then
      #Buscamos el primer servidor disponible
      numero_servidores=$(jq --arg var $i '.Centres[$var | tonumber ].Servers | length  ' $jsonPath)

      #Creamos el nombre de la maquina en base al numero de servidores que haya 
      public_ip=$(jq .Centres[$i].public_ip $jsonPath)
      temp="${public_ip%\"}"
      public_ip="${temp#\"}"
      
      private_ip=$(jq .Centres[$i].private_ip $jsonPath)
      port=$(jq .Centres[$i].port $jsonPath)
      nombreMaquina="\"Servidor$numero_servidores"\"

      #ELEGIMOS EL SIGUIENTE PUERTO
      puertosDesuso=$(jq --arg var $i '.Centres[$var | tonumber ].UnusedPorts | length  ' $jsonPath)
      numero=1
      puertoMinetest=0
      puertoSSH=0

      if (("$puertosDesuso" < "$numero")); then
        puertoMinetest=$(jq .Centres[$i].NextAvaliablePort $jsonPath)
        puertoSSH=$(jq .Centres[$i].NextSSHPort $jsonPath)

        #Y por ultimo actualizamos el siguiente puerto disponible de Minetest
        NextPortMinetest=$(jq .Centres[$i].NextAvaliablePort $jsonPath)
        temp=$((NextPortMinetest+1))
        echo "puerto $temp"

        jq .Centres[$i].NextAvaliablePort=$temp $jsonPath > temp.json
        cat temp.json > $jsonPath
        rm temp.json

        #Y por ultimo actualizamos el siguiente puerto disponible de Minetest
        NextPortSSH=$(jq .Centres[$i].NextSSHPort $jsonPath)
        echo $NextPortSSH

        #Le quitamos las comillas para poder sumar
        temp2=$((NextPortSSH+1))

        jq .Centres[$i].NextSSHPort=$temp2 $jsonPath > temp.json
        cat temp.json > $jsonPath
        rm temp.json

      else
        puertoMinetest=$(jq .Centres[$i].UnusedPorts[0].number $jsonPath)
        nombreMaquina=$(jq .Centres[$i].UnusedPorts[0].name $jsonPath)
        #Borramos el server en desuso
        indice_servidor=0
        jq --argjson indice $indice_servidor 'del(.Centres[0].UnusedPorts[$indice])' $jsonPath > temp.json
        cat temp.json > $jsonPath
        rm temp.json
        puertoSSH=$((puertoMinetest+1000))

      fi
      
      #Quitamos las comillas con el temp
      user=$(jq .Centres[$i].user $jsonPath)
      temp="${user%\"}"
      temp="${temp#\"}"
      user=$temp
      password=$(jq .Centres[$i].password $jsonPath)
      temp="${password%\"}"
      temp="${temp#\"}"
      password=$temp

      #Aqui tenemos que actualizar el json con la nueva maquina que se va a abrir

      #Lo primero creamos los parametros 
      jq '.Centres[0].Servers += [{"name": "None","port": null,"SSHPort":null,"user":"minetest","password":"minetest","ultimaCPU":0,"ultimaMem":0,"CPU":0,"Mem":0,"TimeUp":0,"Cost":0}]' $jsonPath > temp.json
      cat temp.json > $jsonPath
      rm temp.json

     ###### NOMBRE DE LA MAQUINA ######

      #Primero el nombre
      jq .Centres[$i].Servers[$numero_servidores].name=$nombreMaquina $jsonPath > temp.json
      cat temp.json > $jsonPath
      rm temp.json

     ####### PUERTO DE MINETEST #######

      #Ahora el puerto de Minetest
      jq .Centres[$i].Servers[$numero_servidores].port=$puertoMinetest $jsonPath > temp.json
      cat temp.json > $jsonPath
      rm temp.json


     ####### PUERTO PARA EL SSH ########
      #Ahora el puerto de SSH
      jq .Centres[$i].Servers[$numero_servidores].SSHPort=$puertoSSH $jsonPath > temp.json
      cat temp.json > $jsonPath
      rm temp.json

      #Ahora creamos y encendemos dicha maquina
      php -f ./scripts/info/encender.php $nombreMaquina $puertoMinetest $puertoSSH $public_ip $private_ip $port $user $password

    fi
done
  