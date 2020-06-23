#!/bin/bash

#Para poder cogegr el puerto como int , tenemos que quitarle primero las comillas
nombreMaquina="${1%\"}"
nombreMaquina="${nombreMaquina#\"}"

#Ademas vamos a quitar las comillas al nombre
#Para poder cogegr el puerto como int , tenemos que quitarle primero las comillas
puertoMinetest="${2%\"}"
puertoMinetest="${puertoMinetest#\"}"

#Ademas vamos a quitar las comillas al nombre
#Para poder cogegr el puerto como int , tenemos que quitarle primero las comillas
puertoSSH="${3%\"}"
puertoSSH="${puertoSSH#\"}"

private_ip="${4%\"}"
private_ip="${private_ip#\"}"



#Primero creamos una copia enlazada de la maquina base de minetest
vboxmanage clonevm Minetest-Server  --name=$nombreMaquina --options=Link --snapshot=Minetest --register

#Ahora añadimos la regla de redireccion de puerto de Minetest
vboxmanage modifyvm "$nombreMaquina" --natpf1 "TFG,udp,$private_ip,$puertoMinetest,10.0.2.15,30000"

#Ahora añadimos la regla de redireccion de puerto de SSH
vboxmanage modifyvm "$nombreMaquina" --natpf1 "SSH,tcp,$private_ip,$puertoSSH,10.0.2.15,22"

#AutoStart
VBoxManage modifyvm $nombreMaquina --autostart-enabled on

#Y una vez este configurada, la iniciamos
vboxmanage startvm $nombreMaquina --type headless
