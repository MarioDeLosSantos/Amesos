#!/bin/bash
#Apagamos la maquina cuyo nombre sea igual al del parametro recibido
VBoxManage controlvm $1 poweroff
#La borramos
VBoxManage unregistervm $1 --delete
