#!/bin/bash
#Descarga con aria2c la última versión disponible de Rambox según la plataforma

#Identifica plataforma
cd /tmp
if [ $(uname -m) == 'i686' ]; then
fuente=ia32
else
fuente=x64
fi

#Determina última versión publicada
archivo=$(curl https://github.com/saenzramiro/rambox/releases |grep $fuente.deb|head -n 1|cut -d\" -f 2)

#Descarga esa versión
aria2c -c -s3 -x3 "https://github.com"$archivo
sudo gdebi-gtk ./Rambox*.deb
